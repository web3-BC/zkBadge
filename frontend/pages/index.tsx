import { QRCode } from "react-qr-svg";
import { Box } from "@mui/material";

const styles = {
  root: {
    color: "#2C1752",
    fontFamily: "sans-serif",
    textAlign: "center",
  },
  title: {
    color: "#7B3FE4",
  },
};

// update with your contract address
const deployedContractAddress = "0x44f53039FA2d6B2f397ad34aB5aff2c0828560B3";

// more info on query based requests: https://0xpolygonid.github.io/tutorials/wallet/proof-generation/types-of-auth-requests-and-proofs/#query-based-request
// qrValueProofRequestExample: https://github.com/0xPolygonID/tutorial-examples/blob/main/on-chain-verification/qrValueProofRequestExample.json
const qrProofRequestJson = {
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
        id: 1,
        circuitId: "credentialAtomicQuerySigV2OnChain",
        query: {
          allowedIssuers: ["*"],
          context:
            "https://raw.githubusercontent.com/0xPolygonID/tutorial-examples/main/credential-schema/proof-of-dao-longevity.jsonld",
          credentialSubject: {
            entryDate: {
              $lt: 20230415,
            },
          },
          type: "ProofOfDaoLongevity",
        },
      },
    ],
  },
};
export default function Home() {
  return (
    <Box sx={styles.root}>
      <h2 style={styles.title}>Claim an ERC20 zk airdrop on Polygon Mumbai</h2>
      <p>
        Age verification: You must prove your date of birth was before Jan 1,
        2001 to claim.
      </p>
      <p>
        Complete age verification by issuing yourself a Polygon ID claim via{" "}
        <a
          href="https://polygontechnology.notion.site/Issue-yourself-a-KYC-Age-Credential-claim-a06a6fe048c34115a3d22d7d1ea315ea"
          target="_blank"
        >
          KYC Age Credentials
        </a>{" "}
        then scan QR code within Polygon ID app to claim tokens
      </p>

      <Box sx={{display: "flex", justifyContent: "center"}} my={4}>
        <QRCode
          level="Q"
          style={{ width: 256 }}
          value={JSON.stringify(qrProofRequestJson)}
        />
      </Box>
      <br />
      <p>
        Github:{" "}
        <a
          href="https://github.com/oceans404/tutorial-examples/tree/main/on-chain-verification"
          target="_blank"
        >
          On-chain verification tutorial
        </a>
      </p>
      <p>
        Polygonscan:{" "}
        <a
          href={`https://mumbai.polygonscan.com/token/${deployedContractAddress}`}
          target="_blank"
        >
          Token ERC20zkAirdrop
        </a>
      </p>
    </Box>
  );
}
