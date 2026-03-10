import {
  Connection,
  Keypair,
  LAMPORTS_PER_SOL,
  clusterApiUrl
} from "@solana/web3.js";
import {
  createMint,
  getOrCreateAssociatedTokenAccount,
  mintTo
} from "@solana/spl-token";
import dotenv from "dotenv";

dotenv.config();

const RPC_URL = process.env.RPC_URL || clusterApiUrl("devnet");
const TOKEN_NAME = process.env.TOKEN_NAME || "MySolanaCoin";
const TOKEN_SYMBOL = process.env.TOKEN_SYMBOL || "MSC";
const DECIMALS = Number.parseInt(process.env.DECIMALS || "9", 10);
const INITIAL_SUPPLY = Number.parseFloat(process.env.INITIAL_SUPPLY || "1000000");

function parseSecretKey(secretKeyRaw) {
  if (!secretKeyRaw) {
    return null;
  }

  try {
    const secret = JSON.parse(secretKeyRaw);
    return Uint8Array.from(secret);
  } catch {
    throw new Error("SECRET_KEY must be a valid JSON array of numbers.");
  }
}

async function ensureBalance(connection, wallet) {
  const balance = await connection.getBalance(wallet.publicKey);

  if (balance >= 0.5 * LAMPORTS_PER_SOL) {
    return;
  }

  console.log("Low SOL balance on devnet wallet, requesting an airdrop...");
  const signature = await connection.requestAirdrop(wallet.publicKey, LAMPORTS_PER_SOL);
  await connection.confirmTransaction(signature, "confirmed");
}

function toBaseUnits(amount, decimals) {
  return BigInt(Math.round(amount * 10 ** decimals));
}

async function main() {
  if (!Number.isFinite(DECIMALS) || DECIMALS < 0 || DECIMALS > 9) {
    throw new Error("DECIMALS must be a number between 0 and 9.");
  }

  if (!Number.isFinite(INITIAL_SUPPLY) || INITIAL_SUPPLY <= 0) {
    throw new Error("INITIAL_SUPPLY must be a positive number.");
  }

  const connection = new Connection(RPC_URL, "confirmed");
  const providedSecret = parseSecretKey(process.env.SECRET_KEY);
  const payer = providedSecret ? Keypair.fromSecretKey(providedSecret) : Keypair.generate();

  console.log(`Network: ${RPC_URL}`);
  console.log(`Token: ${TOKEN_NAME} (${TOKEN_SYMBOL})`);
  console.log(`Payer address: ${payer.publicKey.toBase58()}`);

  await ensureBalance(connection, payer);

  const mint = await createMint(
    connection,
    payer,
    payer.publicKey,
    null,
    DECIMALS
  );

  const tokenAccount = await getOrCreateAssociatedTokenAccount(
    connection,
    payer,
    mint,
    payer.publicKey
  );

  const mintAmount = toBaseUnits(INITIAL_SUPPLY, DECIMALS);

  await mintTo(
    connection,
    payer,
    mint,
    tokenAccount.address,
    payer,
    mintAmount
  );

  console.log("\n✅ Token created successfully");
  console.log(`Mint address: ${mint.toBase58()}`);
  console.log(`Token account: ${tokenAccount.address.toBase58()}`);
  console.log(`Minted supply: ${INITIAL_SUPPLY} ${TOKEN_SYMBOL}`);
}

main().catch((error) => {
  console.error("\n❌ Failed to create token");
  console.error(error.message);
  process.exit(1);
});
