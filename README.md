```markdown
# 💧 DexTor – A Modern Uniswap V2 Clone with OpenZeppelin

**DexTor** is a smart contract project that lets you create a decentralized exchange (DEX) just like **Uniswap V2**, but written from scratch using the **latest version of Solidity**.

It’s clean, simple, secure — and ready to grow.

---

## 🌟 What Is This?

- A simplified version of Uniswap V2 (the most famous DEX on Ethereum).
- Built using modern Solidity (`^0.8.x`) — no old-school code.
- Includes **OpenZeppelin** for safer contracts.

---

## 🧠 Who Is It For?

- Developers learning how DEXs like Uniswap work.
- Teams building their own token swap system.
- Projects needing a reliable base to create a custom AMM.
- Anyone who wants to learn about how DeFi works, step-by-step.

---

## 🔧 Main Features

✅ Fully rewritten AMM (Uniswap V2-style)  
✅ Uses latest Solidity version (`0.8.x`)  
✅ Safer code with [OpenZeppelin](https://docs.openzeppelin.com/contracts)  
✅ Easy to extend or customize

---

## 🧱 How It Works

1. Factory creates Pairs
2. Pair holds liquidity (tokenA + tokenB)
3. LP tokens are given to liquidity providers
4. Swaps use the formula: tokenA \* tokenB = constant (k)
```

---

### 🔁 Example: Swapping Tokens

1. You add liquidity: ETH + DAI
2. Someone wants to swap DAI for ETH
3. The contract uses math to adjust balances and charge a small fee

---

## 🧩 Key Contracts

| Contract        | What It Does                           |
| --------------- | -------------------------------------- |
| `DexTorFactory` | Deploys and tracks all trading pairs   |
| `DexTorPair`    | Handles swaps and holds token balances |
| `DexTorERC20`   | Issues LP tokens for liquidity         |

---

## 🛡️ Technologies Used

- **Solidity `^0.8.20`** – latest features and safety
- **OpenZeppelin** – trusted building blocks (ERC20, security)

---

## 🔮 What’s Next?

- [ ] Add Router for easy swapping
- [ ] LP token `permit()` support (gasless approvals)
- [ ] Governance and fee options
- [ ] Frontend demo (React + Wagmi + Ethers.js)

---

## ⚙️ Example Use Case

> **Build your own token exchange**

Let’s say you launch a token called `$COFFEE`.  
You pair it with ETH on DexTor.  
Now, users can trade $COFFEE/ETH directly .

---

## 📚 Learn More

- [Uniswap V2 Whitepaper](https://uniswap.org/whitepaper-v2.pdf)
- [Solidity Docs](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)

---

## 🧑‍💻 Author

Built with ❤️ by [Mohamed-lahrach]  
Twitter: [@kings5layer]

---

## 📄 License

MIT — free to use, modify, and share.

---
