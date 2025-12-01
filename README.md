# dmcoin

A simple fungible token smart contract built with [Clarinet](https://github.com/hirosystems/clarinet) for the Stacks blockchain.

## Project structure

- `Clarinet.toml` – Clarinet project configuration and contract registry
- `contracts/dmcoin.clar` – main `dmcoin` fungible token contract
- `settings/` – Clarinet network configuration (Devnet, Testnet, Mainnet)
- `tests/` – place for Clarinet tests (TypeScript + Vitest)

## Requirements

- [Clarinet](https://docs.hiro.so/clarinet/getting-started/installation) (already installed)
- Node.js (optional, for running tests)

You can verify Clarinet is available with:

```bash
clarinet --version
```

## Contract overview

The `dmcoin` contract implements a basic fungible token with:

- Token name: `dmcoin`
- Symbol: `DMC`
- Decimals: `6`
- Owner-controlled minting
- Balance tracking per principal
- Safe transfers with balance checks

### Key data definitions

- `total-supply` – `uint` data variable tracking the total minted supply
- `balances` – map from `{ owner: principal }` to `uint` balance
- `CONTRACT-OWNER` – constant principal allowed to mint new tokens

> IMPORTANT: Before deploying to a live network, update `CONTRACT-OWNER` in `contracts/dmcoin.clar` to the principal that should control minting.

### Public functions

- `get-name` → `(response (string-ascii 32) uint)` – returns the token name
- `get-symbol` → `(response (string-ascii 10) uint)` – returns the token symbol
- `get-decimals` → `(response uint uint)` – returns the number of decimal places
- `get-total-supply` → `(response uint uint)` – returns the total supply
- `get-balance (who principal)` → `(response uint uint)` – returns balance for `who`
- `mint (recipient principal) (amount uint)` → `(response uint uint)`
  - Mints `amount` tokens to `recipient`
  - Can only be called by `CONTRACT-OWNER`
- `transfer (amount uint) (sender principal) (recipient principal)` → `(response uint uint)`
  - Moves `amount` tokens from `sender` to `recipient`
  - `tx-sender` must equal `sender`
  - Fails if `sender` does not have enough balance

### Error codes

- `ERR-NOT-AUTHORIZED` → `(err u100)` – caller is not authorized (e.g. not owner or not sender)
- `ERR-INSUFFICIENT-BALANCE` → `(err u101)` – sender does not have enough tokens

## Common workflows

### 1. Check the contract

From the project root (`dmcoin`):

```bash
clarinet check
```

This will parse and analyze `contracts/dmcoin.clar` and report any syntax or analysis errors.

### 2. Start a Devnet and interact via console

Start a local Devnet:

```bash
clarinet integrate
```

In another terminal, you can open the Clarinet console:

```bash
clarinet console
```

Example console interactions (after deploying `dmcoin` in your Devnet flow):

```clarity
;; Check metadata
(contract-call? .dmcoin get-name)
(contract-call? .dmcoin get-symbol)
(contract-call? .dmcoin get-decimals)

;; Check balances
(contract-call? .dmcoin get-balance tx-sender)

;; Mint tokens (as CONTRACT-OWNER)
(contract-call? .dmcoin mint tx-sender u1000000)

;; Transfer tokens
(contract-call? .dmcoin transfer u100 tx-sender 'ST3J8EVYHVKH6C6FJ2VEQ23YH8C2V8J8N5M8KZK2F)
```

> Note: update principals in examples to match your Devnet accounts and the value of `CONTRACT-OWNER`.

### 3. Add tests (optional)

Clarinet scaffolds a TypeScript + Vitest test setup in `tests/`. You can add tests for `dmcoin` under `tests/` and run them with:

```bash
npm install
npm test
```

## Development tips

- Run `clarinet check` frequently while editing contracts
- Use `clarinet console` for quick manual testing
- Keep the README updated as you extend `dmcoin` with new functionality
