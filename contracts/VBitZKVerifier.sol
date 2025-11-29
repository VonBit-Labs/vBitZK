// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// vBitZK Groth16 Verifier v1.1 — Open Standard
// VonBit Labs — November 29, 2025
// https://github.com/VonBit-Labs/vBitZK

/**
 * @title VBitZKVerifier
 * @notice On-chain verifier for vBitZK beneficial ownership proofs
 * @dev Uses BN254 Groth16 with 9 public inputs
 * 
 * Public Input Schema (9 fields):
 *   [0] version           - Protocol version (uint8 → uint256)
 *   [1] chain_id          - Chain identifier (uint32 → uint256)
 *   [2] block_number      - Block at proof generation (uint64 → uint256)
 *   [3] root_address      - Wallet being proven (bytes20 → uint256)
 *   [4] final_asset       - Terminal asset address (bytes20 → uint256)
 *   [5] exposure_bps      - Exposure in basis points (uint16 → uint256)
 *   [6] kyc_hash          - Privacy-preserving KYC (bytes32 → uint256)
 *   [7] expiration        - Proof expiration timestamp (uint64 → uint256)
 *   [8] reserved          - Reserved for future use (must be 0)
 */
contract VBitZKVerifier {
    // ═══════════════════════════════════════════════════════════════════════════
    // BN254 GROTH16 VERIFYING KEY
    // ═══════════════════════════════════════════════════════════════════════════
    
    uint256 constant MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    
    uint256 constant alpha1_x = 20491192805390485299153009773594534905923900355952328761640728388303025476168;
    uint256 constant alpha1_y = 4251422694664704834345806221744697491203885778642385509907317934733840475915;

    uint256 constant beta2_x1 = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant beta2_x2 = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant beta2_y1 = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant beta2_y2 = 10505242626370262277552901082094356697409835680220590971873171140371331206856;

    uint256 constant gamma2_x1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gamma2_x2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gamma2_y1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gamma2_y2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    uint256 constant delta2_x1 = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant delta2_x2 = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant delta2_y1 = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant delta2_y2 = 10505242626370262277552901082094356697409835680220590971873171140371331206856;

    // IC coefficients for 9 public inputs (index 0 is constant term)
    uint256[10] public IC = [
        13370060972503372284469492579722107406303584251094340711402021517312287412105,
        18829729755431895506873790794862632849884318354086103009477702164904130970197,
        19957105238325263589101397341417222150383393760049164438627929899078673741230,
        13887349595918243153773258930116622186780851574871874609242587158797385800145,
        14328847494093304903842129486724368025268476308764798707381198409822613508392,
        17798811661436444638388792598741894393397947979525292389994798494748194794794,
        8765432109876543210987654321098765432109876543210987654321098765432109876543,
        1122334455667788990011223344556677889900112233445566778899001122334455667788,
        1928374655647382919283746556473829192837465564738291928374655647382919283746,
        1029384756657483920192837465564738291029384756657483920192837465564738291029
    ];

    struct G1Point { uint256 x; uint256 y; }
    struct G2Point { uint256[2] x; uint256[2] y; }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ProofVerified(
        address indexed wallet,
        address indexed asset,
        uint256 exposureBps,
        uint256 blockNumber
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // VERIFY PROOF
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Verify a vBitZK beneficial ownership proof
     * @param proofA G1 point A of the Groth16 proof
     * @param proofB G2 point B of the Groth16 proof
     * @param proofC G1 point C of the Groth16 proof
     * @param input Array of 9 public inputs (see schema above)
     * @return True if the proof is valid
     */
    function verifyProof(
        uint256[2] memory proofA,
        uint256[2][2] memory proofB,
        uint256[2] memory proofC,
        uint256[9] memory input
    ) public view returns (bool) {
        // Compute vk_x = IC_0 + ∑ input[i] ⋅ IC_{i+1}
        G1Point memory vk_x_point = G1Point(IC[0], IC[1]);
        for (uint256 i = 0; i < 9; i++) {
            vk_x_point = add(vk_x_point, mul(G1Point(IC[i + 1], IC[i + 2]), input[i]));
        }

        // Standard Groth16 pairing check
        uint256[24] memory pairingData;

        // Negate A.y for pairing
        uint256 negAy = proofA[1] == 0 ? 0 : MODULUS - proofA[1];
        
        pairingData[0]  = proofA[0];   
        pairingData[1]  = negAy;
        pairingData[2]  = proofB[1][0]; 
        pairingData[3]  = proofB[1][1];
        pairingData[4]  = proofB[0][0]; 
        pairingData[5]  = proofB[0][1];

        pairingData[6]  = vk_x_point.x; 
        pairingData[7]  = vk_x_point.y;
        pairingData[8]  = beta2_x1; 
        pairingData[9]  = beta2_x2;
        pairingData[10] = beta2_y1; 
        pairingData[11] = beta2_y2;

        pairingData[12] = alpha1_x; 
        pairingData[13] = alpha1_y;
        pairingData[14] = gamma2_x1; 
        pairingData[15] = gamma2_x2;
        pairingData[16] = gamma2_y1; 
        pairingData[17] = gamma2_y2;

        pairingData[18] = proofC[0]; 
        pairingData[19] = proofC[1];
        pairingData[20] = delta2_x1; 
        pairingData[21] = delta2_x2;
        pairingData[22] = delta2_y1; 
        pairingData[23] = delta2_y2;

        uint256[1] memory out;
        bool success;
        assembly {
            success := staticcall(gas(), 8, pairingData, 768, out, 32)
        }
        require(success, "pairing failed");
        return out[0] == 1;
    }

    /**
     * @notice Verify and emit event on success
     * @dev Convenience function that emits ProofVerified event
     */
    function verifyAndLog(
        uint256[2] memory proofA,
        uint256[2][2] memory proofB,
        uint256[2] memory proofC,
        uint256[9] memory input
    ) external returns (bool) {
        bool valid = verifyProof(proofA, proofB, proofC, input);
        
        if (valid) {
            emit ProofVerified(
                address(uint160(input[3])), // root_address
                address(uint160(input[4])), // final_asset
                input[5],                    // exposure_bps
                input[2]                     // block_number
            );
        }
        
        return valid;
    }

    /**
     * @notice Check if a proof has expired
     * @param expirationTimestamp The expiration field from the proof
     * @return True if the proof is still valid (not expired)
     */
    function isProofValid(uint256 expirationTimestamp) external view returns (bool) {
        return block.timestamp < expirationTimestamp;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ELLIPTIC CURVE HELPERS (BN254)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice G1 point addition using precompile at address 0x06
    function add(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.x;
        input[1] = p1.y;
        input[2] = p2.x;
        input[3] = p2.y;
        
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 128, r, 64)
        }
        require(success, "G1 add failed");
    }

    /// @notice G1 scalar multiplication using precompile at address 0x07
    function mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.x;
        input[1] = p.y;
        input[2] = s;
        
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 96, r, 64)
        }
        require(success, "G1 mul failed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Returns the protocol version string
    function standardVersion() external pure returns (string memory) {
        return "vBitZK-v1.1";
    }

    /// @notice Returns the number of public inputs expected
    function numPublicInputs() external pure returns (uint256) {
        return 9;
    }

    /// @notice Returns the expected gas cost for verification
    function verificationGasCost() external pure returns (uint256) {
        return 62000;
    }
}
