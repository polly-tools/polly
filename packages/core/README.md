# Polly

Polly is multipurpose modular onchain framework for smart contracts. This package is intended to be used by those who want to develop new modules or integrate exisiting Polly modules in their own deployments.

## Preamble
All examples in this package assume that the development environment uses some sort mainnet forking and Yarn for node package management.

## Getting started
`yarn add @polly-tools/core` to add this package to your project. Import into your solidity project by adding `import "@polly-tools/core/contracts/Polly.sol"`.

## Using plain modules
Using a non-configurable module is pretty straight forward. For this example we're using the Json module.

1. Install the Json module package version 1
```
yarn add @polly-tools/module-json@^1.0.0
```

2. Import Polly and the module package
```
import "@polly-tools/core/contracts/Polly.sol";
import "@polly-tools/module-json/Json.sol";
```

3. Initiate the Json module
```
Polly polly = Polly(0x3504e31F9b8aa9006a742dEe706c9FF9a276F4FA);
Json json = Json(polly.getModule('Json', 1).implementation);
```


## Using configurable modules
Using a configurable module involves some more steps, but is still easy enough.

1. Install the Token721 module package version 1
```
yarn add @polly-tools/module-token721^1.0.0
```

2. Import Polly and the module package
```
import "@polly-tools/core/contracts/Polly.sol";
import "@polly-tools/module-token721/Token721.sol";
```

1. Configure the Token721 module
```
Polly polly = Polly(0x3504e31F9b8aa9006a742dEe706c9FF9a276F4FA);
Polly.Param[] memory params = new Polly.Param[](0);

// Configure the Token721 module and store configuration in Polly with name "My config"
Polly.Param[] memory config = polly.configureModule('Token721', 1, params, true, 'My config');
// Initiate newly created token at address returned from configurator
Token721 token721 = Token721(config[0]._address);
```
