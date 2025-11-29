<p align="center">
  <img src="assets/VonBit-Logo.png" alt="vBitZK" width="120" />
</p>

<h1 align="center">vBitZK</h1>

<p align="center">
  <strong>Zero-Knowledge Beneficial Ownership Proofs for the Tokenized Economy</strong>
</p>

<p align="center">
  <a href="https://vonbit.co/spec/v1.1.pdf">Protocol Spec</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#why-vbitzk">Why vBitZK</a> •
  <a href="https://test.vonbit.co">Live Demo</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.1.0-blue" alt="Version" />
  <img src="https://img.shields.io/badge/proof_size-312_bytes-green" alt="Proof Size" />
  <img src="https://img.shields.io/badge/proving_time-<180ms-green" alt="Proving Time" />
  <img src="https://img.shields.io/badge/cost-$0.001-green" alt="Cost" />
  <img src="https://img.shields.io/badge/chains-8-purple" alt="Chains" />
  <img src="https://img.shields.io/badge/license-MIT-lightgrey" alt="License" />
</p>

---

## The Problem

**Nobody knows who owns what in DeFi.**

When assets flow through Aave → Pendle → EigenLayer → Kelp, the original beneficial owner becomes invisible. A $426K position can nest through 32 layers of smart contracts, making compliance impossible.

Regulators are coming:
- **CTA (USA)**: Jan 1, 2026 — $500/day penalties
- **MiCA (EU)**: Q2 2026 — €5M fines
- **TAFR**: Enhanced AML requirements

$30T in institutional capital is waiting on the sidelines. They can't deploy without knowing who ultimately controls tokenized assets.

---

## The Solution

**vBitZK proves beneficial ownership through recursive ZK proofs.**

```
Wallet → weETH → Pendle PT → EigenLayer → Kelp DAO
                    ↓
        One 312-byte ZK proof
                    ↓
    "0x742d...f8a2 controls 165.5 ETH (79.2%)"
```

No data leaks. No trust assumptions. Verifiable on-chain in 62k gas.

---

## Performance

| Metric | v1.1 |
|--------|------|
| **Proof Size** | 312 bytes |
| **Proving Time** | <180ms |
| **Verification Gas** | 62,000 |
| **Cost per Proof** | $0.001 |
| **Max Nesting Depth** | 32 layers |
| **Protocol Coverage** | 87% TVL |

---

## Quick Start

### TypeScript SDK

```bash
npm install @vonbit/vbitzk-sdk
```

```typescript
import { VBitZKProver } from '@vonbit/vbitzk-sdk';

const prover = new VBitZKProver({
  network: 'mainnet',
  proverEndpoint: 'https://prover.vonbit.co'
});

// Generate beneficial ownership proof
const proof = await prover.proveBeneficialOwnership({
  wallet: '0x742d35Cc6634C0532925a3b844Bc9e7595f8a2',
  asOf: new Date()
});

console.log(proof);
// {
//   proofData: '0x1a2b3c...',
//   exposures: [
//     { asset: 'ETH', amount: '165.5', percentage: 79.2 },
//     { asset: 'USDC', amount: '88420', percentage: 20.8 }
//   ],
//   nestingDepth: 7,
//   protocolsTraversed: ['Aave', 'Pendle', 'EigenLayer', 'Kelp'],
//   verificationGas: 62000
// }

// Verify on-chain
const isValid = await prover.verifyOnChain(proof, '0xVerifierAddress');
```

### Rust Crate

```bash
cargo add vbitzk-prover
```

```rust
use vbitzk_prover::{Prover, ProofRequest};

let prover = Prover::new(Config::mainnet())?;

let proof = prover.prove_beneficial_ownership(ProofRequest {
    wallet: "0x742d35Cc6634C0532925a3b844Bc9e7595f8a2".parse()?,
    as_of: Utc::now(),
    max_depth: 32,
})?;

println!("Proof: {} bytes", proof.data.len()); // 312 bytes
```

### On-Chain Verification

```solidity
import {IVBitZKVerifier} from "@vonbit/contracts/IVBitZKVerifier.sol";

contract ComplianceChecker {
    IVBitZKVerifier public verifier;
    
    function checkBeneficialOwner(
        bytes calldata proof,
        address wallet
    ) external view returns (bool) {
        return verifier.verify(proof, wallet);
    }
}
```

---

## Protocol Adapters

vBitZK recursively unwraps positions across 23 DeFi protocols:

| Category | Protocols | TVL Coverage |
|----------|-----------|--------------|
| **Lending** | Aave, Compound, Morpho, Spark | 34% |
| **LSDs** | Lido, Rocket Pool, Frax, Coinbase | 28% |
| **Restaking** | EigenLayer, Kelp, Ether.fi, Renzo | 15% |
| **Yield** | Pendle, Yearn, Convex | 8% |
| **DEX LPs** | Uniswap, Curve, Balancer | 12% |

