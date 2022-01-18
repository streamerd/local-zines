# LocalZines

This project demonstrates ERC1155 to distribute number of NFTs to accounts that are either collaborators or artistic communities of a locality, via using of access control functionality and token burning only by artists, and configuration inclusion to define how many edition will be minted/dedicated to collaborators and the communities.

as is with arbitrary distributions: 
```
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant COLLABORATOR_ROLE = keccak256("COLLABORATOR_ROLE");
    bytes32 public constant COMMUNITY_ROLE = keccak256("COMMUNITY_ROLE");

    function setMintAmounts() public onlyRole(MINTER_ROLE) {
        _roleToMintAmount[URI_SETTER_ROLE] = 0; // for now, set to 0.
        _roleToMintAmount[MINTER_ROLE] = 0;     // for now, set to 0.
        _roleToMintAmount[COLLABORATOR_ROLE] = 3;
        _roleToMintAmount[COMMUNITY_ROLE] = 2;
    }
```

At contracts/LocalZine.sol constructor, number of copies are minted to collaborators and "graffiti-hamburg" and "hiphop-hamburg" communities. 

.. from this point on, would like to try one thing. 

a potential flaw, or fallacy on the scenario so far, compared to use a divided contract would be that it cannot guarantee that minted editions on each parties' NFTs might not equally incentivised as is on a market place.

if same artworks would be made purchase'able, it'd be using a `round-robin` approach and display from different kinds of participation and display one at a time in a fair marketplace.

also maybe some of those displays, starting with picks from minted tokens to different artists, designers, and many more. 
 

here are commands to compile and deploy the contract on rinkeby test network.

this project is configured to work for rinkeby testnet.
In hardhat.config.js file you can change that.

as is, it's using below environment variables from
a .env file on the project root folder. 

you can create one and then dotenv will work.
make sure DEPLOYER_ACCOUNT's value is 
private key of the deployer account on rinkeby.

```
ALCHEMY_RINKEBY_URL= ...
DEPLOYER_ACCOUNT= ...
```

after configuration completed, 
```
npx hardhat compile
npx hardhat run --network rinkeby scripts/deploy-local-zine.js
```

then you can verify that deployed contract and play with it directy from ethereum with below command, at the end, appending a space and the deployed contract address we got from the above command. 

```
npx hardhat verify --network rinkeby --contract contracts/LocalZine.sol:LocalZine 0x..
```
