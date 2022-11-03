# Json

The Json module is useful for those who want a simple and easy way to encode solidity data to JSON without worrying about string concatenation.

## Getting started

1. Install the Polly core and Json module packages with `yarn add @polly-tools/core @polly-tools/`

2. Import in your solidity code with
```
@import "@polly-tools/core/contracts/Polly.sol";
@import "@polly-tools/module-json/contracts/Json.sol";
```

3. Initiate
```
Polly polly = Polly(0x3504e31F9b8aa9006a742dEe706c9FF9a276F4FA);
Json json = Json(polly.getModule('Json', 1).implementation);
```

## Encoding a simple string value
```
Json.Item[] items = new Json.Item[](1);

items[0]._type = Json.Type.STRING;
items[0]._string = 'Hello World!';

json.encode(items, Json.Format.VALUE);
```

## Encoding an object
```
Json.Item[] person = new Json.Item[](2);

person[0]._type = Json.Type.STRING;
person[0]._key = 'name';
person[0]._string = 'Bob';

person[1]._type = Json.Type.NUMBER;
person[1]._key = 'age';
person[1]._uint = 42;

string memory bob = json.encode(person, Json.Format.OBJECT);
// {"name": "Bob", "age": 42}


// Reusing the person format
person[0]._string = 'Alice';
person[1]._uint = 33;

string memory alice = json.encode(person, Json.Format.OBJECT);
// {"name": "Alice", "age": 33}
```


## Encoding an array of objects
```
Json.Item[] persons = new Json.Item[](2);

persons[0]._type = Json.Type.STRING;
persons[0]._string = bob;

persons[1]._type = Json.Type.STRING;
persons[1]._string = alice;

string memory person_list = json.encode(persons, Json.Format.ARRAY);
// [{"name": "Bob", "age": 42}, {"name": "Alice", "age": 33}]
```

