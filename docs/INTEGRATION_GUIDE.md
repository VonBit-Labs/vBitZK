# vBitZK Integration Guide

This guide walks you through integrating vBitZK beneficial ownership proofs into your application.

## Overview

vBitZK provides three integration paths:

1. **TypeScript SDK** — For web applications and Node.js backends
2. **Rust Crate** — For high-performance or embedded use cases
3. **Direct API** — For any language via REST endpoints

---

## Prerequisites

- Node.js 18+ or Rust 1.70+
- API key from [vonbit.co/developers](https://vonbit.co/developers)
- Understanding of beneficial ownership concepts

---

## TypeScript Integration

### Installation

```bash
npm install @vonbit/vbitzk-sdk
# or
yarn add @vonbit/vbitzk-sdk
# or
pnpm add @vonbit/vbitzk-sdk
```

### Basic Usage

```typescript
import { VBitZKProver, ProofRequest } from '@vonbit/vbitzk-sdk';

// Initialize with your API key
const prover = new VBitZKProver({
  apiKey: process.env.VONBIT_API_KEY,
  network: 'mainnet', // or 'base', 'arbitrum', etc.
});

// Generate a beneficial ownership proof
async function generateProof(walletAddress: string) {
  const proof = await prover.proveBeneficialOwnership({
    wallet: walletAddress,
    asOf: new Date(),
    maxDepth: 32, // Maximum nesting layers to traverse
  });

  return proof;
}
```

### Proof Response Structure

```typescript
interface BOProof {
  // The ZK proof data (312 bytes)
  proofData: string;
  
  // Wallet that was analyzed
  wallet: string;
  
  // Terminal asset exposures
  exposures: Array<{
    asset: string;      // 'ETH', 'USDC', 'WBTC', etc.
    amount: string;     // Raw amount
    percentage: number; // Percentage of total portfolio
  }>;
  
  // How deep the nesting went
  nestingDepth: number;
  
  // Protocols that were traversed
  protocolsTraversed: string[];
  
  // Proof metadata
  generatedAt: string;
  expiresAt: string;
  
  // Verification info
  verificationGas: number;
  verifierAddress: string;
}
```

### Verifying Proofs On-Chain

```typescript
import { ethers } from 'ethers';

async function verifyOnChain(proof: BOProof) {
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  
  const isValid = await prover.verifyOnChain(
    proof,
    provider
  );
  
  console.log('Proof valid:', isValid);
}
```

### Generating Compliance Reports

```typescript
// Generate FinCEN-compatible SAR
const sar = await prover.generateSAR({
  wallet: '0x...',
  format: 'FinCEN',
  period: {
    start: '2025-01-01',
    end: '2025-12-31'
  }
});

// Generate CTR (Currency Transaction Report)
const ctr = await prover.generateCTR({
  wallet: '0x...',
  transactions: [...],
  format: 'FinCEN'
});
```

---

## Rust Integration

### Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
vbitzk-prover = "1.1"
tokio = { version = "1", features = ["full"] }
```

### Basic Usage

```rust
use vbitzk_prover::{Prover, Config, ProofRequest};
use chrono::Utc;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize prover
    let config = Config::mainnet()
        .with_api_key(std::env::var("VONBIT_API_KEY")?);
    
    let prover = Prover::new(config)?;
    
    // Generate proof
    let proof = prover.prove_beneficial_ownership(ProofRequest {
        wallet: "0x742d35Cc6634C0532925a3b844Bc9e7595f8a2".parse()?,
        as_of: Utc::now(),
        max_depth: 32,
    }).await?;
    
    println!("Proof size: {} bytes", proof.data.len());
    println!("Nesting depth: {}", proof.nesting_depth);
    
    Ok(())
}
```

---

## Direct API

### Generate Proof

```bash
curl -X POST https://api.vonbit.co/v1/prove \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "wallet": "0x742d35Cc6634C0532925a3b844Bc9e7595f8a2",
    "network": "ethereum",
    "maxDepth": 32
  }'
```

### Response

```json
{
  "success": true,
  "proof": {
    "proofData": "0x1a2b3c...",
    "wallet": "0x742d35Cc6634C0532925a3b844Bc9e7595f8a2",
    "exposures": [
      { "asset": "ETH", "amount": "165.5", "percentage": 79.2 },
      { "asset": "USDC", "amount": "88420", "percentage": 20.8 }
    ],
    "nestingDepth": 7,
    "protocolsTraversed": ["Aave", "Pendle", "EigenLayer", "Kelp"],
    "generatedAt": "2025-11-29T14:30:00Z",
    "expiresAt": "2026-02-27T14:30:00Z",
    "verificationGas": 62000
  }
}
```

### Verify Proof

```bash
curl -X POST https://api.vonbit.co/v1/verify \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "proofData": "0x1a2b3c...",
    "wallet": "0x742d35Cc6634C0532925a3b844Bc9e7595f8a2"
  }'
