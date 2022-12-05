import { promises as fsPromises } from 'fs';
import { HardhatUserConfig, task } from 'hardhat/config';

task('antegen:supply-threshold', 'Generate AnteTest to verify a token supply threshold')
  .addParam('token', 'The token to validate')
  .addParam('threshold', 'The threshold to verify')
  .addParam('author', 'Author of the Ante Test')
  .addParam('tokenaddress', 'Address of the token')
  .setAction(async (taskArgs) => {
    let result = await fsPromises.readFile('contracts/templates/AnteTestSupplyThresholdTemplate.sol', 'utf-8');

    result = result.replace(/\[TOKEN\]/g, taskArgs.token);
    result = result.replace(/\[THRESHOLD\]/g, taskArgs.threshold);
    result = result.replace(/\[AUTHOR\]/g, taskArgs.author);
    result = result.replace(/\[TOKEN_ADDRESS\]/g, taskArgs.tokenaddress);

    await fsPromises.writeFile('contracts/antegen/AnteUSDTSupplyTest.sol', result);
  });
