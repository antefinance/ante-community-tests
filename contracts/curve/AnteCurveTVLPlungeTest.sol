pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

// @title Curve TVL Plunge Test
// @notice Ensure that curve keeps a TVL of > 10%"
contract AnteCurveTVLPlungeTest is AnteTest("Ensure that curve keeps a TVL of > 10%") {

    address constant COMPOUND_SWAP = 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56;
    address constant USDT_SWAP = 0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C;
    address constant SUSD_SWAP = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;
    address constant SBTC_SWAP = 0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714;

    address constant COMPOUND_ADDRESS = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant SUSD_ADDRESS = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address constant SBTC_ADDRESS = 0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6;

    IERC20 constant COMPOUND = IERC20(COMPOUND_ADDRESS);
    IERC20 constant USDT = IERC20(USDT_ADDRESS);
    IERC20 constant SUSD = IERC20(SUSD_ADDRESS);
    IERC20 constant SBTC = IERC20(SBTC_ADDRESS);

    uint256 immutable oldTVL;

    constructor() {

        testedContracts = [COMPOUND_SWAP, USDT_SWAP, SUSD_SWAP, SBTC_SWAP];
        protocolName = "Curve";

        oldTVL = COMPOUND.balanceOf(COMPOUND_SWAP) + 
                    USDT.balanceOf(USDT_SWAP) + 
                    SUSD.balanceOf(SUSD_SWAP) + 
                    SBTC.balanceOf(SBTC_SWAP);
    }

    // @return the current tvl
    function getTotalValue() public view returns(uint256){
        return COMPOUND.balanceOf(COMPOUND_SWAP) + 
                    USDT.balanceOf(USDT_SWAP) + 
                    SUSD.balanceOf(SUSD_SWAP) + 
                    SBTC.balanceOf(SBTC_SWAP);
    }

    // @return if the current tvl is above 10% of the original TVL
    function checkTestPasses() public view override returns (bool) {
        return (100 * getTotalValue() / oldTVL > 10);
    }
}
