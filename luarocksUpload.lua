-- Generates the rockspec needed for LuaRocks

local f = string.format

local function trim(str)
   return string.match(str, '^%s*(.-)%s*$')
end

local tmp = os.tmpname()

os.execute("git describe --exact-match --tags $(git log -n1 --pretty='%h') &> " .. tmp)

local file = io.open(tmp)
local tag = trim(file:read("*a"))
file:close()

os.remove(tmp) -- Cleanup

if tag:match('fatal') then
   print('Error getting tag, are you on a tagged commit?')
   os.exit(-1)
end

local gitTag = tag

tag = tag:gsub('v', '')

if not tag:match('%-') then
   tag = tag .. '-0'
end

local spec = f([[
package = "typed"
version = "%s"

source = {
   url = "git://github.com/SovietKitsune/typed",
   tag = "%s"
}

description = {
   summary = "Typed is a module to aid in allowing for typed code",

   detailed = "Typed gives clean errors that look like errors from misused standard functions",

   homepage = "https://github.com/SovietKitsune/typed",
   license = "MIT"
}

dependencies = {
   "middleclass"
}

build = {
   type = "builtin",
   modules = {
      typed = "typed.lua"
   }
}
]], tag, gitTag)

local location = "./rockspecs/typed-" .. tag .. '.rockspec'

local rockspec = io.open(location, "w+")
rockspec:write(spec)
rockspec:close()

local upload = io.popen("luarocks upload " .. location .. " --api-key=" .. os.getenv("API_KEY"))

for line in upload:lines() do
   print(line)
end

assert(upload:close())