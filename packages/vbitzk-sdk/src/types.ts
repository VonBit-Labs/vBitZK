/**
 * Core type definitions for vBitZK SDK
 */

/** Ethereum address */
export type Address = `0x${string}`;

/** 32-byte hash */
export type Hash = `0x${string}`;

/** Basis points (0-10000) */
export type Bps = number;

/** Beneficial ownership proof */
export interface BOProof {
  proofData: string;
  wallet: Address;
  exposures: Exposure[];
  nestingDepth: number;
  protocolsTraversed: string[];
  generatedAt: string;
  expiresAt: string;
  verificationGas: number;
}

/** Terminal asset exposure */
export interface Exposure {
  asset: string;
  amount: string;
  percentage: number;
}

/** Prover configuration */
export interface ProverConfig {
  network?: 'mainnet' | 'base' | 'arbitrum' | 'polygon';
  apiKey?: string;
  proverEndpoint?: string;
}

/** Proof request parameters */
export interface ProofRequest {
  wallet: Address;
  asOf?: Date;
  maxDepth?: number;
}