```

---

## Smart Contract Integration

### Verifier Interface

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVBitZKVerifier {
    /// @notice Verify a beneficial ownership proof
    /// @param proof The ZK proof data
    /// @param wallet The wallet address the proof is for
    /// @return valid Whether the proof is valid
    function verify(
        bytes calldata proof,
        address wallet
    ) external view returns (bool valid);
    
    /// @notice Get the expiration timestamp of a proof
    /// @param proof The ZK proof data
    /// @return expiresAt Unix timestamp when proof expires
    function getExpiration(
        bytes calldata proof
    ) external pure returns (uint256 expiresAt);
    
    /// @notice Extract exposures from a proof
    /// @param proof The ZK proof data
    /// @return assets Array of asset addresses
    /// @return percentages Array of exposure percentages (basis points)
    function getExposures(
        bytes calldata proof
    ) external pure returns (
        address[] memory assets,
        uint256[] memory percentages
    );
}
```

### Usage Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVBitZKVerifier} from "@vonbit/contracts/IVBitZKVerifier.sol";

contract ComplianceGatedVault {
    IVBitZKVerifier public immutable verifier;
    
    constructor(address _verifier) {
        verifier = IVBitZKVerifier(_verifier);
    }
    
    modifier requiresValidBO(bytes calldata boProof) {
        require(
            verifier.verify(boProof, msg.sender),
            "Invalid beneficial ownership proof"
        );
        require(
            verifier.getExpiration(boProof) > block.timestamp,
            "Proof expired"
        );
        _;
    }
    
    function deposit(
        uint256 amount,
        bytes calldata boProof
    ) external requiresValidBO(boProof) {
        // Deposit logic - only compliant users can deposit
    }
}
```

---

## Error Handling

### TypeScript

```typescript
import { VBitZKError, ProofError, NetworkError } from '@vonbit/vbitzk-sdk';

try {
  const proof = await prover.proveBeneficialOwnership({ ... });
} catch (error) {
  if (error instanceof ProofError) {
    // Proof generation failed
    console.error('Proof error:', error.code, error.message);
  } else if (error instanceof NetworkError) {
    // Network/API issues
    console.error('Network error:', error.message);
  } else {
    throw error;
  }
}
```

### Error Codes

| Code | Description |
|------|-------------|
| `INVALID_WALLET` | Wallet address is malformed |
| `UNSUPPORTED_NETWORK` | Network not supported |
| `MAX_DEPTH_EXCEEDED` | Nesting exceeds 32 layers |
| `UNSUPPORTED_PROTOCOL` | Position in unsupported protocol |
| `PROOF_GENERATION_FAILED` | Prover network error |
| `RATE_LIMIT_EXCEEDED` | Too many requests |

---

## Best Practices

### 1. Cache Proofs

Proofs are valid for 90 days. Cache them to avoid regeneration costs.

```typescript
const cache = new Map<string, BOProof>();

async function getProof(wallet: string) {
  const cached = cache.get(wallet);
  if (cached && new Date(cached.expiresAt) > new Date()) {
    return cached;
  }
  
  const proof = await prover.proveBeneficialOwnership({ wallet });
  cache.set(wallet, proof);
  return proof;
}
```

### 2. Batch Requests

For multiple wallets, use batch API:

```typescript
const proofs = await prover.proveBatch([
  { wallet: '0x...' },
  { wallet: '0x...' },
  { wallet: '0x...' },
]);
```

### 3. Handle Expiration

Check expiration before on-chain verification:

```typescript
if (new Date(proof.expiresAt) < new Date()) {
  // Regenerate proof
  proof = await prover.proveBeneficialOwnership({ ... });
}
```

---

## Support

- **Documentation**: [docs.vonbit.co](https://docs.vonbit.co)
- **API Status**: [status.vonbit.co](https://status.vonbit.co)
- **Discord**: [discord.gg/vonbit](https://discord.gg/vonbit)
- **Email**: developers@vonbit.co

---

## Next Steps

1. [Get an API key](https://vonbit.co/developers)
2. [Try the demo](https://test.vonbit.co)
3. [Read the protocol spec](docs/PROTOCOL_SPEC_v1.1.pdf)
4. [View example code](examples/)
