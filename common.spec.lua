
mtt.register("common_compare_rules", function(callback)
    mapblock_tileset.register_tileset("mytile", {
        groups = {
            a = true
        }
    })

    mapblock_tileset.set_mapblock_data({x=1,y=0,z=0}, { tilename="mytile" })

    -- group match
    local rules = {
        ["1,0,0"] = { groups = {"a"} }
    }
    local match, match_count = mapblock_tileset.compare_rules({x=0, y=0, z=0}, rules)
    assert(match)
    assert(match_count == 1)

    -- group does not match
    rules = {
        ["1,0,0"] = { not_groups = {"a"} }
    }
    match, match_count = mapblock_tileset.compare_rules({x=0, y=0, z=0}, rules)
    assert(not match)
    assert(match_count == nil)

    -- tilename match
    rules = {
        ["1,0,0"] = { tilename = "mytile" }
    }
    match, match_count = mapblock_tileset.compare_rules({x=0, y=0, z=0}, rules)
    assert(match)
    assert(match_count == 1)

    -- tilename match (string rule)
    rules = {
        ["1,0,0"] = "mytile"
    }
    match, match_count = mapblock_tileset.compare_rules({x=0, y=0, z=0}, rules)
    assert(match)
    assert(match_count == 1)

    -- tilename does not match
    rules = {
        ["1,0,0"] = { tilename = "not-mytile" }
    }
    match, match_count = mapblock_tileset.compare_rules({x=0, y=0, z=0}, rules)
    assert(not match)
    assert(match_count == nil)

    callback()
end)


mtt.register("common_rotate_rules", function(callback)
    local rules = {
        ["1,0,0"] = {id=1},
        ["0,0,1"] = {id=2},
        ["0,0,3"] = {id=3}
    }

    local rotated_rules = mapblock_tileset.rotate_rules(rules, 90)
    assert(rotated_rules["0,0,-1"].id == 1)
    assert(rotated_rules["1,0,0"].id == 2)
    assert(rotated_rules["3,0,0"].id == 3)

    rotated_rules = mapblock_tileset.rotate_rules(rules, 180)
    assert(rotated_rules["-1,0,0"].id == 1)
    assert(rotated_rules["0,0,-1"].id == 2)
    assert(rotated_rules["0,0,-3"].id == 3)

    rotated_rules = mapblock_tileset.rotate_rules(rules, 270)
    assert(rotated_rules["0,0,1"].id == 1)
    assert(rotated_rules["-1,0,0"].id == 2)
    assert(rotated_rules["-3,0,0"].id == 3)

    callback()
end)

mtt.register("common_select_tile", function(callback)
    mapblock_tileset.register_tileset("mytile_1", {
        groups = {
            a = true
        }
    })

    mapblock_tileset.register_tileset("mytile_2", {
        catalog = "",
        tiles = {
            {
                positions = {x=1,y=0,z=0},
                rules = {
                    ["0,0,1"] = { groups = {"a"}}
                },
                rotations = {0,90,180,270}
            }
        }
    })

    local success = mapblock_tileset.place({x=10,y=0,z=0}, "mytile_1")
    assert(success)

    local tileset = mapblock_tileset.get_tileset("mytile_2")
    assert(tileset)

    -- rotated match
    local selected_tile, selected_rotation = mapblock_tileset.select_tile({x=11, y=0,z=0}, tileset)
    assert(selected_tile)
    assert(selected_rotation == 270)

    selected_tile, selected_rotation = mapblock_tileset.select_tile({x=9, y=0,z=0}, tileset)
    assert(selected_tile)
    assert(selected_rotation == 90)

    selected_tile, selected_rotation = mapblock_tileset.select_tile({x=10, y=0,z=-1}, tileset)
    assert(selected_tile)
    assert(selected_rotation == 0)

    -- no match
    selected_tile = mapblock_tileset.select_tile({x=999, y=0,z=0}, tileset)
    assert(not selected_tile)

    callback()
end)