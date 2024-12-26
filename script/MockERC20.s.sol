// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract MockERC20Script is Script {
    // Configurations for different chains
    uint16 private chainId_fuji = 43113;
    uint32 private chainId_arbSepolia = 421614;

    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        uint chainId = getChainID();
        MockERC20 tokenA;
        MockERC20 tokenB;

        if (chainId == chainId_arbSepolia) {
            // Deploy MockERC20 on Arbitrum Sepolia
            tokenA = deployMockERC20(
                "Mock Token ArbSepolia",
                "MOCKA",
                18
            );
            console.log("MockERC20 deployed on ArbSepolia at:", address(tokenA));

            tokenB = deployMockERC20(
                "Mock Token B",
                "MOCKB",
                18
            );
            console.log("MockERC20 deployed on ArbSepolia at:", address(tokenB));
        }
        else if (chainId == chainId_fuji) {
            // Deploy MockERC20 on Fuji
            tokenA = deployMockERC20(
                "Mock Token Fuji",
                "MOCKF",
                18
            );
            console.log("MockERC20 deployed on Fuji at:", address(tokenA));

                tokenB = deployMockERC20(
                "Mock Token B",
                "MOCKB",
                18
            );
            console.log("MockERC20 deployed on Fuji at:", address(tokenB));
        }
        else {
            revert("Invalid Chain");
        }

        vm.stopBroadcast();
    }

    function getChainID() public view returns (uint256 chainID) {
        assembly {
            chainID := chainid()
        }
    }
    
    function deployMockERC20(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal returns (MockERC20) {
        MockERC20 token = new MockERC20(name, symbol, decimals);
        console.log("MockERC20 deployed with name:", name);
        console.log("MockERC20 deployed with symbol:", symbol);
        console.log("MockERC20 deployed with decimals:", decimals);
        return token;
    }
}
