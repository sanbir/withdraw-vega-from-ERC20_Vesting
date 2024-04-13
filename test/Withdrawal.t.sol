// SPDX-FileCopyrightText: 2022 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
import "../src/ERC20_Vesting.sol";
import "../src/IMultiSigWalletWithDailyLimit.sol";

contract Withdrawal is Test {
    address constant public multisigWallet_Address = 0x592e720974D478832053AF79151f3482b1538F36;
    address constant public ERC20_Vesting_Address = 0x23d1bFE8fA50a167816fBD79D7932577c06011f4;
    address constant public v2_address = 0xcB84d72e61e383767C4DFEb2d8ff7f4FB89abc6e;

    address constant public account1 = 0xF5EFD4E7ebe4203d3Ee592AA058809d0Ae613aCA;
    address constant public account2 = 0xaeF7d07F5aDC3084D43963009CCD67C6C68aea64;

    address constant public anotherWallet = 0x16da609341ed67750A8BCC5AAa2005471006Cd77;

    bytes32 constant public vega_public_key = hex"7A542A71397AEEFB4CBEAF5CDD565D475CBC87C63EB469C95497A5A6C2874797";

    Vm cheats = Vm(HEVM_ADDRESS);

    ERC20_Vesting public erc20_Vesting;
    IERC20 public vegaToken;
    IMultiSigWalletWithDailyLimit public multisig;

    function setUp() public {
        erc20_Vesting = ERC20_Vesting(ERC20_Vesting_Address);
        vegaToken = IERC20(v2_address);
        multisig = IMultiSigWalletWithDailyLimit(multisigWallet_Address);
    }

    function testWithdrawal() public {
        uint256 vegaBalanceOfAnotherWalletBefore = vegaToken.balanceOf(anotherWallet);

        uint256 vested_for_tranche_3 = erc20_Vesting.get_vested_for_tranche(multisigWallet_Address, 3);
        uint256 vested_for_tranche_8 = erc20_Vesting.get_vested_for_tranche(multisigWallet_Address, 8);

        uint256 totalVested = 38719906076721291002783;

        bytes memory remove_stake = abi.encodeWithSelector(erc20_Vesting.remove_stake.selector, totalVested, vega_public_key);
        emit log_bytes(remove_stake);
        bytes memory withdraw_from_tranch_3 = abi.encodeWithSelector(erc20_Vesting.withdraw_from_tranche.selector, uint8(3));
        emit log_bytes(withdraw_from_tranch_3);
        bytes memory withdraw_from_tranch_8 = abi.encodeWithSelector(erc20_Vesting.withdraw_from_tranche.selector, uint8(8));
        // emit log_bytes(withdraw_from_tranch_8);
        bytes memory transfer_vega_to_another_wallet = abi.encodeWithSelector(vegaToken.transfer.selector, anotherWallet, vested_for_tranche_3);
        emit log_bytes(transfer_vega_to_another_wallet);

        uint txCount = multisig.getTransactionCount(true, true);

        cheats.startPrank(account2);
        multisig.submitTransaction(ERC20_Vesting_Address, 0, remove_stake);
        multisig.submitTransaction(ERC20_Vesting_Address, 0, withdraw_from_tranch_3);
        // multisig.submitTransaction(ERC20_Vesting_Address, 0, withdraw_from_tranch_8);
        multisig.submitTransaction(v2_address, 0, transfer_vega_to_another_wallet);
        cheats.stopPrank();

        cheats.startPrank(account1);
        multisig.confirmTransaction(txCount);
        multisig.confirmTransaction(txCount + 1);
        multisig.confirmTransaction(txCount + 2);
        // multisig.confirmTransaction(txCount + 3);
        cheats.stopPrank();

        uint256 vegaBalanceOfAnotherWalletAfter = vegaToken.balanceOf(anotherWallet);
        emit log_uint(vegaBalanceOfAnotherWalletAfter - vegaBalanceOfAnotherWalletBefore);
    }
}
