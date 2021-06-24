# ante-community-tests

Please feel free to join our Discord to bounce ideas and discuss various ideas with the community and developers!

Website: [ante.finance](https://www.ante.finance/)  
Twitter: [AnteFinance](https://twitter.com/AnteFinance)  
Discord: [Ante Finance](https://discord.gg/yaJthzNdNG)  

---

_The following has been provided by [@waynebruce0x](https://github.com/waynebruce0x):_
## Getting Started Writing Ante Tests
There are many different tools and methods you can use to develop Ante Tests. In this guide we’ll use
Hardhat and Alchemy, however feel free to adapt this guide to suit your favourite Ethereum development
tools. Hardhat is an environment for developing, testing and deploying smart contracts, and Alchemy is
an Ethereum node service which allows us to interact with projects already on the blockchain.

## Installing A Recent Version of Node.js
First we’ll need a recent version of Node.js, so we can run JavaScript code (which Hardhat is build on
top of). Hardhat have an excellent guide on their website for installing Node.js. This is part of their
Hardhat tutorial which we would recommend to anyone new to Ethereum development.
https://hardhat.org/tutorial/setting-up-the-environment.html

## Creating Your Ante Test Project
Next we’re going to create a new project folder called AnteTest, and change your terminal directory to
this folder so that any future commands run inside the AnteTest folder
```
mkdir AnteTest && cd AnteTest
```
Then create a new package.json file for your project, install hardhat, and run it. If these steps are
successful you’ll see ‘welcome to Hardhat’ printed in your terminal. Use your arrow keys to select ‘Create
an empty hardhat.config.js’
```
npm init -y
npm install --save-dev hardhat
npx hardhat
```
create an empty hardhat.config.js
Great, so now we have your empty Hardhat project ready and waiting. Next we’ll install some plugins to
make things easier. Openzeppelin have a bunch of libraries useful for Ethereum development. We’re just
going to install hardhat-upgrades and contracts. Nomiclabs’ ethers library makes it easier for us to
interact with the Ethereum blockchain.
```
npm install --save-dev @openzeppelin/hardhat-upgrades
npm install --save-dev @openzeppelin/contracts
npm install --save-dev @nomiclabs/hardhat-ethers ethers # peer dependencies
```

## Creating An Alchemy App
sign up to Alchemy at https://www.alchemy.com/. Once you have made a project / app you’ll be given a
unique ‘integrate with alchemy’ URL. Keep this safe! This will allow us to fork the current state of the
Ethereum blockchain, allowing us to interact with projects that have already been deployed (like AAVE,
Uniswap, WBTC etc).

## Configuring Your Ante Test Project
At this point it’s a good idea to open up the AnteTest project in your IDE. You should be able to see a
`hardhat.config.js` file, open it up because we’re going to edit it’s contents. We’re going to add
requirements for two of the plugins we just installed, and give your project details of your Alchemy node.
Clear your `hardhat.config.js` file, then copy and paste the code below into it, where "[ALCHEMYURL]" is
the http address of your Alchemy node. Make `hardhat.config.js` this:
```
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
/**
* @type import('hardhat/config').HardhatUserConfig
*/
module.exports = {
  solidity: "0.8.0",
  networks: {
    hardhat: {
      forking: {
        url: "[ALCHEMYURL]",
      }
    }
  }
};
```

## Adding The Ante Interfaces
Make a new folder in the project called contracts, and inside that, make another folder called interfaces.
Copy the IAnteTest interface and the AnteTest abstract class into this interfaces folder (you can find them
here https://docs.ante.finance/antev05/tutorials/write-an-ante-test/iantetest.sol-and-antetest.sol)

## Writing Your Ante Test
For this step you need to get creative. There are some examples in the Ante docs that you can use as
inspiration. Google search is great for getting ideas and debugging your contract, and if you get stuck
you can always ask us questions in the Ante Discord server!
Put your test in the contracts folder when it’s finished. Then make a new folder called ‘scripts’, with a file
‘deploy.js’ inside it. You’ll also have to write the deployment script yourself (some help can be found here
https://hardhat.org/tutorial/deploying-to-a-live-network.html).

## Putting It All Together
Now you’re ready to check your Ante Test works as you expected! We’re going to run a fork of the
current Ethereum mainnet. This means we can interact with the blockchain without losing any real
money. This step is important because it lets us check that the Ante Test works without any issues
(because even the best devs tests often don’t work first time!).
Start up your Alchemy node
npx hardhat node
Then in a seperate terminal window, also in the AnteTest directory, compile your smart contracts, and
deploy them to the Ethereum fork.
```
npx hardhat compile
npx hardhat run scripts/deploy.js
```
