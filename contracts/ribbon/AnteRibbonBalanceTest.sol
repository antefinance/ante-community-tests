// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../AnteTest.sol";

interface IRibbonThetaVault {
    //Returns the asset balance on the vault.
    function totalBalance() external view returns (uint256);

    //Returns the vault's total balance, ncluding the amounts locked into a short position
    function assetBalance() external view returns (uint256);
}

// Ante Test to check if Ribbon Theta Vault maintains a total balance above or equal to its asset balance
contract AnteRibbonBalanceTest is AnteTest("Ribbon Theta Vault Balance above or equal to asset value") {
    // https://etherscan.io/address/0x0FABaF48Bbf864a3947bdd0Ba9d764791a60467A
    address public constant ribbonThetaVaultAddr = 0x0FABaF48Bbf864a3947bdd0Ba9d764791a60467A;

    IRibbonThetaVault public ribbonThetaVault = IRibbonThetaVault(ribbonThetaVaultAddr);

    constructor() {
        protocolName = "Ribbon";
        testedContracts = [ribbonThetaVaultAddr];
    }

    function checkTestPasses() public view override returns (bool) {
        return (ribbonThetaVault.totalBalance() >= ribbonThetaVault.assetBalance());
    }
}
