# ante-community-tests

Follow this [guide](https://docs.ante.finance/ante/for-developers/writing-ante-tests) to write an Ante Test and submit a PR.

Suggest test ideas or ask questions in [Discord](https://discord.gg/ante).

Learn about Ante: [ante.finance](https://www.ante.finance/) | [Twitter](https://twitter.com/AnteFinance) | [YouTube](https://www.youtube.com/channel/UCJ7wxiuzI2SKw3U2gB2ZqDA)

---

## Contribute to the community repository

### Set up your local environment

1. Install Node and NPM ([Instructions](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm))
    ```
    Make sure to use Node version 14 or higher and NPM version 6 or higher
    ```

2. Fork the ante-community-tests repository by clicking the `Fork` button in the upper right hand corner of this page, then clone your fork to your local machine with
    ```
    git clone git@github.com:[YOUR_GITHUB_USERNAME]/ante-community-tests.git
    ```

3. Install all required packages
    ```
    npm install --save-dev
    ```

4. Copy [`.env.example`](./.env.example) to `.env` and fill in any required values:
    1. To run the testing suite, you'll need a free [Alchemy API key](https://auth.alchemy.com/signup)
    2. To deploy contracts, you'll need a free [Infura API key](https://app.infura.io/register) as well as a mnemonic/private key (if you do not have a mnemonic you can use `test test test test test test test test test test test junk`)
    3. To verify deployed contracts, you'll need free block explorer API keys (e.g. [Etherscan](https://etherscan.io/register))
    
### Write your Ante Test

Write an ante test for your desired protocol and put it in a file called `./contracts/[PROTOCOL_NAME]/[YOUR_TEST_NAME].sol`. For more information on writing Ante Tests, see our [docs](https://docs.ante.finance/). Ask questions in [Discord](https://discord.gg/yaJthzNdNG)!

### Test your Ante Test (Optional)
We recommend writing unit tests to make sure your Ante Test works. Unit tests live in the [`test`](./test/) directory.

**Using Hardhat**

1. Create a file in the `./test/[PROTOCOL_NAME]` folder with filename `[YOUR_TEST_NAME].spec.ts`

2. Fill in the `NETWORK` fieldin your `.env` file with the network you intend to test on.

3. Run the following command:
    ```
    npx hardhat test test/[PROTOCOL_NAME]/[YOUR_TEST_NAME].spec.ts
    ```
    >Troubleshooting: If you are trying to run the testing suite with `npx hardhat test`, you must run `npx hardhat typechain` first to avoid an error where hardhat cannot find the typechain directory

**Using Foundry**

1. Create a file in the `./test/[PROTOCOL_NAME]` folder with filename `[YOUR_TEST_NAME].t.sol`

2. Run the following command:
    ```
    forge test --match-path test/[PROTOCOL_NAME]/[YOUR_TEST_NAME].t.sol
    ```

### Submit a PR

1. Push your code to your own GitHub repo and create a pull request against this repo

2. Show off what you've built in our [discord](https://discord.gg/yaJthzNdNG) or tweet your PR at us on [twitter](https://twitter.com/antefinance)!

3. Once your PR has been merged in, feel free to deploy your test and pool!
    >**VERY IMPORTANT** - Make sure to get feedback from our community before deploying your Ante Test to mainnet! Testing and feedback are the best way to catch bugs early (and avoid wasting gas).

## References

[NFT Template Video](https://youtu.be/_qiGWIAyx6k)
