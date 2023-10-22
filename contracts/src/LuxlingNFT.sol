// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {IERC6551Registry} from "./interfaces/IERC6551Registry.sol";

contract LuxlingNFT is ERC721, Ownable {
    mapping(uint256 => string) public uris;
    uint256 public nextTokenId = 1;

    constructor() ERC721("LuxlingNFT", "LXLNG") {}

    function tokenURI(
        uint256 id
    ) public view virtual override returns (string memory) {
        require(id >= nextTokenId, "Token does not exist");
        return uris[id];
    }

    function mint(address to, string memory uri) public {
        uris[nextTokenId] = uri;
        _mint(to, nextTokenId);
        nextTokenId++;
    }
}
