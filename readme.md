# mapblock_tileset

Tileset placement engine for minetest

![](https://github.com/BuckarooBanzay/mapblock_tileset/workflows/luacheck/badge.svg)
![](https://github.com/BuckarooBanzay/mapblock_tileset/workflows/test/badge.svg)
[![License](https://img.shields.io/badge/License-MIT%20and%20CC%20BY--SA%203.0-green.svg)](license.txt)
[![Download](https://img.shields.io/badge/Download-ContentDB-blue.svg)](https://content.minetest.net/packages/BuckarooBanzay/mapblock_tileset)

<img src="./screenshot.png"/>

(buildings and streets not included)

# Overview

Places mapblocks from a mapblock-catalog to the world according to the predefined rules

# Dependencies

* `mapblock_lib` https://github.com/BuckarooBanzay/mapblock_lib

# Api

Tileset and rules for a simple street, for more examples see: https://github.com/BuckarooBanzay/mapblock_tileset_city

Placement via the `mapblock_tileset:place` tool or the `/tile_place` command, in this example: `/tile_place street`

```lua
local MP = minetest.get_modpath(minetest.get_current_modname())

mapblock_tileset.register_tileset("street", {
    -- the location of the mapblock catalog
    catalog = MP .. "/schematics/street.zip",
    groups = {
        -- the groups can be referenced in a foreign ruleset
        street = true
    },
    tiles = {
        -- all sides tile/street
        {
            -- the position(s) of the mapblocks in the catalog, picked randomly
            positions = {{x=0,y=0,z=0}},
            -- the rules that have to match before placing the tile
            -- the rule-index is a position in the "x,y,z" format
            -- the rule-positions get transformed/rotated according to available `rotations` below
            rules = {
                -- match the neighboring tiles with `group = street`
                ["1,0,0"] = { groups = {"street"} },
                ["-1,0,0"] = { groups = {"street"} },
                ["0,0,1"] = { groups = {"street"} },
                ["0,0,-1"] = { groups = {"street"} }
            },
            -- default tile, will be place if no other tile matches
            fallback = true,
            -- y-rotations to search and apply for
            rotations = {0}
        },{
            -- straight street tile
            positions = {{x=1,y=0,z=0}},
            rules = {
                ["1,0,0"] = { groups = {"street"} },
                ["-1,0,0"] = { groups = {"street"} }
            },
            -- straight street only has to be rotated by 0 and 90 degrees
            rotations = {0,90}
        },{
            -- three sides tile
            positions = {{x=2,y=0,z=0}},
            rules = {
                ["1,0,0"] = { groups = {"street"} },
                ["-1,0,0"] = { groups = {"street"} },
                ["0,0,1"] = { groups = {"street"} }
            },
            -- all rotations are possible
            rotations = {0,90,180,270}
        },{
            -- corner tile
            positions = {{x=3,y=0,z=0}},
            rules = {
                ["-1,0,0"] = { groups = {"street"} },
                ["0,0,1"] = { groups = {"street"} }
            },
            -- all rotations are possible
            rotations = {0,90,180,270}
        }
    }
})
```

# License

* Code: `MIT`
* Textures: `CC-BY-SA-3.0`