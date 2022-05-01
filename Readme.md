# Setup

   npm install

# To compile

    truffle compile

# To deploy in the dev environment

    truffle develop
    migrate --reset --compile-all

# To deploy in a new network

Edit the `truffle-config.js` file and add a new entry under `networks`. Then run:

    truffle migrate --reset --compile-all --network YOUR_NETWORK

# using foundry
    forge init
    forge remappings
    forge install OpenZeppelin/openzeppelin-contracts

# to build foundry project
    forge build --force --contracts contracts --lib-paths foundry-lib
# to run flashloan tests
    forge test --contracts contracts --lib-paths foundry-lib  --match _flashloan -vv --force

# to deploy project using foundry
    forge create H2oToken --contracts contracts/tokens/H2OToken.sol --rpc-url "http://localhost:8545"
    forge create IceToken --contracts contracts/tokens/IceToken.sol --rpc-url "http://localhost:8545"
    forge create SteamToken --contracts contracts/tokens/SteamToken.sol --rpc-url "http://localhost:8545"
    forge create Controller --constructor-args H2OToken, IceToken, StreamToken --contracts contracts/Controller.sol --private-key "http://localhost:8545"