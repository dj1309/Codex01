# Solana-Style Crypto Coin Starter

This repository now includes a starter script to create your own **SPL token on Solana Devnet**.

> "Like Solana" can mean different things. Building a full Layer-1 chain like Solana is a huge engineering effort, but creating a Solana-based token is straightforward with this project.

## What this does

- Connects to **Solana Devnet**
- Creates a new wallet (or uses one from `SECRET_KEY`)
- Airdrops SOL on devnet if needed
- Creates a new SPL token mint
- Creates your Associated Token Account
- Mints an initial supply into your wallet

## Prerequisites

- Node.js 18+
- npm

## Setup

```bash
npm install
cp .env.example .env
```

Optional: set your own wallet secret key in `.env`.

## Run

```bash
npm run create-token
```

## Environment variables

| Variable | Required | Description |
| --- | --- | --- |
| `RPC_URL` | No | Solana RPC endpoint (defaults to devnet) |
| `TOKEN_NAME` | No | Name for display/logging |
| `TOKEN_SYMBOL` | No | Symbol for display/logging |
| `DECIMALS` | No | Number of decimals (default 9) |
| `INITIAL_SUPPLY` | No | Human-readable supply to mint (default 1000000) |
| `SECRET_KEY` | No | JSON array of 64-byte wallet secret key |

## Notes

- This script creates the mint and tokens. Metadata (name/symbol/logo on explorers/wallets) usually requires Metaplex metadata setup.
- Devnet tokens are for testing only.
