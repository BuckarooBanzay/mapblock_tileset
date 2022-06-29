
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
        if rotation == 90 then
            mapblock_tileset.flip_pos(pos, "x")
            mapblock_tileset.transpose_pos(pos, "x", "z")
        elseif rotation == 180 then
            mapblock_tileset.flip_pos(pos, "x")
            mapblock_tileset.flip_pos(pos, "z")
        elseif rotation == 270 then
            mapblock_tileset.flip_pos(pos, "z")
            mapblock_tileset.transpose_pos(pos, "x", "z")
        end
        rotated_rules[mapblock_tileset.pos_to_string(pos)] = rule
    end

    return rotated_rules
end

function mapblock_tileset.flip_pos(rel_pos, axis)
	rel_pos[axis] = 0 - rel_pos[axis]
end

function mapblock_tileset.transpose_pos(rel_pos, axis1, axis2)
	rel_pos[axis1], rel_pos[axis2] = rel_pos[axis2], rel_pos[axis1]
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

-- returns true if the rules match the surroundings
function mapblock_tileset.compare_rules(mapblock_pos, rules, get_mapblock_data)
    local matches = 0
    for dirname, rule in pairs(rules) do
        local rel_pos = mapblock_tileset.string_to_pos(dirname)
        local abs_pos = vector.add(mapblock_pos, rel_pos)
        local data = get_mapblock_data(abs_pos)
        local groups = {}
        if data and data.tilename then
            local tileset = mapblock_tileset.get_tileset(data.tilename)
            if tileset and tileset.groups then
                groups = tileset.groups
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