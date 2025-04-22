// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import {UQ112x112, Math} from "src/core/libraries/UQ112x112.sol";
import {IDexTorFactory} from "src/core/interfaces/IDexTorFactory.sol";
import {DexTorERC20} from "src/core/DexTorERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DexTorPair is DexTorERC20 {
    using UQ112x112 for uint224;
    using Math for uint;
    error DexTorPair__ZeroAddress();
    error DexTorPair__TokensHaveSameAddresses();
    error DexTorPair__BurnAmountExceedsBalance();
    error DexTorPair__LOCKED();
    error DexTorPair__BalanceExceedsUint112Max();
    error DexTorPair__ZeroBalances();
    error DexTorPair__ZeroLiquidity();
    error DexTorPair__ZeroAmounts();
    error DexTorPair__TransferFailed();
    error DexTorPair__SwapAmountExceedsBalance();
    error DexTorPair__InvalidTo();

    uint private constant MINIMUM_LIQUIDITY = 10 ** 3;

    address public immutable factory;
    address public immutable token0;
    address public immutable token1;

    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor(address _token0, address _token1, address _factory) {
        if (_token0 == address(0) || _token0 == address(0)) {
            revert DexTorPair__ZeroAddress();
        }
        if (_token0 == _token1) {
            revert DexTorPair__TokensHaveSameAddresses();
        }
        token0 = _token0;
        token1 = _token1;
        factory = _factory;
    }

    uint256 private unlocked = 1;
    modifier lock() {
        if (unlocked != 1) {
            revert DexTorPair__LOCKED();
        }
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, ) = token.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, value)
        );

        if (!success) {
            revert DexTorPair__TransferFailed();
        }
    }

    function _update(
        uint balance0,
        uint balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        if (balance0 > type(uint112).max || balance1 > type(uint112).max) {
            revert DexTorPair__BalanceExceedsUint112Max();
        }
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            unchecked {
                // price of x in term of y
                price0CumulativeLast +=
                    uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                    timeElapsed;
                // price of y in term of x
                price1CumulativeLast +=
                    uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                    timeElapsed;
            }
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;

        emit Sync(reserve0, reserve1);
    }

    /**
     * @dev The _mintFee function calculates and mints liquidity tokens as a fee if certain conditions are met.
     *  The fee is based on the growth in the square root of the product of the reserves (k).
     *  This mechanism is used in Uniswap V2 to ensure that liquidity providers (LPs) are incentivized and properly rewarded when the protocol's fee mechanism is active.
     * @param _reserve0 token0 reserve
     * @param _reserve1 token1 reserve
     * @return feeOn boolean indicating if the fee is on or not
     */
    function _mintFee(
        uint112 _reserve0,
        uint112 _reserve1
    ) private returns (bool feeOn) {
        // If the fee mechanism is active (feeOn == true) and _kLast is not zero:
        // Calculate rootK and rootKLast:
        // rootK is the square root of the current product of reserves (_reserve0 * _reserve1).
        // rootKLast is the square root of the previous product of reserves (_kLast).
        // Ensure Growth in Product of Reserves:
        // If rootK (current) is greater than rootKLast (previous), it means the reserves have grown, and liquidity fees need to be minted.
        // Calculate Liquidity:
        // numerator is the product of the total supply of liquidity tokens (totalSupply) and the growth in reserves (rootK - rootKLast).
        // denominator is a weighted sum of the current and previous reserves (rootK * 5 + rootKLast).
        // liquidity is the amount of liquidity tokens to mint, calculated as numerator / denominator.
        // Mint Liquidity:
        // If liquidity > 0, mint the calculated amount of liquidity tokens to the feeTo address.
        address feeTo = IDexTorFactory(factory).getFeeTo();
        if (feeTo != address(0)) {
            feeOn = true;
        } else {
            feeOn = false;
        }
        uint _kLast = kLast;
        if (feeOn && _kLast != 0) {
            uint rootK = Math.sqrt(uint(_reserve0) * uint(_reserve1));
            uint rootKLast = Math.sqrt(_kLast);
            if (rootK > rootKLast) {
                uint numerator = totalSupply() * (rootK - rootKLast);
                uint denominator = (rootK * 5 + rootKLast);
                uint liquidity = numerator / denominator;
                if (liquidity > 0) {
                    _mint(feeTo, liquidity);
                }
            }
        } else if (!feeOn && _kLast != 0) {
            kLast = 0;
        }
    }

    function mint(address to) external lock returns (uint liquidity) {
        /**
         * @dev Retrieve Current Reserves
         */
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        /**
         * @dev Get Token Balances:
         */
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        if (balance0 == 0 || balance1 == 0) {
            revert DexTorPair__ZeroBalances();
        }
        /**
         * @dev Calculate Amounts Added
         */
        uint amount0 = balance0 - _reserve0;
        uint amount1 = balance1 - _reserve1;
        /**
         * @dev Calls _mintFee to determine if the protocol fee is enabled
         * and possibly mint a fee
         */
        bool feeOn = _mintFee(_reserve0, _reserve1);
        /**
         * @dev Calculate Liquidity to Mint
         */
        uint _totalSupply = totalSupply();
        /**
         * @devIf the pool is new (_totalSupply == 0),
         * it calculates the initial liquidity tokens proportional to the geometric mean of amount0 and amount1.
         * It also permanently locks a small amount (MINIMUM_LIQUIDITY) to prevent the pool from being drained completely.
         */
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the minimum liquidity
        } else {
            /**
             * @dev If the pool is not new, it calculates the liquidity tokens based on the ratio of the amounts added to the reserves.
             * @notice The ternary operator (condition ? value1 : value2) is used to select the smaller value between the two calculations.
             */
            liquidity = ((amount0 * _totalSupply) / _reserve0 <
                (amount1 * _totalSupply) / _reserve1)
                ? ((amount0 * _totalSupply) / _reserve0)
                : ((amount1 * _totalSupply) / _reserve1);
        }
        if (liquidity <= 0) {
            revert DexTorPair__ZeroLiquidity();
        }
        /**
         * @dev Mint Liquidity Tokens
         */
        _mint(to, liquidity);

        /**
         * @dev Update Reserves
         */
        _update(balance0, balance1, _reserve0, _reserve1);

        /**
         * @dev Store kLast if Fees Are On
         */
        if (feeOn) {
            kLast = uint(reserve0) * uint(reserve1);
        }
        /**
         * @dev Emit Mint Event
         */
        emit Mint(msg.sender, amount0, amount1);
    }

    /**
     * @dev The burn function allows a liquidity provider to remove their liquidity from the pool.
     * @param to address to send the tokens to
     * @return amount0
     * @return amount1
     */
    function burn(
        address to
    ) external lock returns (uint amount0, uint amount1) {
        /**
         * @dev Retrieve Current Reserves
         */
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        /**
         * @dev Get Token Balances:
         * @notice Saves gas by fetching token0 and token1 addresses into local variables.
         */
        address _token0 = token0;
        address _token1 = token1;
        /**
         * @dev Get Balances and Liquidity
         */
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        if (balance0 == 0 || balance1 == 0) {
            revert DexTorPair__ZeroBalances();
        }
        uint liquidity = balanceOf(address(this));
        /**
         * @dev Mint Fee (if applicable)
         * Checks if a protocol fee is active and mints the fee to the fee recipient.
         */
        bool feeOn = _mintFee(_reserve0, _reserve1);
        /**
         * @dev Calculate Withdrawal Amounts
         * Calculates how much of token0 and token1 should be returned to the liquidity provider
         * based on their share of the total supply (liquidity / totalSupply).
         */
        uint _totalSupply = totalSupply();
        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;
        if (amount0 <= 0 && amount1 <= 0) {
            revert DexTorPair__ZeroAmounts();
        }
        /**
         * @dev Burn Liquidity Tokens
         * @notice The _burn function is called to remove the liquidity tokens from the pool.
         */
        _burn(address(this), liquidity);
        /**
         * @dev Transfer Tokens to User
         * @notice Transfers the proportionate amounts of token0 and token1 to the specified address (to).
         */
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        /**
         * @dev Update Balances and Reserves
         */
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        _update(balance0, balance1, _reserve0, _reserve1);
        /**
         * @dev Store kLast if Fees Are On
         */
        if (feeOn) {
            kLast = uint(reserve0) * uint(reserve1);
        }
        /**
         * @dev Emit Burn Event
         */
        emit Burn(msg.sender, amount0, amount1, to);
    }

    /**
     * @notice Executes a token swap between token0 and token1.
     * @dev This function allows users to swap tokens by specifying the output amounts for token0 and token1.
     *      It ensures that the swap respects the pool's reserves and maintains the invariant.
     * @param amount0Out The amount of token0 to send to the recipient.
     * @param amount1Out The amount of token1 to send to the recipient.
     * @param to The address to receive the output tokens.
     * @param data Additional data to be passed to the recipient for callback execution.
     */
    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external lock {
        // Ensure at least one of the output amounts is greater than zero
        if (amount0Out <= 0 || amount1Out <= 0) {
            revert DexTorPair__ZeroAmounts();
        }

        // Retrieve the current reserves of token0 and token1
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();

        // Ensure the output amounts do not exceed the current reserves
        if (amount0Out >= _reserve0 || amount1Out >= _reserve1) {
            revert DexTorPair__SwapAmountExceedsBalance();
        }

        uint balance0;
        uint balance1;

        {
            // Scope for local variables to avoid stack too deep errors
            address _token0 = token0;
            address _token1 = token1;

            // Ensure the recipient address is not one of the token addresses
            if (to == _token0 || to == _token1) {
                revert DexTorPair__InvalidTo();
            }

            // Transfer the specified output amounts to the recipient
            if (amount0Out > 0) {
                _safeTransfer(_token0, to, amount0Out);
            }
            if (amount1Out > 0) {
                _safeTransfer(_token1, to, amount1Out);
            }

            // If additional data is provided, execute a callback to the recipient
            if (data.length > 0) {
                (bool success, ) = to.call(data);
                if (!success) {
                    revert DexTorPair__TransferFailed();
                }
            }

            // Update the balances of token0 and token1 after the transfers
            balance0 = IERC20(token0).balanceOf(address(this));
            balance1 = IERC20(token1).balanceOf(address(this));
        }

        // Calculate the input amounts for token0 and token1
        uint amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;

        // Ensure at least one of the input amounts is greater than zero
        if (amount0In <= 0 || amount1In <= 0) {
            revert DexTorPair__ZeroAmounts();
        }

        {
            // Adjust the balances to account for a 0.3% fee on the input amounts
            uint balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
            uint balance1Adjusted = (balance1 * 1000) - (amount1In * 3);

            // Ensure the invariant (k = reserve0 * reserve1) is maintained
            if (
                balance0Adjusted * balance1Adjusted <
                uint(reserve0) * uint(reserve1) * 1000 ** 2
            ) {
                revert DexTorPair__SwapAmountExceedsBalance();
            }
        }

        // Update the reserves to match the new balances
        _update(balance0, balance1, _reserve0, _reserve1);

        // Emit a Swap event with details of the transaction
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    /**
     * @dev // force balances to match reserves
     */
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint amount0 = IERC20(_token0).balanceOf(address(this)) -
            uint(reserve0);
        uint amount1 = IERC20(_token0).balanceOf(address(this)) -
            uint(reserve1);

        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
    }

    /**
     * @dev force reserves to match balances
     */
    function sync() external lock {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }
}
