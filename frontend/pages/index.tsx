import { QRCode } from "react-qr-svg";
import { Box, Typography } from "@mui/material";
import Image from "next/image";
import {
  qrTwitterProofRequestJson,
  qrInstagramProofRequestJson,
} from "../config";

export default function Home() {
  return (
    <Box textAlign={"center"} p={4} height={"100vh"}>
      <Typography variant="h2">Claim our zkBudges!</Typography>

      <Box display={"flex"} justifyContent={"center"} my={4}>
        <Box mr={5}>
          <Box display={"flex"} justifyContent={"center"}>
            <Image width={50} height={50} src="/twitterLogo.png" alt="" />
          </Box>
          <Typography variant="body1" my={3}>
            you must have more than 40 twitter followers !
          </Typography>
          <Box display={"flex"} justifyContent={"center"}>
            <QRCode
              level="Q"
              style={{ width: 256 }}
              value={JSON.stringify(qrTwitterProofRequestJson)}
            />
          </Box>
        </Box>
        <Box>
          <Box display={"flex"} justifyContent={"center"}>
            <Image
              width={50}
              height={50}
              src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Instagram_logo_2022.svg/1024px-Instagram_logo_2022.svg.png"
              alt=""
            />
          </Box>
          <Typography variant="body1" my={3}>
            you must have more than 30 instagram followers !
          </Typography>
          <Box display={"flex"} justifyContent={"center"}>
            <QRCode
              level="Q"
              style={{ width: 256 }}
              value={JSON.stringify(qrInstagramProofRequestJson)}
            />
          </Box>
        </Box>
      </Box>
    </Box>
  );
}
