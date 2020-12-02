-- Generates the package.lua needed by lit
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

os.rename('typed.lua', 'init.lua') -- We need to upload a package.lua since of middleclass.lua

local package = f([[
return {
   name = "SovietKitsune/typed",
   version = "%s",
   description = "A module to aid in allowing for typed code.",
   tags = { "lua", "types" },
   license = "MIT",
   author = { name = "Soviet Kitsune", email = "sovietkitsune@soviet.solutions" },
   homepage = "https://github.com/SovietKitsune/typed",
   dependencies = {},
   files = {
      "**.lua",
      "!spec*"
   }
}
]], tag)

local packageFile = io.open('package.lua', "w+")
packageFile:write(package)
packageFile:close()