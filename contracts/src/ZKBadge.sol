// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/* ========== IMPORTS ========== */
import "../lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "./interfaces/IERC5192.sol";
import "./interfaces/ICircuitValidator.sol";
import "./verifiers/ZKPVerifier.sol";
import "./lib/GenesisUtils.sol";

contract ZKBadge is ERC1155URIStorage, IERC5192, ZKPVerifier {
    /* ========== STATE VARIABLES ========== */

    struct Reptation {
        uint64 requestId;
        address issuer;
        uint256 expireTimestamp;
        ICircuitValidator.CircuitQuery query;
    }

    using Strings for uint256;

    bool private isLocked = true;
    uint256 private _tokenId;
    uint64 constant MAX_UINT64 = 2**64 - 1;
    mapping(uint256 => Reptation) private _tokenToReptation;

    error ErrLocked();
    error ErrNotFound();

    modifier checkLock() {
        if (isLocked) revert ErrLocked();
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor() ERC1155("") {}

    /* ========== VIEW FUNCTIONS ========== */

    function totalSupply() public view returns (uint256) {
        return _tokenId;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC5192).interfaceId || super.supportsInterface(interfaceId);
    }

    function locked(uint256 tokenId) external view returns (bool) {
        if (tokenId > _tokenId) revert ErrNotFound();
        return isLocked;
    }

    function tokenReptationData(uint256 id) public view returns (Reptation memory reptation) {
        return _tokenToReptation[id];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data)
        public
        override
        checkLock
    {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override checkLock {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function setApprovalForAll(address operator, bool approved) public override checkLock {
        super.setApprovalForAll(operator, approved);
    }

    function convertUint256ToUint64(uint256 value) public pure returns (uint64) {
        require(value <= MAX_UINT64, "Value too large to fit in uint64");
        return uint64(value);
    }

    function initBadge(
        ICircuitValidator _validator,
        ICircuitValidator.CircuitQuery memory _query,
        uint256 _expireTimestamp,
        string memory _tokenURI
    ) public {
        // minted token id is equal to requestId
        uint256 _requestId = _tokenId + 1;
        this.setZKPRequest(convertUint256ToUint64(_requestId), _validator, _query.schema, _query.claimPathKey, _query.operator, _query.value);
        _mint(address(this), _requestId, 1, "");
        _setURI(_requestId, _tokenURI);
        _tokenToReptation[_requestId] = Reptation({requestId: convertUint256ToUint64(_requestId), issuer: _msgSender(), expireTimestamp: _expireTimestamp, query: _query});
        emit InitBadge(convertUint256ToUint64(_requestId), _expireTimestamp, _query);
    }

    function _beforeProofSubmit(uint64, /*requestId*/ uint256[] memory inputs, ICircuitValidator validator)
        internal
        view
        override
    {
        address addr = GenesisUtils.int256ToAddress(inputs[validator.getChallengeInputIndex()]);
        require(_msgSender() == addr, "address in proof is not a sender address");
    }

    function _afterProofSubmit(uint64 requestId, uint256[] memory inputs, ICircuitValidator validator)
        internal
        override
    {
        address prover = _msgSender();
        uint tokenId_ = uint256(requestId);
        require(tokenId_ <= _tokenId, "the given request id does not exist");
        require(!proofs[prover][requestId], "proof can not be submitted more than once");
        _mint(prover, tokenId_, 1, "");
        emit MintBadge(tokenId_, prover);
        if (isLocked) emit Locked(tokenId_);
    }

    /* ========== EVENTS ========== */

    event InitBadge(uint256 indexed _tokenId, uint256 _expireTimestamp, ICircuitValidator.CircuitQuery _query);

    event MintBadge(uint256 indexed _tokenId, address indexed _to);
}
