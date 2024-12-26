// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract MintMockERC20Script is Script {
    uint16 private chainId_fuji = 43113;
    uint32 private chainId_arbSepolia = 421614;

    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        address recipient = vm.envAddress("RECIPIENT");
        uint256 mintAmount = 100;

        vm.startBroadcast(privateKey);

        uint chainId = getChainID();
        address tokenAAddress = vm.envAddress("TOKEN_A_ADDRESS");
        address tokenBAddress = vm.envAddress("TOKEN_B_ADDRESS");

        if (tokenAAddress == address(0) || tokenBAddress == address(0)) {
            revert("Token addresses not set in .env file");
        }

        MockERC20 tokenA = MockERC20(tokenAAddress);
        MockERC20 tokenB = MockERC20(tokenBAddress);

        console.log("Minting tokens for recipient:", recipient);
        console.log("Minting amount:", mintAmount);

        // Mint tokens for Token A
        console.log("Minting Token A...");
        tokenA.mint(recipient, mintAmount);
        console.log("Minted Token A to recipient:", recipient, "Amount:", mintAmount);

        // Mint tokens for Token B
        console.log("Minting Token B...");
        tokenB.mint(recipient, mintAmount);
        console.log("Minted Token B to recipient:", recipient, "Amount:", mintAmount);

        vm.stopBroadcast();
    }

    function getChainID() public view returns (uint256 chainID) {
        assembly {
            chainID := chainid()
        }
    }
}
