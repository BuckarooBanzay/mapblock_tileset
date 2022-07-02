
return function(callback)
    print("common_compare_rules")

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
end