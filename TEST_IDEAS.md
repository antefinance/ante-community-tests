# Ante Test Ideas

We’re excited you want to contribute to Ante! In addition to helping build a safer Web3 ecosystem, writing an Ante Test is a fantastic way for new Solidity developers to learn the basics (for example, anon Paradigm engineer [FrankieIsLost](https://github.com/FrankieIsLost) wrote an Ante Test early in their Web3 career).

Here's how you can help:

## Contribute test ideas
Have protocols you want tested? Submit Ante Test ideas to the list below or in [Discord](https://discord.gg/ante)! You can check out [Coming up with an Invariant](https://docs.ante.finance/antev05/for-devs/writing-an-ante-test/invariant-ideas) for examples of protocol invariants you could write a test for.

## Contribute test code
1. Select any test on the list that isn't already picked up by someone else
2. **Add yourself to the Test Writer column** (so no one ends up duplicating someone else's work!)
3. Happy test writing! See [Writing an Ante Test](https://docs.ante.finance/antev05/for-devs/writing-an-ante-test) for a step-by-step guide.

## Test Ideas
Note: when we say rug, that could imply draining funds, but could also include failure of any guarantee in a meaningful manner.

| Test Idea                                                                                               | Status      | Test Writer  |
| :------------------------------------------------------------------------------------------------------ | :---------- | :----------- |
| AAVE doesn't rug                                                                                        | Not started |              |
| Arbitrum bridge doesn't rug                                                                             | Not started |              |
| Axie doesn't collapse                                                                                   | Not started |              |
| Cobie doesn't rug Do-Algod-DCR Luna bet escrow wallet                                                   | Merged      | abitwhaleish |
| Compound test? (re: latest vulnerability)                                                               | Not started |              |
| Curve 3pool doesn't rug                                                                                 | Not started |              |
| Curve 3pool doesn't becomes unbalanced past threshold<br />(look at historic balances and choose some stdev) | Not started |              |
| Curve stETH x ETH pool doesn't rug                                                                      | Not started |              |
| Curve TVL doesn't plunge                                                                                | Not started |              |
| ___ DAO multisig doesn't rug                                                                            | Not started |              |
| Fei doesn't rug                                                                                         | Not started |              |
| Frax always sufficiently collateralized                                                                 | Not started |              |
| LlamaPay test (lastPayerUpdate <= block.timestamp)                                                      | In review   | abitwhaleish |
| Maker's biggest vaults don't rug                                                                        | Not started |              |
| Near <> ETH bridge doesn't rug                                                                          | Not started |              |
| Nexus Mutual doesn't rug                                                                                | Not started |              |
| Nexus Mutual never undercollateralized                                                                  | Not started |              |
| Optimism bridge doesn't rug                                                                             | Not started |              |
| Polygon bridge doesn't rug                                                                              | Not started |              |
| Rari pool doesn't rug                                                                                   | Not started |              |
| Stargate test?                                                                                          | Not started |              |
| Tetra locker doesn't rug                                                                                | Not started |              |
| Uniswap periphery functioning correctly                                                                 | Not started |              |
| USDM fully backed by Mochi vault assets                                                                 | Not started |              |
| USDC-DAI exchange rate remains steady                                                                   | Merged | icepaq |
| USDT-UST exchange rate remains steady                                                                   | Merged | icepaq |
| USDT-USDC exchange rate remains steady                                                                  | Merged | icepaq |        
| USDT-DAI exchange rate remains steady                                                                   | Not started |              |
| UST price stays pegged within 5% of 1 USD                                                               | Merged      | abitwhaleish |
| VC token dump test                                                                                      | Not started |              |
| zksync bridge doesn't rug                                                                               | Not started |              |
| POC: knowledge of private key among multisig not leaked                                                 | Not started |              |
| POC: knowledge of single private key not leaked (cannot sign a given message in a way)                  | Not started |              |
