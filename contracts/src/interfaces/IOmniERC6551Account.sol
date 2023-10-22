// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC6551Account} from "./IERC6551Account.sol";

interface IOmniERC6551Account is IERC6551Account {
    function callRemote(
        string calldata destinationChain,
        address to,
        uint256 value,
        bytes calldata data
    ) external payable;
}
