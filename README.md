# 🪙 KaratLend – A Minimal DeFi Lending Pool

KaratLend is a minimal decentralized lending pool built with Solidity, Foundry, and OpenZeppelin. It supports multiple tokens, dynamic interest rates based on pool utilization, flash loans, and even NFT collateral.

---

## 🚀 Features

- ✅ Supply and borrow ERC-20 tokens
- 📈 Dynamic interest rates based on utilization
- 💰 Flash loan support
- 🖼️ NFT as collateral (experimental)
- 🔐 Built with OpenZeppelin security standards

---

## 🛠️ Installation

```bash
git clone https://github.com/yourusername/karatlend.git
cd karatlend

# Install Foundry dependencies
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

---

## 📁 Project Structure

```
karatlend/
├── src/
│   └── LendingPool.sol
├── test/
│   └── LendingPool.t.sol
├── foundry.toml
└── lib/
    └── openzeppelin-contracts/
```

---

## 🧪 Running Tests

```bash
forge test
```

---

## 🧾 Smart Contract Overview

### `LendingPool.sol`

| Function      | Description                                                     |
| ------------- | --------------------------------------------------------------- |
| `supply()`    | Users deposit tokens into the pool                              |
| `borrow()`    | Users borrow tokens (against supplied tokens or NFT collateral) |
| `repay()`     | Users repay borrowed tokens                                     |
| `withdraw()`  | Withdraw deposited tokens if not locked                         |
| `flashLoan()` | Perform instant, no-collateral loans                            |

---

## 📄 License

MIT

---

## ✨ Author

Made with 💛 by [Abubakar Ibrahim](https://abubakar.life)
