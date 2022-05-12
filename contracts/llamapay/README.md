# LlamaPay Ante Tests

## AnteLlamaPayTest
**Author:** [@abitwhaleish](https://github.com/abitwhaleish)

### How it works
Coming soon.

### Usage notes

**Staking**

If you are staking the LlamaPay Ante Test, you can interact with the pool the same way you would with any other Ante Test; either via web app[add link] or directly[add link] (e.g. via Etherscan).

**Challenging**

1. Deploy the [**AnteLlamaPayTestChallengerWrapper**](https://github.com/antefinance/ante-community-tests/blob/main/contracts/llamapay/AnteLlamaPayTestChallengerWrapper.sol) contract with the LlamaPay Ante Test and Ante Pool addresses as arguments; currently:
    - Ante Test: [0x62ca84def073e6788b4f68e387617e50c8d36ebf](https://etherscan.io/address/0x62ca84def073e6788b4f68e387617e50c8d36ebf)
    - Ante Pool: [0x18fCb9704D596Ac3cf912F3Bd390579b8c22684F](https://etherscan.io/address/0x18fCb9704D596Ac3cf912F3Bd390579b8c22684F)
2. Use the `challenge()` wrapper function to interact with the Ante Pool (e.g. via Etherscan or other preferred method)
3. To withdraw challenged funds, use the `withdrawChallenge()` or `withdrawChallengeAll()` wrapper functions

**Checking the Test**

Using the wrapper you deployed, call `setParamsAndCheckTest()`, passing in the token address and payer address to check. If the test fails, you can use the `claim()` function to claim your share of the payout.
