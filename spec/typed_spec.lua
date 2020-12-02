local typed = require 'typed'

-- Prevents exiting program
_G._TEST = true

rawset(os, 'exit', function()
   error(rawget(os, 'error'))
end)

describe('typed', function()
   describe('.isArray', function()
      it('should return false on dicts', function()
         assert.False(typed.isArray {hi = true})
      end)

      it('should return true on arrays', function()
         assert(typed.isArray {1, 2, 3})
      end)

      it('should return true on empty tables', function()
         assert(typed.isArray {})
      end)
   end)

   describe('.whatIs', function()
      it('should describe standard Lua types', function()
         assert.are.equal(typed.whatIs(1), 'number')
         assert.are.equal(typed.whatIs(''), 'string')
         assert.are.equal(typed.whatIs(true), 'boolean')
         assert.are.equal(typed.whatIs(print), 'function')
         assert.are.equal(typed.whatIs(coroutine.create(function() end)), 'thread')
         assert.are.equal(typed.whatIs(io.stdout), 'userdata')
      end)

      it('should describe an empty table as unknown[]', function()
         assert.are.equal(typed.whatIs({}), 'unknown[]')
      end)

      it('should describe a number array as number[]', function()
         assert.are.equal(typed.whatIs({1, 2, 3, 4}), 'number[]')
      end)

      it('should describe a mixed array as any[]', function()
         assert.are.equal(typed.whatIs({1, '2', 3, false}), 'any[]')
      end)

      it('should describe a number dict as table<string, number>', function()
         assert.are.equal(typed.whatIs({money = 1}), 'table<string, number>')
      end)

      it('should describe a mixed dict as table<string, any>', function()
         assert.are.equal(typed.whatIs({money = 1, name = 'John'}), 'table<string, any>')
      end)

      it('should describe a key mixed number dict as table<any, number>', function()
         assert.are.equal(typed.whatIs({1, money = 2}), 'table<any, number>')
      end)

      it('should describe a key and value mixed dict as table<any, any>', function()
         assert.are.equal(typed.whatIs({1, '2', hi = true}), 'table<any, any>')
      end)

      it('should support tables within tables', function()
         assert.are.equal(typed.whatIs({{}}), 'unknown[][]')
      end)

      it('should give correct types on tables within tables', function()
         assert.are.equal(typed.whatIs({{1, 2, 3, 4}, {5, 6, 7, 2}}), 'number[][]')
      end)

      it('should support arrays within dicts', function()
         assert.are.equal(typed.whatIs({a = {1, 2, 3}}), 'table<string, number[]>')
      end)

      it('should support dicts within arrays', function()
         assert.are.equal(typed.whatIs({{a = 6}}), 'table<string, number>[]')
      end)

      it('should support deeply nested tables', function()
         assert.are.equal(typed.whatIs({
            friends = {
               {
                  money = 2
               },
               {
                  money = 1
               }
            }
         }), 'table<string, table<string, number>[]>')
      end)

      it('should support custom types', function()
         assert.are.equal(typed.whatIs({__name = 'qwerty'}), 'qwerty')
      end)

      it('should support arrays of custom types', function()
         assert.are.equal(typed.whatIs({{__name = 'qwerty'}}), 'qwerty[]')
      end)

      it('should understand arrays(typed.Array)', function()
         assert.are.equal(typed.whatIs(typed.Array()), 'unknown[]')
      end)

      it('should understand typed arrays', function()
         assert.are.equal(typed.whatIs(typed.TypedArray('number')), 'TypedArray<number>')
      end)
   end)

   describe('.resolve', function()
      it('should return a function', function()
         assert.are.equal(type(typed.resolve('string')), 'function')
      end)

      it('should return a formatted string', function()
         local _, res = typed.resolve('string')(5)
         assert.are.equal(res, 'bad argument #1 to \'?\' (string expected, got number)')
      end)

      it('should support or statements', function()
         local _, res = typed.resolve('string | function')(5)
         assert.are.equal(res, 'bad argument #1 to \'?\' (string | function expected, got number)')
      end)
   end)

   describe('.func', function()
      it('should automatically resolve function name', function()
         local function hi()
            typed.func(_, 'string')()
         end

         assert.has.error(function()
            hi()
         end, 'bad argument #1 to \'hi\' (string expected, got nil)')
      end)
   end)

   describe('.typedDict', function()
      it('should panic on invalid types', function()
         assert.has.error(function()
            typed.typedDict('string', 'number')[3] = 2
         end)
      end)
   end)

   describe('Array', function()
      describe(':len', function()
         it('should return the arrays length', function()
            local array = typed.Array {5, 7, 1, 5, 0}

            assert.are.equal(5, array:len())
         end)
      end)

      describe(':pairs', function()
         it('should loop over each item', function()
            local s = spy.new(function()
            end)

            local array = typed.Array {2, 9, 3, 2}

            for i, v in array:pairs() do
               s(i, v)
            end

            assert.spy(s).was.called(4)
            assert.spy(s).was.called_with(2, 9)
         end)
      end)

      describe(':get', function()
         it('should return contents correctly', function()
            local array = typed.Array {5, 8, '20'}

            array:push(5)

            array:push(8)

            array:push('20')

            assert.are.equal('20', array:get(3))
         end)
      end)

      describe(':iter', function()
         it('should iterate in the same order', function()
            local input = {0, 5, 10, 20, '50', true, false}

            local array = typed.Array(input)

            local output = {}

            for val in array:iter() do
               table.insert(output, val)
            end

            assert.are.same(input, output)
         end)
      end)

      describe(':unpack', function()
         it('should unpack the table in the same order', function()
            local input = {0, 5, 19, 8}

            local array = typed.Array(input)

            assert.are.same(input, {array:unpack()})
         end)
      end)

      describe(':push', function()
         it('should add items in the same order', function()
            local array = typed.Array()

            array:push(5)

            array:push(8)

            assert.are.equal(8, array:get(2))
         end)
      end)

      describe(':pop', function()
         it('should remove the selected item', function()
            local array = typed.Array {1}

            array:pop()

            assert.is_nil(array:get(1))
         end)

         it('should return popped item', function()
            local array = typed.Array {2}

            assert.is.equal(2, array:pop())
         end)

         it('should rebase the array', function()
            local array = typed.Array {2, 3, 5}

            array:pop(2)

            assert.is.equal(5, array:get(2))
         end)
      end)

      describe(':forEach', function()
         it('should loop over each item', function()
            local s = spy.new(function()
            end)

            local array = typed.Array {2, 9, 3, 2}

            array:forEach(s)

            assert.spy(s).was.called(4)
            assert.spy(s).was.called_with(2, 9)
         end)
      end)

      describe(':filter', function()
         it('should loop over each item', function()
            local s = spy.new(function()
            end)

            local array = typed.Array {2, 9, 3, 2}

            array:filter(s)

            assert.spy(s).was.called(4)
            assert.spy(s).was.called_with(9)
         end)

         it('should reduce the items in the new array', function()
            local array = typed.Array {5, 2, 8, 9}

            local newArr = array:filter(function()
               return false
            end)

            assert.is.equal(0, #newArr)
         end)
      end)

      describe(':find', function()
         it('should loop over each item', function()
            local s = spy.new(function()
            end)

            local array = typed.Array {2, 9, 3, 2}

            array:find(s)

            assert.spy(s).was.called(4)
            assert.spy(s).was.called_with(9)
         end)

         it('should return the found item', function()
            local array = typed.Array {2, 8, 1, '6'}

            local item = array:find(function(v)
               return v == '6'
            end)

            assert.is.equal('6', item)
         end)
      end)

      describe(':map', function()
         it('should loop over each item', function()
            local s = spy.new(function()
            end)

            local array = typed.Array {2, 9, 3, 2}

            array:map(s)

            assert.spy(s).was.called(4)
            assert.spy(s).was.called_with(9)
         end)

         it('should change the items in the new array', function()
            local array = typed.Array {2, 7, 3, 1}

            local newArr = array:map(function(x)
               return x * 2
            end)

            assert.are.same({4, 14, 6, 2}, {newArr:unpack()})
         end)
      end)

      describe(':slice', function()
         it('should create a new array', function()
            local array = typed.Array {7, 1, 3, 1}

            local slice = array:slice()

            array:push(5)

            assert.is_nil(slice:get(5))
         end)

         it('should return a slice of the contents', function()
            local array = typed.Array {1, 6, 2, 1}

            local slice = array:slice(2, 3)

            assert.are.same({6, 2}, {slice:unpack()})
         end)
      end)

      describe(':copy', function()
         it('should create a new array', function()
            local array = typed.Array {7, 1, 3, 1}

            local copy = array:copy()

            array:push(5)

            assert.is_nil(copy:get(5))
         end)
      end)

      describe(':reverse', function()
         it('should reverse the array contents', function()
            local array = typed.Array {1, 2, 3, 4}

            local rev = array:reverse()

            assert.is.same({4, 3, 2, 1}, {rev:unpack()})
         end)
      end)
   end)

   describe('TypedArray', function()
      describe(':__init', function()
         it('should panic on invalid type', function()
            assert.has_error(function()
               typed.TypedArray()
            end, 'bad argument #1 to \'initialize\' (string expected, got nil)')
         end)

         it('should allow strings', function()
            typed.TypedArray('number')
         end)
      end)

      describe(':push', function()
         it('should panic on invalid type', function()
            assert.has_error(function()
               local arr = typed.TypedArray('number')

               arr:push()
            end, 'bad argument #1 to \'push\' (number expected, got nil)')
         end)
      end)
   end)

   describe('Schema', function()
      local schema = typed.Schema('test')
         :field('name', 'string')
         :field('id', 'number')

      describe(':validate', function()
         it('should error on invalid types', function()
            local succ = schema:validate {
               name = '3',
               id = '2'
            }

            assert.False(succ)
         end)

         it('should support nested schemas', function()
            local newSchema = typed.Schema('nested')
               :field('sub', schema)
               :field('id', 'number')

            local succ = newSchema:validate {
               sub = {
                  name = '3',
                  id = '2'
               },
               id = 2
            }

            assert.False(succ)
         end)
      end)
   end)
end)