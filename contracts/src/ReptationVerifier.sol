// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/* ========== IMPORTS ========== */

import "./verifiers/ZKPVerifier.sol";
import "./lib/GenesisUtils.sol";
import "./ZKBadge.sol";

contract ReptationVerifier is ZKPVerifier {
    /* ========== STATE VARIABLES ========== */

    mapping(uint64 => uint256) public requestToExpireTimestamp;
    ZKBadge public badge;

    /* ========== CONSTRUCTOR ========== */

    constructor() {
        badge = ZKBadge(0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF); // TODO: set after deploy
        requestToExpireTimestamp[uint64(0)] = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff; // set max value to timestamp as default
    }

    /* ========== FUNCTIONS ========== */

    function setExpireTime(uint64 requestId, uint256 expireTimestamp) public onlyOwner {
        require(requestExist[requestId], "the given request id does not exist");
        requestToExpireTimestamp[requestId] = expireTimestamp;
    }

    function _beforeProofSubmit(uint64, uint256[] memory inputs, ICircuitValidator validator)
        internal
        override
    {
        address addr = GenesisUtils.int256ToAddress(inputs[validator.getChallengeInputIndex()]);
        require(_msgSender() == addr, "address in proof is not a sender address");
    }

    function _afterProofSubmit(uint64 requestId, uint256[] memory inputs, ICircuitValidator validator) internal override {
        address prover =_msgSender();
        require(
            requestExist[requestId] && !proofs[prover][requestId], "proof can not be submitted more than once"
        );
        require(badge.balanceOf(prover) == 1, "msg.sender does not have badge SBT");
        uint256 tokenId = badge.getOwnedToken(prover);
        badge.addReptation(prover, address(this), requestId, requestToExpireTimestamp[requestId], requestQueries[requestId]);
    }
}
