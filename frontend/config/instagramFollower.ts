const instagramFollowerContext =
  "https://raw.githubusercontent.com/web3-BC/zkBadge/main/schemas/proof-of-instagram-follower/proof-of-instagram-follower.jsonld";

const deployedContractAddress = "0x2feC2760E3C520D8f0024998779DF9Af8fAFa4a4";

export const qrInstagramProofRequestJson = {
  id: "7f38a193-0918-4a48-9fac-36adfdb8b542",
  typ: "application/iden3comm-plain-json",
  type: "https://iden3-communication.io/proofs/1.0/contract-invoke-request",
  thid: "7f38a193-0918-4a48-9fac-36adfdb8b542",
  body: {
    reason: "airdrop participation",
    transaction_data: {
      contract_address: deployedContractAddress,
      method_id: "b68967e2",
      chain_id: 80001,
      network: "polygon-mumbai",
    },
    scope: [
      {
        id: 3,
        circuitId: "credentialAtomicQuerySigV2OnChain",
        query: {
          allowedIssuers: ["*"],
          context: instagramFollowerContext,
          credentialSubject: {
            followerNumber: {
              $gt: 30,
            },
          },
          type: "ProofOfInstagramFollower",
        },
      },
    ],
  },
};
