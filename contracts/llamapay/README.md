# LlamaPay Ante Tests

## AnteLlamaPayTest
**Author:** [@abitwhaleish](https://github.com/abitwhaleish)

### How it works
Coming soon.

### Usage notes

**Staking**

If you are staking the LlamaPay Ante Test, you can interact with the pool the same way you would with any other Ante Test; either via web app[add link] or directly[add link] (e.g. via Etherscan).

**Challenging**

1. Deploy the [**AnteLlamaPayTestChallengerWrapper**](https://github.com/antefinance/ante-community-tests/blob/main/contracts/llamapay/AnteLlamaPayTestChallengerWrapper.sol) or [**AnteLlamaPayTestChallengerWrapperAvax**](https://github.com/antefinance/ante-community-tests/blob/main/contracts/llamapay/AnteLlamaPayTestChallengerWrapperAvax.sol) contract depending on the chain with the corresponding LlamaPay Ante Test and Ante Pool addresses as arguments; currently:

| **Network**       | **Ante Test** | **Ante Pool** |
|:------------------|:--------------|:--------------|
| Ethereum Mainnet  | [0x62ca84def073e6788b4f68e387617e50c8d36ebf](https://etherscan.io/address/0x62ca84def073e6788b4f68e387617e50c8d36ebf) | [0x18fCb9704D596Ac3cf912F3Bd390579b8c22684F](https://etherscan.io/address/0x18fCb9704D596Ac3cf912F3Bd390579b8c22684F) |
| Ethereum Rinkeby  | [0x2eFAe77c5287e1Fea56EA13C91561FBa4730256c](https://rinkeby.etherscan.io/address/0x2efae77c5287e1fea56ea13c91561fba4730256c) | [0x8B29C1f916DD7d537D8438dF3A70f642eCf6794B](https://rinkeby.etherscan.io/address/0x8B29C1f916DD7d537D8438dF3A70f642eCf6794B) |
| Avalanche C-Chain | [0x4c008a686899F9a745C394A8C42d4a4Cb89F23A5](https://snowtrace.io/address/0x4c008a686899F9a745C394A8C42d4a4Cb89F23A5) | [0x99eDEcfE4FE9c2d760b30E782eA0E6C87Bd2F3ac](https://snowtrace.io/address/0x99eDEcfE4FE9c2d760b30E782eA0E6C87Bd2F3ac) |
| Avalanche Fuji    | Coming soon!  | Coming soon!  |

2. Use the `challenge()` wrapper function to interact with the Ante Pool (e.g. via Etherscan or other preferred method)
3. To withdraw challenged funds, use the `withdrawChallenge()` or `withdrawChallengeAll()` wrapper functions

**Checking the Test**

Using the wrapper you deployed, call `setParamsAndCheckTest()`, passing in the token address and payer address to check. If the test fails, you can use the `claim()` function to claim your share of the payout.
