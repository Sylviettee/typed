<div align="center">
   <h1>Typed</h1>
   <a href="https://github.com/SovietKitsune/typed/actions">
      <img alt="GitHub Workflow Status" src="https://img.shields.io/github/workflow/status/sovietkitsune/typed/testing?style=flat-square">
   </a>
   <a href="https://codecov.io/gh/sovietkitsune/typed">
      <img alt="Codecov" src="https://img.shields.io/codecov/c/github/sovietkitsune/typed?style=flat-square">
   </a>
   <a href="https://typed.readthedocs.org">
      <img alt="Read the Docs" src="https://img.shields.io/readthedocs/typed?style=flat-square">
   </a>
</div>

Typed is a module to aid in allowing for typed code

Here we see it gives clean errors that look like errors from misused standard functions

```
bad argument #1 to 'tonumber' (string expected, got nil)
```

## Table of contents

- [Table of contents](#table-of-contents)
- [Quick example](#quick-example)
- [Tables and arrays](#tables-and-arrays)
- [Logical statements](#logical-statements)
- [Arrays, typed arrays, typed dictionaries, and schemas.](#arrays-typed-arrays-typed-dictionaries-and-schemas)
  - [Arrays](#arrays)
  - [Typed array](#typed-array)
  - [Typed dictionaries](#typed-dictionaries)
  - [Schemas](#schemas)
- [Installation](#installation)
- [Testing](#testing)
- [TODO](#todo)
- [Documentation](#documentation)

## Quick example

```lua
local typed = require 'typed'

local function hi(msg)
   typed.func(_, 'string')(msg)

   print(msg)
end

hi('hello') -- No errors
hi(1) -- bad argument #1 to 'hi' (string expected, got number)
```

Typed can automatically figure out the name of the function, however, 
if you want to replace it, you pass the first argument.

More examples can be located in the [examples directory](https://github.com/SovietKitsune/typed/tree/master/examples)

## Tables and arrays

Typed also supports arrays and tables in its definitions.

An array is `type` followed by `[]` while a table is `table<keyType, valueType>`.

By default, an empty table `{}` would be `unknown[]`. This is as it can't be inferred what it is.

Arrays are treated the same say as `{}`, `typed.Array()` would be the same as `unknown[]`.

Typed arrays do not function like this. Instead they are registered as `TypedArray<type>`.
Where `type` is the type stored within.

## Logical statements

Currently typed only supports the `or` logical operator.

```lua
local typed = require 'typed'

local function hi(msg)
   typed.func(_, 'string | number')(msg)

   print(msg)
end

hi('hello') -- No errors
hi(1) -- No errors
```

Here is the first example using the `or` operator represented with `|`.

It does exactly what you would think it does, it will accept strings **or** numbers.

## Arrays, typed arrays, typed dictionaries, and schemas.

Typed can do more then just validate function parameters. They can also

- Validate what goes in and out a dictionary
- Validate what goes in and out an array
- Validate complex objects.

### Arrays

Arrays are a wrapper around tables with utility functions such as `:filter` and `:find`.

### Typed array

A typed array is just a fancy array which protects the values within.

```lua
local typed = require 'typed'

local arr = typed.TypedArray('number')

arr:push() -- bad argument #1 to 'push' (number expected, got nil)
```

Here we see it protects the push method to prevent non-numbers from entering.

### Typed dictionaries

A typed dictionary is a dictionary with its `__newindex` method changed.

```lua
typed.typedDict('string', 'number')[3] = 2

-- (5.2+) bad argument #1 to '__newindex' (string expected, got number)
-- (5.1)bad argument #1 to '?' (string expected, got number)
```

This allows you to more control what users do with your data.

### Schemas

Schemas are commonly used to validate and setup configurations.

In the example below we see us using a schema to validate a configuration and setup defaults.

```lua
local typed = require 'typed'
local toml = require 'toml'

local configSchema = typed.Schema('config')
   :field('saveLocation', 'string')
   :field('playerName', 'string', 'joe')

local data, err = configSchema:validate(toml.parse([[
saveLocation = "hi"
]]))

if err then
   error 'Invalid config!'
end

for i, v in pairs(data) do
   print(i, v)
   --> playerName      joe
   --> saveLocation    hi
end
```

Schemas can also be nested to allow for even more complex objects.

```lua
local typed = require 'typed'

local schema = typed.Schema('test')
   :field('name', 'string')
   :field('id', 'number')

print(schema:validate {
   name = '3',
   id = '2'
}) --> false   Expected number, got string on field id

local newSchema = typed.Schema('nested')
   :field('sub', schema)
   :field('id', 'number')

print(newSchema:validate {
   sub = {
      name = '3',
      id = '2'
   },
   id = 2
}) --> false   Expected test, got Malformed test on field sub; Expected number, got string on field id
```

Validation does not cause errors automatically, you would need to assert them in order to get an error.

## Installation

You can install typed by using [lit](http://luvit.io/lit.html) or [Luarocks](https://luarocks.org).

```sh
# Using lit
lit install SovietKitsune/typed
# Using Luarocks
luarocks install typed
```

You may also install it locally and place it somewhere where Lua can find it.

```sh
wget --output-document typed.lua https://git.io/JkPmL
```

You would also need to install [middleclass](https://github.com/kikito/middleclass) as well.

## Testing

Typed is tested using [busted](https://olivinelabs.com/busted/).

```sh
busted
```

## TODO

* Logical `not` (`!`)
* Typecast operators (`>`)
* Pairs and len tests for 5.2+
* Logical `or` (`|`) on schemas

## Documentation

Documentation can be found [here](https://typed.readthedocs.org)