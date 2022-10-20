
mtt.register("common_compare_rules", function(callback)
    mapblock_tileset.register_tileset("mytile", {
        connections = {
            {
                type = "a",
                direction = {x=1,y=0,z=0},
            }
        }
    })

    mapblock_tileset.set_mapblock_data({x=1,y=0,z=0}, { tilename="mytile" })

    local connections = {
        {
            type = "a",
            direction = {x=1,y=0,z=0}
        }
    }
    local match, match_count = mapblock_tileset.compare_connections({x=0, y=0, z=0}, connections)
    assert(match)
    assert(match_count == 1)

    callback()
end)

mtt.register("common_rotate_rotate_position_y", function(callback)
    local pos = {x=0,y=0,z=3}
    local max_pos = {x=3,y=0,z=3}

    local rot_pos = mapblock_tileset.rotate_position_y(pos, max_pos, 90)
    assert(rot_pos.x == 3)
    assert(rot_pos.y == 0)
    assert(rot_pos.z == 3)

    rot_pos = mapblock_tileset.rotate_position_y(pos, max_pos, 180)
    assert(rot_pos.x == 3)
    assert(rot_pos.y == 0)
    assert(rot_pos.z == 0)

    rot_pos = mapblock_tileset.rotate_position_y(pos, max_pos, 270)
    assert(rot_pos.x == 0)
    assert(rot_pos.y == 0)
    assert(rot_pos.z == 0)

    callback()
end)

mtt.register("common_rotate_connections", function(callback)
    local connections = {
        {
            direction = {x=1,y=0,z=0},
            id = 1
        },{
            position = {x=0,y=0,z=0},
            direction = {x=0,y=0,z=1},
            id = 2
        },{
            position = {x=0,y=0,z=3},
            direction = {x=0,y=0,z=1},
            id = 3
        }
    }

    local size = {x=4,y=1,z=4}

    local rotated_connections = mapblock_tileset.rotate_connections(connections, size, 90)
    assert(rotated_connections[1].direction.x == 0)
    assert(rotated_connections[1].direction.z == -1)
    assert(rotated_connections[2].direction.x == 1)
    assert(rotated_connections[2].direction.z == 0)
    assert(rotated_connections[3].position.x == 3)
    assert(rotated_connections[3].position.z == 3)
    assert(rotated_connections[3].direction.x == 1)
    assert(rotated_connections[3].direction.z == 0)

    rotated_connections = mapblock_tileset.rotate_connections(connections, size, 180)
    assert(rotated_connections[1].direction.x == -1)
    assert(rotated_connections[1].direction.z == 0)
    assert(rotated_connections[2].direction.x == 0)
    assert(rotated_connections[2].direction.z == -1)
    assert(rotated_connections[3].position.x == 3)
    assert(rotated_connections[3].position.z == 0)
    assert(rotated_connections[3].direction.x == 0)
    assert(rotated_connections[3].direction.z == -1)

    rotated_connections = mapblock_tileset.rotate_connections(connections, size, 270)
    assert(rotated_connections[1].direction.x == 0)
    assert(rotated_connections[1].direction.z == 1)
    assert(rotated_connections[2].direction.x == -1)
    assert(rotated_connections[2].direction.z == 0)
    assert(rotated_connections[3].position.x == 0)
    assert(rotated_connections[3].position.z == 0)
    assert(rotated_connections[3].direction.x == -1)
    assert(rotated_connections[3].direction.z == 0)

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
                position = {x=1,y=0,z=0},
                connections = {
                    {
                        direction = {x=0,y=0,z=1},
                        groups = {"a"}
                    }
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