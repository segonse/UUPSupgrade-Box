// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {Test} from "forge-std/Test.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox deployer;
    UpgradeBox upgrader;
    address proxy;
    BoxV1 boxV1;
    BoxV2 boxV2;

    function setUp() external {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployer.run();
        boxV1 = BoxV1(proxy);
        vm.startBroadcast();
        boxV2 = new BoxV2();
        vm.stopBroadcast();
    }

    function testVersionIsReturnOneWhenFirstDeployed() public {
        assertEq(boxV1.version(), 1);
    }

    function testProxyStatAsBoxV1() public {
        vm.expectRevert();
        BoxV2(proxy).setNumber(7);
    }

    function testUpgrades() public {
        upgrader.upgradeBox(proxy, address(boxV2));
        assertEq(BoxV2(proxy).version(), 2);

        BoxV2(proxy).setNumber(7);
        assertEq(BoxV2(proxy).getNumber(), 7);
    }
}
