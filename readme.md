<div align="center">
    <h1>Typed</h1>
    <img alt="GitHub Workflow Status" src="https://img.shields.io/github/workflow/status/sovietkitsune/typed/testing?style=flat-square">
</div>

Typed is a module to aid in allowing for typed code

Here we see it gives clean errors that look like errors from misused standard functions

```
bad argument #1 to 'tonumber' (string expected, got nil)
```

## Table of contents

* [Example](#quick-example)
* [Types and arrays](#types-and-arrays)
* [Logical statements](#logical-statements)
* [Installation](#installation)
* [Testing](#installation)
* [Documentation](#documentation)

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

## Tables and arrays

Typed also supports arrays and tables in its definitions.

An array is `type` followed by `[]` while a table is `table<keyType, valueType>`.

By default, an empty table `{}` would be `unknown[]`. This is as it can't be inferred what it is.

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

## Testing

Typed is tested using [busted](https://olivinelabs.com/busted/).

```sh
busted
```

## TODO

* Logical `not` (`!`)
* Typecast operators (`>`)

## Documentation

###  typed.strict
If typed should panic on invalid types.

When set to `false`, the code might be unstable.

###  typed.isArray(tbl)
Is this an array?

* **Parameters**
    **tbl** (*dict[any, any]*)

* **Return type**
    boolean

###  typed.whatIs(this)
What is this specific item?

Note: This can be overridden with __name field.

Arrays are represented with type[] and tables with table<keyType, valueType>.


* **Parameters**
    **this** (*any*)

* **Return type**
    str

###  typed.resolve(validator, pos, name)
Create a new function to validate types

This is commonly piped into assert and should be used in environments without debug.

* **Parameters**
    * **validator** (*str*) – The validation string like string | number
    * **pos** (*number or nil*) – The position of where this is argument is (defaults to 1)
    * **name** (*str or nil*) – The name of the function (defaults to ?)

* **Return type**
    fun(any):boolean or nil or str

###  typed.func(name, ...)
Create a new typed function.

**This function uses the debug library**

You can override the inferred name by passing a first argument.

The rest of the arguments are validation strings.

This returns a function which would take those arguments defined in the validation string.

* **Parameters**
    * **name** (*str*)
    * **...** (*str*)

* **Return type**
    fun(...):void