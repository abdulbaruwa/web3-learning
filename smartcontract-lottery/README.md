### Smartcontract-based implementation of a Lottery

#### Features
1. Users can enter lottery with ETH based on a USD fee
2. An admin will choose when the lottery is over ( having an admin means it is not  decentralised - hing chainlink keepers or a DAO)
3. The lottery will select a random user.


### Testing
1. `mainnet-fork`
2. `development`  with mocks
3. `testnet`


### Add a mainnet fork
brownie networks add development mainnet-fork-dev cmd=ganache-cli host=http://127.0.0.1 fork='https://mainnet.infura.io/v3/$WEB3_INFURA_PROJECT_ID' accounts=10 mnemonic=brownie port=8545