import { Box, Button } from "@mui/material";
import Web3 from "web3";
import { ZkBadgeContract } from "../utils";

declare global {
  interface Window {
    ethereum: any;
  }
}

export default function Test() {
  const onClick = async () => {
    const web3 = new Web3(window.ethereum);
    console.log((await web3.eth.getAccounts())[0]);
    const contract = new ZkBadgeContract(
      web3,
      "0xD790a21c69797f46AC178503A096C725ed4a9ae0"
    );

    const result = await contract.initBadge();
    console.log(result);
  };

  return (
    <Box height={"100vh"}>
      <Box display={"flex"} justifyContent={"center"} p="4">
        <Button color="primary" variant="contained" onClick={onClick}>
          init Budge !
        </Button>
      </Box>
    </Box>
  );
}
