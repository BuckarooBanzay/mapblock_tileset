
function mapblock_tileset.pos_to_string(pos)
    return pos.x .. "," .. pos.y .. "," .. pos.z
end

function mapblock_tileset.string_to_pos(str)
    return minetest.string_to_pos("(" .. str .. ")")
end

function mapblock_tileset.rotate_position_y(pos, max_pos, rotation)
    local new_pos = table.copy(pos)
    if rotation == 90 then
        mapblock_lib.flip_pos(new_pos, max_pos, "x")
        mapblock_lib.transpose_pos(new_pos, "x", "z")
    elseif rotation == 180 then
        mapblock_lib.flip_pos(new_pos, max_pos, "x")
        mapblock_lib.flip_pos(new_pos, max_pos, "z")
    elseif rotation == 270 then
        mapblock_lib.flip_pos(new_pos, max_pos, "z")
        mapblock_lib.transpose_pos(new_pos, "x", "z")
    end
    return new_pos
end

-- y-axis only connection-rotation
function mapblock_tileset.rotate_connections(connections, size, rotation)
    if rotation == 0 then
        return connections
    end
    local rotated_connections = {}

    for i, connection in ipairs(connections) do
        local new_connection = table.copy(connection)
        -- copy position and direction vector
        new_connection.position = table.copy(connection.position or {x=0,y=0,z=0})
        new_connection.direction = table.copy(connection.direction)

        local max_pos = vector.subtract(size, 1)
        new_connection.position = mapblock_tileset.rotate_position_y(new_connection.position, max_pos, rotation)
        new_connection.direction = mapblock_tileset.rotate_position_y(new_connection.direction, {x=0,y=0,z=0}, rotation)
        table.insert(rotated_connections, new_connection)
    end

    return rotated_connections
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

-- returns true if the connections match the surroundings
function mapblock_tileset.compare_connections(mapblock_pos, connections)
    local matches = 0
    for _, connection in ipairs(connections) do
        connection.position = connection.position or {x=0,y=0,z=0}
        local abs_pos = vector.add( vector.add(mapblock_pos, connection.position), connection.direction )
        local data = mapblock_tileset.get_mapblock_data(abs_pos)
        local groups = {}
        if data and data.tilename then
            local tileset = mapblock_tileset.get_tileset(data.tilename)
            if tileset and tileset.groups then
                groups = tileset.groups
            end
        end

        -- group match
        for _, group in ipairs(connection.groups or {}) do
            if not groups[group] then
                if not connection.optional then
                    return false
                end
            else
                matches = matches + 1
            end
        end

        -- group non-match
        for _, not_group in ipairs(connection.not_groups or {}) do
            if groups[not_group] then
                if not connection.optional then
                    return false
                end
            else
                matches = matches + 1
            end
        end

        -- exact tilename match
        if connection.tilename then
            if not data or connection.tilename ~= data.tilename then
                if not connection.optional then
                    return false
                end
            else
                matches = matches + 1
            end
        end

        -- tilename non-match
        if connection.not_tilename then
            if data and connection.not_tilename == data.tilename then
                if not connection.optional then
                    return false
                end
            else
                matches = matches + 1
            end
        end

    end
    return true, matches
end

function mapblock_tileset.select_tile(mapblock_pos, tileset)
    local selected_tile
    local selected_matchcount = -1
    local selected_rotation = 0

    for _, tile in ipairs(tileset.tiles) do
        local size = tile.size or {x=1,y=1,z=1}
        for _, rotation in ipairs(tile.rotations) do
            local connections = mapblock_tileset.rotate_connections(tile.connections, size, rotation)
            local match, matchcount = mapblock_tileset.compare_connections(mapblock_pos, connections)
            if match and matchcount > selected_matchcount then
                selected_rotation = rotation
                selected_tile = tile
                selected_matchcount = matchcount
            end
        end
    end

    return selected_tile, selected_rotation
end