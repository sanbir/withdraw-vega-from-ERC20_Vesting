//SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

interface IMultiSigWallet {

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    function MultiSigWallet(address[] memory _owners, uint _required) external;

    function addOwner(address owner) external;

    function removeOwner(address owner) external;

    function replaceOwner(address owner, address newOwner) external;

    function changeRequirement(uint _required) external;

    function submitTransaction(address destination, uint value, bytes memory data) external;

    function confirmTransaction(uint transactionId) external;

    function revokeConfirmation(uint transactionId) external;

    function executeTransaction(uint transactionId) external;

    function isConfirmed(uint transactionId) external;

    function getConfirmationCount(uint transactionId)
    external
    view
    returns (uint count);

    function getTransactionCount(bool pending, bool executed)
    external
    view
    returns (uint count);

    function getOwners()
    external
    view
    returns (address[] memory);

    function getConfirmations(uint transactionId)
    external
    view
    returns (address[] memory _confirmations);

    function getTransactionIds(uint from, uint to, bool pending, bool executed)
    external
    view
    returns (uint[] memory _transactionIds);
}

interface IMultiSigWalletWithDailyLimit is IMultiSigWallet {

    event DailyLimitChange(uint dailyLimit);

    function MultiSigWalletWithDailyLimit(address[] memory _owners, uint _required, uint _dailyLimit) external;

    function changeDailyLimit(uint _dailyLimit) external;

    function executeTransaction(uint transactionId) override external;

    function calcMaxWithdraw()
    external
    view
    returns (uint);
}
