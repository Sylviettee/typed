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