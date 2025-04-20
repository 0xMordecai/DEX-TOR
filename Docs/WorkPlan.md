```markdown
# ✅ DexTor – Development Work Plan

This is a step-by-step plan to build **DexTor**, a Uniswap V2-style DEX using modern **Solidity** and **Foundry**.  
No frontend, no oracle — just clean, secure smart contracts.

---

## 🔧 PHASE 1: Project Setup

**Goal:** Initialize Foundry and create your project structure.

### Tasks:

- [Done] Install Foundry if you haven't: `curl -L https://foundry.paradigm.xyz | bash`
- [Done] Run `foundryup`
- [Done] Create a new project: `forge init`
```

- [ ] Install OpenZeppelin:  
       `forge install OpenZeppelin/openzeppelin-contracts`

### Folder Structure:

```
/src
  ├─ DexTorFactory.sol
  ├─ DexTorPair.sol
  ├─ DexTorERC20.sol
  └─ interfaces/
/test
/lib
```

---

## 🔁 PHASE 2: Core Contracts

### 2.1 🪙 DexTorERC20 (LP Token) : Done

- [Done] Inherit from `ERC20`
- [Done] Add `mint(address, amount)` and `burn(address, amount)`
- [Done] Keep track of total supply and balances

### 2.2 💧 DexTorPair (Swaps & Liquidity) Done

- [Done] Store `token0`, `token1`
- [Done] Store `reserve0`, `reserve1`
- [Done] Implement `swap()` → apply formula: `x * y = k`
- [Done] Charge a small swap fee (e.g., 0.3%)
- [Done] Add `sync()` to update reserves

### 2.3 🏭 DexTorFactory 85 % done

- [ ] Deploy new `DexTorPair` contracts with `create2`
- [ ] Ensure unique token pairs
- [ ] Track all pairs in a mapping
- [ ] Emit `PairCreated()` event

---

## 🧪 PHASE 3: Testing

**Goal:** Make sure your contracts work properly.

### Tasks:

- [ ] Write tests in `/test` using Foundry (Forge)
- [ ] Test adding/removing liquidity
- [ ] Test token swaps
- [ ] Check reserves, fees, LP token behavior
- [ ] Test edge cases (zero amounts, reentrancy)

✅ Example test:

```solidity
function testSwapDAIForETH() public {
    // add liquidity
    // perform swap
    // assert balances and reserves
}
```

---

## 🛠️ PHASE 4: Extras (Optional)

**Goal:** Make your contracts more flexible and production-ready.

### Tasks:

- [ ] Add `Ownable` to Factory (to control fees later)
- [ ] Add a protocol fee switch (optional % sent to treasury)
- [ ] Create simple interfaces: `IDexTorFactory`, `IDexTorPair`
- [ ] Add a basic Router contract (like Uniswap’s Router02)

---

## 📦 Tools Used

- **Foundry** – Compile, test, deploy (`forge`, `cast`)
- **Solidity** – `^0.8.20`
- **OpenZeppelin** – For ERC20 and security helpers

---

## 📁 Final Folder Structure

```
/src
  ├─ DexTorFactory.sol
  ├─ DexTorPair.sol
  ├─ DexTorERC20.sol
  └─ interfaces/
      ├─ IDexTorFactory.sol
      └─ IDexTorPair.sol

/test
  ├─ DexTorPair.t.sol
  ├─ DexTorFactory.t.sol
/lib
```

---

## 🚀 Next Steps After Core Build

- Add a Router contract (to help users swap easily)
- Optional: Frontend (React + Wagmi + Ethers.js)
- Optional: Governance (fee switch, admin rights)

---

## 💬 Need Help?

- Ask ChatGPT 😄
- Read the [Uniswap V2 Whitepaper](https://uniswap.org/whitepaper-v2.pdf)
- Visit [Foundry Book](https://book.getfoundry.sh/) for dev tools
- Use [OpenZeppelin Docs](https://docs.openzeppelin.com/contracts)

---

Happy coding! 💻⚡

```

---
```
