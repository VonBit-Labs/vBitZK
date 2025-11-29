/**
 * vBitZK Basic Example
 * 
 * This example demonstrates how to:
 * 1. Generate a beneficial ownership proof
 * 2. Verify the proof locally
 * 3. Verify the proof on-chain
 */

import { VBitZKProver } from '@vonbit/vbitzk-sdk';
import { ethers } from 'ethers';

// Example wallet with nested DeFi positions
const EXAMPLE_WALLET = '0x742d35Cc6634C0532925a3b844Bc9e7595f8a2';

async function main() {
  console.log('🔐 vBitZK Basic Example\n');
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. INITIALIZE PROVER
  // ═══════════════════════════════════════════════════════════════════════════
  
  const prover = new VBitZKProver({
    apiKey: process.env.VONBIT_API_KEY || 'demo-key',
    network: 'mainnet',
    proverEndpoint: 'https://prover.vonbit.co'
  });
  
  console.log('✅ Prover initialized\n');
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 2. GENERATE BENEFICIAL OWNERSHIP PROOF
  // ═══════════════════════════════════════════════════════════════════════════
  
  console.log(`📊 Generating proof for ${EXAMPLE_WALLET}...`);
  
  const proof = await prover.proveBeneficialOwnership({
    wallet: EXAMPLE_WALLET,
    asOf: new Date(),
    maxDepth: 32
  });
  
  console.log('\n✅ Proof generated!\n');
  console.log('━'.repeat(60));
  console.log(`Proof size:        ${proof.proofData.length / 2 - 1} bytes`);
  console.log(`Nesting depth:     ${proof.nestingDepth} layers`);
  console.log(`Protocols:         ${proof.protocolsTraversed.join(' → ')}`);
  console.log(`Verification gas:  ${proof.verificationGas.toLocaleString()}`);
  console.log(`Expires:           ${proof.expiresAt}`);
  console.log('━'.repeat(60));
  
  console.log('\n📈 Terminal Asset Exposures:\n');
  for (const exposure of proof.exposures) {
    const bar = '█'.repeat(Math.floor(exposure.percentage / 5));
    console.log(`  ${exposure.asset.padEnd(6)} ${bar} ${exposure.percentage.toFixed(1)}% (${exposure.amount})`);
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 3. VERIFY LOCALLY
  // ═══════════════════════════════════════════════════════════════════════════
  
  console.log('\n🔍 Verifying proof locally...');
  
  const localVerification = await prover.verifyLocal(proof);
  console.log(`✅ Local verification: ${localVerification ? 'VALID' : 'INVALID'}`);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 4. VERIFY ON-CHAIN (Optional - requires RPC)
  // ═══════════════════════════════════════════════════════════════════════════
  
  if (process.env.RPC_URL) {
    console.log('\n⛓️ Verifying proof on-chain...');
    
    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
    const onChainVerification = await prover.verifyOnChain(proof, provider);
    
    console.log(`✅ On-chain verification: ${onChainVerification ? 'VALID' : 'INVALID'}`);
  } else {
    console.log('\n💡 Set RPC_URL environment variable for on-chain verification');
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 5. EXPORT PROOF
  // ═══════════════════════════════════════════════════════════════════════════
  
  console.log('\n📦 Proof data (for on-chain submission):\n');
  console.log(JSON.stringify({
    proofData: proof.proofData,
    wallet: proof.wallet,
    expiresAt: proof.expiresAt
  }, null, 2));
}

main().catch(console.error);
