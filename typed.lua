--[[lit-meta
   name = "SovietKitsune/typed"
   version = "1.0.2"
   dependencies = {}
   description = "A module to aid in allowing for typed code."
   tags = { "lua", "types"}
   license = "MIT"
   author = { name = "Soviet Kitsune", email = "sovietkitsune@soviet.solutions" }
   homepage = "https://github.com/SovietKitsune/typed"
]]
--- # Typed
---
--- A module to aid in allowing for typed code
---
--- Typed gives clean errors that look like errors from misused standard functions
---
--- ```
--- bad argument #1 to 'tostring' (string | function expected, got nil)
--- ```
--- 
--- ## Quick example
---
--- ```lua
--- local typed = require 'typed'
---
--- local function hi(msg)
---    typed.func(_, 'string')(msg)
---
---    print(msg)
--- end
--- 
--- hi('hello') -- No errors
--- hi(1) -- bad argument #1 to 'hi' (string expected, got number)
--- ```
--- 
--- Typed can automatically figure out the name of the function, however, 
--- if you want to replace it, you pass the first argument.
---
--- ## Tables and arrays
---
--- Typed also supports arrays and tables in its definitions.
---
--- An array is `type` followed by `[]` while a table is `table<keyType, valueType>`.
--- 
--- By default, an empty table `{}` would be `unknown[]`. This is as it can't be inferred what it is.
---
--- ## Logical statements
---
--- Currently typed only supports the `or` logical operator.
---
--- ```lua
--- local typed = require 'typed'
---
--- local function hi(msg)
---    typed.func(_, 'string | number')(msg)
---
---    print(msg)
--- end
--- 
--- hi('hello') -- No errors
--- hi(1) -- No errors
--- ```
---
--- Here is the first example using the `or` operator represented with `|`.
---
--- It does exactly what you would think it does, it will accept strings **or** numbers.
--- 
---@module typed
local typed = {}

unpack = unpack or table.unpack

--- If typed should panic on invalid types.
---
--- When set to `false`, the code might be unstable.
typed.panic = true

-- Utilities

local function split(str, separator)
   local ret = {}

   if not str then
      return ret
   end

   if not separator or separator == '' then
      for c in string.gmatch(str, '.') do
         table.insert(ret, c)
      end

      return ret
   end

   local n = 1

   while true do
      local i, j = string.find(str, separator, n)

      if not i then
         break
      end

      table.insert(ret, string.sub(str, n, i - 1))

      n = j + 1
   end

   table.insert(ret, string.sub(str, n))

   return ret
end

local function trim(str)
   return string.match(str, '^%s*(.-)%s*$')
end

--- Is this an array?
---@param tbl table<any, any>
---@return boolean
function typed.isArray(tbl)
   for i in pairs(tbl) do
      if type(i) ~= 'number' then
         return false
      end
   end

   return true
end

--- What is this specific item?
---
--- Note: This can be overridden with `__name` field.
---
--- Arrays are represented with `type[]` and tables with `table<keyType, valueType>`.
---@param this any
---@return string
function typed.whatIs(this)
   if type(this) == 'table' and this.__name then
      return this.__name
   else
      if type(this) == 'table' then
         if typed.isArray(this) then
            if #this > 0 then
               local currentType = typed.whatIs(this[1])

               for _, v in pairs(this) do
                  if typed.whatIs(v) ~= currentType and currentType ~= 'any' then
                     currentType = 'any'
                  end
               end

               return currentType .. '[]'
            else
               return 'unknown[]'
            end
         else
            local keyType
            local valueType

            for i, v in pairs(this) do
               if not keyType then
                  keyType = typed.whatIs(i)
                  valueType = typed.whatIs(v)
               end

               if typed.whatIs(i) ~= keyType and keyType ~= 'any' then
                  keyType = 'any'
               end

               if typed.whatIs(v) ~= valueType and valueType ~= 'any' then
                  valueType = 'any'
               end
            end

            return 'table<' .. keyType .. ', ' .. valueType .. '>'
         end
      else
         return type(this)
      end
   end
end

--- Create a new function to validate types
---
--- This is commonly piped into assert and should be used in environments without `debug`.
---
---@param validator string The validation string like `string | number`
---@param pos number | nil The position of where this is argument is (defaults to 1)
---@param name string | nil The name of the function (defaults to ?)
---@return fun(x: any):boolean, nil | string
function typed.resolve(validator, pos, name)
   local parts = split(validator, '|')

   for i, v in pairs(parts) do
      parts[i] = trim(v)
   end

   local expects = 'bad argument #' .. 
      (pos or 1) .. ' to \'' .. (name or '?') .. 
      '\' (' .. table.concat(parts, ' | ') .. ' expected, got %s)'

   return function(x)
      local matches 
      
      for _, v in pairs(parts) do
         if typed.whatIs(x) == v then
            matches = v
            break
         end
      end

      if matches == nil then
         return nil, string.format(expects, typed.whatIs(x))
      else
         return true
      end
   end
end

--- Create a new typed function.
---
--- **This function uses the debug library**
---
--- You can override the inferred name by passing a first argument.
---
--- The rest of the arguments are validation strings.
---
--- This returns a function which would take those arguments defined in the validation string.
---@param name string
---@vararg string
---@return fun(...):void
function typed.func(name, ...)
   local info = debug.getinfo(2)

   typed.resolve('string | nil', 1, 'typed.func')(name or info.name)

   for i, v in pairs {...} do
      assert(typed.resolve('string', i + 1, 'typed.func')(v))
   end

   local arr = {...}

   return function(...)
      local input = {...}
      for i = 1, #arr do
         local newInfo = debug.getinfo(2)

         local succ, err = typed.resolve(arr[i], i, name or newInfo.name)(input[i])

         if not succ then
            -- Testing
            if not _TEST then
               print(debug.traceback(string.format('Uncaught exception:\n%s:%u: %s', newInfo.short_src,
                                                   newInfo.currentline, err), 3))
            else
               -- Instead store the error within os
               os.error = err
            end

            if typed.panic then
               os.exit(-1)
            else
               print 'The code is now unstable now as panicking has been disabled!'
            end
         end
      end
   end
end

return typed