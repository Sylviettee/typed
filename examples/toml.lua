--[[
A schema can be very useful when working with config files.

Here we see a use by using a toml parser with schemas to fill in defaults and enforce types.
]]

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

--- The data would either be the filled in data or nil and an error