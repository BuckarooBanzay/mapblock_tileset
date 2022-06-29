
return function(callback)
    print("common_compare_rules")

    mapblock_tileset.register_tileset("mytile", {
        groups = {
            a = true
        }
    })

    local mapdata = {
        ["1,0,0"] = { tilename="mytile" }
    }

    local function get_mapblock_data(mapblock_pos)
        local pos_str = mapblock_tileset.pos_to_string(mapblock_pos)
        return mapdata[pos_str]
    end

    -- group match
    local rules = {
        ["1,0,0"] = { groups = {"a"} }
    }
    local match, match_count = mapblock_tileset.compare_rules({x=0, y=0, z=0}, rules, get_mapblock_data)
    assert(match)
    assert(match_count == 1)

    -- group does not match
    rules = {
        ["1,0,0"] = { not_groups = {"a"} }
    }
    match, match_count = mapblock_tileset.compare_rules({x=0, y=0, z=0}, rules, get_mapblock_data)
    assert(not match)
    assert(match_count == nil)

    callback()
end