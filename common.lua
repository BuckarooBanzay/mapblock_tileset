
function mapblock_tileset.pos_to_string(pos)
    return pos.x .. "," .. pos.y .. "," .. pos.z
end

function mapblock_tileset.string_to_pos(str)
    return minetest.string_to_pos("(" .. str .. ")")
end

-- y-axis only rule-rotation
function mapblock_tileset.rotate_rules(rules, rotation)
    if rotation == 0 then
        return rules
    end
    local rotated_rules = {}

    for pos_str, rule in pairs(rules) do
        local pos = mapblock_tileset.string_to_pos(pos_str)
        local max_pos = {x=0, y=0, z=0}
        if rotation == 90 then
            mapblock_lib.flip_pos(pos, max_pos, "x")
            mapblock_lib.transpose_pos(pos, "x", "z")
        elseif rotation == 180 then
            mapblock_lib.flip_pos(pos, max_pos, "x")
            mapblock_lib.flip_pos(pos, max_pos, "z")
        elseif rotation == 270 then
            mapblock_lib.flip_pos(pos, max_pos, "z")
            mapblock_lib.transpose_pos(pos, "x", "z")
        end
        rotated_rules[mapblock_tileset.pos_to_string(pos)] = rule
    end

    return rotated_rules
end

mapblock_tileset.cardinal_directions = {
    -- same plane
    {x=1, y=0, z=0},
    {x=-1, y=0, z=0},
    {x=0, y=1, z=0},
    {x=0, y=-1, z=0},
    {x=0, y=0, z=1},
    {x=0, y=0, z=-1},
    -- lower plane
    {x=1, y=-1, z=0},
    {x=-1, y=-1, z=0},
    {x=0, y=-1, z=1},
    {x=0, y=-1, z=-1}
}

-- set the mapblock groups manually (foreign buildings for example)
function mapblock_tileset.set_mapblock_groups(mapblock_pos, groups)
    local data = mapblock_tileset.get_mapblock_data(mapblock_pos)
    data.groups = groups
    mapblock_tileset.set_mapblock_data(mapblock_pos, data)
end

-- returns true if the rules match the surroundings
function mapblock_tileset.compare_rules(mapblock_pos, rules)
    local matches = 0
    for dirname, rule in pairs(rules) do
        local rel_pos = mapblock_tileset.string_to_pos(dirname)
        local abs_pos = vector.add(mapblock_pos, rel_pos)
        local data = mapblock_tileset.get_mapblock_data(abs_pos)
        local groups = {}
        if data then
            if data.tilename then
                -- groups from tileset definition
                local tileset = mapblock_tileset.get_tileset(data.tilename)
                if tileset and tileset.groups then
                    groups = tileset.groups
                end
            elseif data.groups then
                -- groups from mapblock data
                groups = data.groups
            end
        end

        if type(rule) == "table" then
            -- table with fields

            -- group match
            for _, group in ipairs(rule.groups or {}) do
                if not groups[group] then
                    return false
                end
                matches = matches + 1
            end

            -- group non-match
            for _, not_group in ipairs(rule.not_groups or {}) do
                if groups[not_group] then
                    return false
                end
                matches = matches + 1
            end

            -- exact tilename match
            if rule.tilename then
                if not data or rule.tilename ~= data.tilename then
                    return false
                else
                    matches = matches + 1
                end
            end

            -- tilename non-match
            if rule.not_tilename then
                if data and rule.not_tilename == data.tilename then
                    return false
                else
                    matches = matches + 1
                end
            end
        end

        if type(rule) == "string" then
            -- single match with tilename
            if not data or rule ~= data.tilename then
                return false
            else
                matches = matches + 1
            end
        end
    end
    return true, matches
end

function mapblock_tileset.select_fallback(tileset)
    for _, tile in ipairs(tileset.tiles) do
        if tile.fallback then
            return tile
        end
    end
end

function mapblock_tileset.select_tile(mapblock_pos, tileset)
    local selected_tile
    local selected_matchcount = 0
    local selected_rotation = 0

    for _, tile in ipairs(tileset.tiles) do
        for _, rotation in ipairs(tile.rotations) do
            local rules = mapblock_tileset.rotate_rules(tile.rules, rotation)
            local match, matchcount = mapblock_tileset.compare_rules(mapblock_pos, rules)
            if match and matchcount > selected_matchcount then
                selected_rotation = rotation
                selected_tile = tile
                selected_matchcount = matchcount
            end
        end
    end

    if not selected_tile then
        selected_tile = mapblock_tileset.select_fallback(tileset)
        selected_rotation = 0
    end

    return selected_tile, selected_rotation
end