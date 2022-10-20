
mapblock_tileset = {}

local MP = minetest.get_modpath("mapblock_tileset")
dofile(MP .. "/api.lua")
dofile(MP .. "/data.lua")
dofile(MP .. "/common.lua")
dofile(MP .. "/place.lua")
dofile(MP .. "/tools.lua")
dofile(MP .. "/pointed.lua")

if minetest.get_modpath("mtt") then
    dofile(MP .. "/data.spec.lua")
    dofile(MP .. "/common.spec.lua")
end
