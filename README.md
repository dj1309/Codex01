# Codex01

Create your own crypto coin on Solana (an SPL token).

> If by “like Solana” you mean creating a whole new blockchain like Solana, that is a much larger Layer-1 engineering project. This repo helps you create a **coin on Solana** quickly.

## What this does

This project provides:
- A setup + mint script: `scripts/create_solana_like_coin.sh`
- A straightforward workflow to create and mint your token on Solana devnet/mainnet

## Prerequisites

Install:
- [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools)
- [SPL Token CLI](https://spl.solana.com/token)
- `jq`

Verify:

```bash
solana --version
spl-token --version
jq --version
```

## Quick start (devnet)

1. Configure Solana to devnet:

```bash
solana config set --url https://api.devnet.solana.com
```

2. Create or use a wallet:

```bash
solana-keygen new -o ~/.config/solana/devnet-wallet.json
solana config set --keypair ~/.config/solana/devnet-wallet.json
```

3. Airdrop test SOL:

```bash
solana airdrop 2
```

4. Run the script:

```bash
bash scripts/create_solana_like_coin.sh \
  --name "My Solana Style Coin" \
  --symbol "MSC" \
  --decimals 9 \
  --supply 1000000 \
  --network devnet
```

5. The script prints your token mint address and associated token account.

## Mainnet notes

- Switch URL to mainnet: `solana config set --url https://api.mainnet-beta.solana.com`
- Use real SOL (no airdrop).
- Double-check mint authority and freeze authority handling before launch.

## Example outputs to save

- Mint address
- Token account address
- Signature IDs for mint and transfers

## Important security tips

- Keep your keypair secure.
- Consider revoking mint authority after fixed supply minting.
- Avoid sharing your seed phrase or private key.

