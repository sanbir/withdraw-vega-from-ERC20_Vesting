// SPDX-FileCopyrightText: 2022 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
import "../src/ERC20_Vesting.sol";

contract Withdrawal is Test {
    address constant public multisigWallet = 0x592e720974D478832053AF79151f3482b1538F36;
    address constant public ERC20_Vesting_Address = 0x23d1bFE8fA50a167816fBD79D7932577c06011f4;
    address constant public v2_address = 0xcB84d72e61e383767C4DFEb2d8ff7f4FB89abc6e;

    address constant public account1 = 0xF5EFD4E7ebe4203d3Ee592AA058809d0Ae613aCA;
    address constant public account2 = 0xaeF7d07F5aDC3084D43963009CCD67C6C68aea64;

    Vm cheats = Vm(HEVM_ADDRESS);

    ERC20_Vesting public erc20_Vesting;
    IERC20 public vegaToken;

    function setUp() public {
        erc20_Vesting = ERC20_Vesting(ERC20_Vesting_Address);
        vegaToken = IERC20(v2_address);
    }

    function testWithdrawal() public {
        cheats.startPrank(multisigWallet);
        //vm.recordLogs();

        uint256 vegaBalanceOfMultisigWalletBefore = vegaToken.balanceOf(multisigWallet);

        erc20_Vesting.withdraw_from_tranche(3);
        erc20_Vesting.withdraw_from_tranche(8);

        uint256 vegaBalanceOfMultisigWalletAfter = vegaToken.balanceOf(multisigWallet);

        emit log_uint(vegaBalanceOfMultisigWalletAfter - vegaBalanceOfMultisigWalletBefore);

//        Vm.Log[] memory withdrawLogs = vm.getRecordedLogs();
//        assertEq(withdrawLogs.length, 1);
//        assertEq(withdrawLogs[0].topics[0], keccak256("Withdrawn(uint256,uint256)"));
    }
}
