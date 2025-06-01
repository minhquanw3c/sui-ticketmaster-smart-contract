// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TicketMaster} from "./../src/TicketMaster.sol";

contract DeployTicketMaster is Script {
    function run() external returns (TicketMaster) {
        vm.startBroadcast();
        TicketMaster ticketMasterContract = new TicketMaster();
        vm.stopBroadcast();

        return ticketMasterContract;
    }
}
