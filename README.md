# LocalZines

This project demonstrates ERC1155 to distribute number of NFTs to accounts that are either collaborators or artistic communities of a locality.

At contracts/LocalZine.sol constructor, number of copies are minted to collaborators and "graffiti-hamburg" and "hiphop-hamburg" communities. 

Here are commands to compile and deploy the contract on rinkeby test network.

This project is configured to work for rinkeby testnet.
In hardhat.config.js file you can change that.

As is, it's using below environment variables from
a .env file on the project root folder. 

You can create one and then dotenv will work.
Make sure DEPLOYER_ACCOUNT's value is 
private key of the deployer account on rinkeby.

```
ALCHEMY_RINKEBY_URL= ...
DEPLOYER_ACCOUNT= ...
```

after configuration completed, 
```shell
npx hardhat compile
npx hardhat run --network rinkeby scripts/deploy-local-zine.js
```