**Total: 87% of DeFi TVL covered**

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     vBitZK Stack                        │
├─────────────────────────────────────────────────────────┤
│  Client SDK (TypeScript/Rust)                           │
│    └── Wallet input, proof request                      │
├─────────────────────────────────────────────────────────┤
│  Prover Network (Cysic Decentralized)                   │
│    └── Halo2 circuit, Nova folding                      │
│    └── 312-byte proof output                            │
├─────────────────────────────────────────────────────────┤
│  Protocol Adapters                                      │
│    └── 23 adapters for position unwrapping              │
│    └── Recursive ownership resolution                   │
├─────────────────────────────────────────────────────────┤
│  On-Chain Verifier (Ivy-1)                              │
│    └── 62k gas verification                             │
│    └── Live on 8 chains                                 │
└─────────────────────────────────────────────────────────┘
```

---

## Supported Chains

| Chain | Verifier Address | Status |
|-------|------------------|--------|
| Ethereum | `0x...` | ✅ Live |
| Base | `0x...` | ✅ Live |
| Arbitrum | `0x...` | ✅ Live |
| Optimism | `0x...` | ✅ Live |
| Polygon | `0x...` | ✅ Live |
| Avalanche | `0x...` | ✅ Live |
| BSC | `0x...` | ✅ Live |
| Solana | `...` | 🔜 Q1 2026 |

---

## Use Cases

### For Funds

```typescript
// Generate compliance report
const report = await prover.generateSAR({
  wallet: fundWallet,
  format: 'FinCEN',
  period: { start: '2025-01-01', end: '2025-12-31' }
});
// → Machine-readable SAR/CTR for regulators
```

### For Protocols

```solidity
// Gate access based on beneficial ownership
modifier onlyCompliant(bytes calldata boProof) {
    require(verifier.verify(boProof, msg.sender), "BO proof required");
    _;
}
```

### For Regulators

```typescript
// Verify beneficial ownership without accessing private data
const verification = await verifier.verifyProof(proof);
// → { valid: true, wallet: '0x...', timestamp: '2025-11-29T...' }
// No PII exposed, cryptographic guarantee of control
```

---

## Comparison

| Feature | vBitZK | Chainalysis | TRM | Arkham |
|---------|--------|-------------|-----|--------|
| DeFi Nesting Depth | 32 layers | 1-2 layers | 1-2 layers | 1-2 layers |
| Privacy Preserving | ✅ ZK | ❌ | ❌ | ❌ |
| On-Chain Verifiable | ✅ 62k gas | ❌ | ❌ | ❌ |
| Decentralized | ✅ Cysic | ❌ | ❌ | ❌ |
| Beneficial Ownership | ✅ Native | ❌ | ❌ | ❌ |
| Cost per Query | $0.001 | $$$$ | $$$$ | $$$$ |

**vBitZK is infrastructure. They are analytics.**

---

## Documentation

| Document | Description |
|----------|-------------|
| [Protocol Specification v1.1](docs/PROTOCOL_SPEC_v1.1.pdf) | Complete technical specification |
| [Integration Guide](docs/INTEGRATION_GUIDE.md) | Step-by-step integration |

---

## Roadmap

| Milestone | Status |
|-----------|--------|
| v1.0 — Core BO proofs | ✅ Shipped |
| v1.1 — 10x performance, Cysic integration | ✅ Shipped |
| v1.2 — Solana support | 🔜 Q1 2026 |
| v1.3 — zkML risk primitives | 🔜 Q2 2026 |
| v2.0 — Cross-chain BO aggregation | 🔜 Q3 2026 |

---

## Community

- **Website**: [vonbit.co](https://vonbit.co)
- **Demo**: [test.vonbit.co](https://test.vonbit.co)
- **Twitter**: [@VonBit_ai](https://twitter.com/VonBit_ai)
- **Spec PDF**: [v1.1 Protocol Specification](https://vonbit.co/spec/v1.1.pdf)

---

## Security

vBitZK proofs are:

- **Sound** — Cannot forge proof of ownership you don't have
- **Zero-Knowledge** — No private data revealed
- **Succinct** — 312 bytes regardless of nesting depth
- **Non-Interactive** — Generate once, verify anywhere

Audit status: In progress with [TBD]

---

## License

MIT License — see [LICENSE](LICENSE)

---

<p align="center">
  <strong>The compliance primitive for the $100T tokenized economy.</strong>
</p>

<p align="center">
  <sub>Built by <a href="https://vonartis.com">Vonartis Foundation</a></sub>
</p>
