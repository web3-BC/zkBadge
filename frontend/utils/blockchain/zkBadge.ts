import Web3 from "web3";
import { Contract } from "web3-eth-contract";
import { AbiItem } from "web3-utils";
import zkBudgeAbi from "./zkBadge.abi.json";

const Operators = {
  NOOP: 0, // No operation, skip query verification in circuit
  EQ: 1, // equal
  LT: 2, // less than
  GT: 3, // greater than
  IN: 4, // in
  NIN: 5, // not in
  NE: 6, // not equal
};

export class ZkBadgeContract {
  private contract: Contract;
  private web3: Web3;

  constructor(web3: Web3, address: string) {
    this.web3 = web3;
    this.contract = new web3.eth.Contract(zkBudgeAbi as AbiItem[], address);
  }

  async initBadge() {
    const myAddress = (await this.web3.eth.getAccounts())[0];
    // twitter
    const schemaBigInt = "219882141702273976456222131777881875963";
    const schemaClaimPathKey =
      "103081303023551618326205634827915170763119089898481916474257929748740453143";

    // instagram
    //const schemaBigInt = "197574806230583209203612988838897896729"
    //const schemaClaimPathKey = "3786517441489641419997514295353400176264111636791018231547659999429101382318"

    const query = {
      schema: schemaBigInt,
      claimPathKey: schemaClaimPathKey,
      operator: Operators.GT, // operator
      value: [30, ...new Array(63).fill(0).map((i) => 0)],
    };

    const validatorAddress = "0xF2D4Eeb4d455fb673104902282Ce68B9ce4Ac450";
    //const validatorAddress = "0x3DcAe4c8d94359D31e4C89D7F2b944859408C618";
    return await this.contract.methods
      .initBadge(
        validatorAddress,
        query.schema,
        query.claimPathKey,
        query.operator,
        query.value,
        1684133863,
        "https://bafkreib7ruprcdsvwvfld7ftirogoewj2vp7wbnepv57flqoucvghhfdou.ipfs.nftstorage.link/"
      )
      .send({ from: myAddress });
  }
}
