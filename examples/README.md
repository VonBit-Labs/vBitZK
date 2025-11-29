# Examples

## Basic Proof Generation

```bash
# Install dependencies
npm install @vonbit/vbitzk-sdk ethers

# Set API key
export VONBIT_API_KEY=your_api_key

# Run example
npx ts-node basic-proof.ts
```

## Expected Output

```
🔐 vBitZK Basic Example

✅ Prover initialized

📊 Generating proof for 0x742d35Cc6634C0532925a3b844Bc9e7595f8a2...

✅ Proof generated!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Proof size:        312 bytes
Nesting depth:     7 layers
Protocols:         Aave → Pendle → EigenLayer → Kelp
Verification gas:  62,000
Expires:           2026-02-27T14:30:00Z
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 Terminal Asset Exposures:

  ETH    ████████████████ 79.2% (165.5)
  USDC   ████ 20.8% (88420)

🔍 Verifying proof locally...
✅ Local verification: VALID
```

## More Examples

- [Batch Proofs](batch-proofs.ts) — Generate proofs for multiple wallets
- [Compliance Report](compliance-report.ts) — Generate SAR/CTR reports
- [Smart Contract](smart-contract/) — Integrate with Solidity
