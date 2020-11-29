local typed = require 'typed'

local function hi(msg)
   typed.func(_, 'string')(msg)

   print(msg)
end

hi('hello') -- No errors
hi(1) -- bad argument #1 to 'hi' (string expected, got number)