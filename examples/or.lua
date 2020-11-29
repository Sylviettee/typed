local typed = require 'typed'

local function hi(msg)
   -- We see the use of `|` to allow strings **or** numbers
   typed.func(_, 'string | number')(msg)

   print(msg)
end

hi('hello') -- No errors
hi(1) -- No errors