// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AxelarExecutable} from "axelar-gmp/executable/AxelarExecutable.sol";
import {IAxelarGasService} from "axelar-gmp/interfaces/IAxelarGasService.sol";
import {IAxelarGateway} from "axelar-gmp/interfaces/IAxelarGateway.sol";
import {StringToAddress, AddressToString} from "axelar-gmp/libs/AddressString.sol";

import "openzeppelin-contracts/utils/introspection/IERC165.sol";
import "openzeppelin-contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/interfaces/IERC1271.sol";
import "openzeppelin-contracts/utils/cryptography/SignatureChecker.sol";

import "./interfaces/IOmniERC6551Account.sol";
import "./lib/ERC6551AccountLib.sol";

contract OmniERC6551Account is
    IERC165,
    IERC1271,
    IOmniERC6551Account,
    AxelarExecutable
{
    using StringToAddress for string;
    using AddressToString for address;
    event FalseSender(string sourceChain, string sourceAddress);

    uint256 public nonce;
    IAxelarGasService public immutable gasService;

    receive() external payable {}

    constructor(
        address gateway_,
        address gasReceiver_
    ) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
    }

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result) {
        require(msg.sender == owner(), "Not token owner");

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }

        emit TransactionExecuted(to, value, data);
        nonce++;
    }

    // Forwards a call to the TBA on another chain
    // Assumes the TBA exists on destinationChain
    function callRemote(
        string calldata destinationChain,
        address to,
        uint256 value,
        bytes calldata data
    ) external payable {
        require(msg.sender == owner(), "Not token owner");
        require(msg.value > 0, "Gas payment required"); // TODO: account for gas payment + contract call value

        string memory stringAddress = address(this).toString();
        bytes memory payload = abi.encode(to, value, data);

        gasService.payNativeGasForContractCall{value: msg.value}(
            address(this),
            destinationChain,
            stringAddress,
            payload,
            msg.sender
        );
        gateway.callContract(destinationChain, stringAddress, payload);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        if (sourceAddress.toAddress() != address(this)) {
            emit FalseSender(sourceChain, sourceAddress);
            return;
        }

        address to;
        uint256 value;
        bytes memory data;
        (to, value, data) = abi.decode(payload, (address, uint256, bytes));

        bytes memory result;
        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }

        emit TransactionExecuted(to, value, data);
        nonce++;
    }

    function token() external view returns (uint256, address, uint256) {
        return ERC6551AccountLib.token();
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = this
            .token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return (interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC6551Account).interfaceId);
    }

    function isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) external view returns (bytes4 magicValue) {
        bool isValid = SignatureChecker.isValidSignatureNow(
            owner(),
            hash,
            signature
        );

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }
}
