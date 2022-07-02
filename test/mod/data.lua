
return function(callback)
    print("data")

    local pos1 = {x=0, y=0, z=0}
    local pos2 = {x=0, y=2, z=0}

    mapblock_tileset.set_mapblock_data(pos1, {x=1})
    mapblock_tileset.set_mapblock_data(pos2, {y=2})

    local data = mapblock_tileset.get_mapblock_data(pos1)
    assert(data.x == 1)
    data = mapblock_tileset.get_mapblock_data(pos2)
    assert(data.y == 2)

    mapblock_tileset.set_mapblock_data(pos1, nil)
    data = mapblock_tileset.get_mapblock_data(pos1)
    assert(not data)

    callback()
end