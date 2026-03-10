#!/usr/bin/env bash
set -euo pipefail

NAME=""
SYMBOL=""
DECIMALS="9"
SUPPLY="1000000"
NETWORK="devnet"

usage() {
  cat <<USAGE
Usage:
  $0 --name <token_name> --symbol <token_symbol> [--decimals 9] [--supply 1000000] [--network devnet|mainnet]

Example:
  $0 --name "My Solana Style Coin" --symbol MSC --decimals 9 --supply 1000000 --network devnet
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      NAME="$2"
      shift 2
      ;;
    --symbol)
      SYMBOL="$2"
      shift 2
      ;;
    --decimals)
      DECIMALS="$2"
      shift 2
      ;;
    --supply)
      SUPPLY="$2"
      shift 2
      ;;
    --network)
      NETWORK="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$NAME" || -z "$SYMBOL" ]]; then
  echo "Error: --name and --symbol are required."
  usage
  exit 1
fi

if ! command -v solana >/dev/null 2>&1; then
  echo "Error: solana CLI not installed."
  exit 1
fi

if ! command -v spl-token >/dev/null 2>&1; then
  echo "Error: spl-token CLI not installed."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required."
  exit 1
fi

case "$NETWORK" in
  devnet)
    RPC_URL="https://api.devnet.solana.com"
    ;;
  mainnet)
    RPC_URL="https://api.mainnet-beta.solana.com"
    ;;
  *)
    echo "Error: --network must be devnet or mainnet"
    exit 1
    ;;
esac

solana config set --url "$RPC_URL" >/dev/null

OWNER_PUBKEY="$(solana address)"

echo "Network: $NETWORK"
echo "Owner: $OWNER_PUBKEY"
echo "Creating token: $NAME ($SYMBOL)"

CREATE_OUTPUT="$(spl-token create-token --decimals "$DECIMALS")"
MINT_ADDRESS="$(echo "$CREATE_OUTPUT" | awk '/Creating token/ {print $3}')"

if [[ -z "$MINT_ADDRESS" ]]; then
  echo "Error: failed to parse mint address."
  echo "$CREATE_OUTPUT"
  exit 1
fi

ACCOUNT_OUTPUT="$(spl-token create-account "$MINT_ADDRESS")"
TOKEN_ACCOUNT="$(echo "$ACCOUNT_OUTPUT" | awk '/Creating account/ {print $3}')"

if [[ -z "$TOKEN_ACCOUNT" ]]; then
  echo "Error: failed to parse token account address."
  echo "$ACCOUNT_OUTPUT"
  exit 1
fi

# Mint initial supply to owner's token account
spl-token mint "$MINT_ADDRESS" "$SUPPLY" "$TOKEN_ACCOUNT" >/dev/null

cat <<RESULT

✅ Token created successfully.

Name:           $NAME
Symbol:         $SYMBOL
Mint address:   $MINT_ADDRESS
Token account:  $TOKEN_ACCOUNT
Decimals:       $DECIMALS
Initial supply: $SUPPLY
Network:        $NETWORK

Next useful commands:
  spl-token supply $MINT_ADDRESS
  spl-token accounts
  spl-token authorize $MINT_ADDRESS mint --disable   # optional: lock fixed supply forever

RESULT
