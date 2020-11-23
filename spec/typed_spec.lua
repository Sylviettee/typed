local typed = require 'typed'

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
      -- Prevents exiting program
      _G._TEST = true
      
      os.exit = function() error(os.error) end

      it('should automatically resolve function name', function() 
         local function hi()
            typed.func(_, 'string')()
         end

         assert.has.error(function() 
            hi() 
         end, 'bad argument #1 to \'hi\' (string expected, got nil)')
      end)
   end)
end)