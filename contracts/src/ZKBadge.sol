// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/* ========== IMPORTS ========== */
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "./interfaces/IERC5192.sol";
import "./interfaces/ICircuitValidator.sol";

contract ZKBadge is ERC721, IERC5192, Ownable {
    /* ========== STATE VARIABLES ========== */

    struct Reptation {
        address verifier;
        uint64 requestId;
        uint256 expireTimestamp;
        ICircuitValidator.CircuitQuery query;
    }

    using Strings for uint256;

    bool private isLocked = true;
    uint256 private _counter;

    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) private _ownedToken;
    mapping(uint256 => Reptation[]) private _tokenToReptations;

    error ErrLocked();
    error ErrNotFound();

    modifier checkLock() {
        if (isLocked) revert ErrLocked();
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor() ERC721("ZKBadge", "ZKB") {}
    // MEMO: ERC1155の方が視覚的にわかりやすいかも？？
    // 各プロジェクト(issuer)がsetZKPRequestと一緒に自分達のSBTを発行するイメージ
    // その場合、コントラクトを一つにまとめた方が良さそう（expire期限をいつでも変更できるようになるし）

    /* ========== VIEW FUNCTIONS ========== */

    function totalSupply() public view returns (uint256) {
        return _counter;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC5192).interfaceId || super.supportsInterface(interfaceId);
    }

    function locked(uint256 tokenId) external view returns (bool) {
        if (!_exists(tokenId)) revert ErrNotFound();
        return isLocked;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function getOwnedToken(address owner) public view returns (uint256) {
        return _ownedToken[owner];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override checkLock {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override checkLock {
        super.safeTransferFrom(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override checkLock {
        super.transferFrom(from, to, tokenId);
    }

    function approve(address approved, uint256 tokenId) public override checkLock {
        super.approve(approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public override checkLock {
        super.setApprovalForAll(operator, approved);
    }

    function mint(address to, string memory _tokenURI) public onlyOwner returns (uint256) {
        uint256 tokenId = ++_counter;
        _mint(to, tokenId);
        _tokenURIs[tokenId] = _tokenURI;
        _ownedToken[to] = tokenId;

        if (isLocked) emit Locked(tokenId);

        return tokenId;
    }

    function addReptation(address owner, address verifier_, uint64 requestId_, uint256 expireTimestamp_, ICircuitValidator.CircuitQuery memory query_) external {
        require(_msgSender() == verifier_, "the given verifier address does not match msg.sender");
        uint256 _tokenId = getOwnedToken(owner);
        Reptation memory newReptation = Reptation({
            verifier: verifier_,
            requestId: requestId_,
            expireTimestamp: expireTimestamp_,
            query: query_
        });
        _tokenToReptations[_tokenId].push(newReptation);
        emit ReptationAdded(_tokenId, verifier_, requestId_, expireTimestamp_, query_);
    }

    /* ========== EVENTS ========== */

    event ReptationAdded(uint256 indexed _tokenId, address _verifier, uint64 _requestId, uint256 _expireTimestamp, ICircuitValidator.CircuitQuery  _query);

}
