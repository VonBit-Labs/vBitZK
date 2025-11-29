/**
 * @vonbit/vbitzk-sdk
 * 
 * Zero-knowledge beneficial ownership proofs for the tokenized economy.
 * 
 * @example
 * ```typescript
 * import { VBitZKProver, proveWithCysic } from '@vonbit/vbitzk-sdk';
 * 
 * // One-liner proof via Cysic network
 * const { proof, provingTimeMs, costUsd } = await proveWithCysic({
 *   wallet: '0x...',
 *   exposureBps: 5000
 * });
 * ```
 */

export * from './types';
export * from './prover';

export const VERSION = '1.1.0';
