# @vonbit/vbitzk-sdk

Zero-knowledge beneficial ownership SDK for institutional crypto compliance.

## Installation

```bash
npm install @vonbit/vbitzk-sdk
```

## Quick Start

```typescript
import { VBitZKProver } from '@vonbit/vbitzk-sdk';

const prover = new VBitZKProver({
  network: 'mainnet',
  proverEndpoint: 'https://prover.vonbit.co'
});

const proof = await prover.proveBeneficialOwnership({
  wallet: '0x742d35Cc6634C0532925a3b844Bc9e7595f8a2',
  asOf: new Date()
});

console.log(proof);
// {
//   proofData: '0x1a2b3c...',
//   exposures: [...],
//   nestingDepth: 7,
//   verificationGas: 62000
// }
```

## Performance

| Metric | v1.1 |
|--------|------|
| Proof Size | 312 bytes |
| Proving Time | <180ms |
| Cost | $0.001 |
| Verify Gas | 62,000 |

## License

MIT
