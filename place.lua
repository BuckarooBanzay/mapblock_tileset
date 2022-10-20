
function mapblock_tileset.remove(mapblock_pos)
    mapblock_lib.clear_mapblock(mapblock_pos)
    mapblock_tileset.set_mapblock_data(mapblock_pos, nil)
end

function mapblock_tileset.place(mapblock_pos, tileset_name)
    local tileset = mapblock_tileset.get_tileset(tileset_name)
    if not tileset then
        return false, "tileset not found: " .. tileset_name
    end

    if not tileset.tiles or not tileset.catalog then
        -- dummy tile, just set data and return
        mapblock_tileset.set_mapblock_data(mapblock_pos, {
            tilename = tileset_name,
            tilerotation = 0
        })
        return true
    end

    local selected_tile, selected_rotation = mapblock_tileset.select_tile(mapblock_pos, tileset)

    if selected_tile then
        local catalog, catalog_err = mapblock_lib.get_catalog(tileset.catalog)
        if catalog_err then
            return nil, "get_catalog error: " .. catalog_err
        end
        if selected_tile.positions and #selected_tile.positions > 0 then
            -- set mapblock
            local tilepos = selected_tile.positions[math.random(#selected_tile.positions)]
            local success, err = catalog:deserialize(tilepos, mapblock_pos, {
                transform = {
                    rotate = {
                        angle = selected_rotation,
                        axis = "y",
                        disable_orientation = selected_tile.disable_orientation or tileset.disable_orientation
                    },
                    replace = selected_tile.replace or tileset.replace
                },
                on_metadata = tileset.on_metadata
            })
            if not success then
                return false, err
            end
        else
            -- clear mapblock
            mapblock_lib.clear_mapblock(mapblock_pos)
        end
        mapblock_tileset.set_mapblock_data(mapblock_pos, {
            tilename = tileset_name,
            tilerotation = selected_rotation
        })
        return true
    end

    return false, "no matching tile found"
end

function mapblock_tileset.update_surroundings(mapblock_pos)
    for _, dir in ipairs(mapblock_tileset.cardinal_directions) do
        local neighbor_pos = vector.add(mapblock_pos, dir)
        local data = mapblock_tileset.get_mapblock_data(neighbor_pos)
        if data and data.tilename then
            local success, err = mapblock_tileset.place(neighbor_pos, data.tilename)
            if not success then
                return success, err
            end
        end
    end

    return true
end

minetest.register_chatcommand("tile_place", {
    privs = { mapblock_lib = true },
    func = function(name, tileset_name)
        local pos1 = mapblock_lib.get_pos(1, name)
        local pos2 = mapblock_lib.get_pos(2, name)
        if not pos1 or not pos2 then
            return false, "select /mapblock_pos1 and /mapblock_pos2 first"
        end

        pos1, pos2 = mapblock_lib.sort_pos(pos1, pos2)
        local it = mapblock_lib.pos_iterator(pos1, pos2)
        local worker
        worker = function()
            local mapblock_pos = it()
            if not mapblock_pos then
                minetest.chat_send_player(name, "Placement done")
                return
            end

            local success, err = mapblock_tileset.place(mapblock_pos, tileset_name)
            if not success then
                minetest.chat_send_player(name, "Placement failed: " .. err)
                return
            end
            mapblock_tileset.update_surroundings(mapblock_pos)
            minetest.after(0.1, worker)
        end

        worker()
    end
})

minetest.register_chatcommand("tile_remove", {
    privs = { mapblock_lib = true },
    func = function(name)
        local pos1 = mapblock_lib.get_pos(1, name)
        local pos2 = mapblock_lib.get_pos(2, name)
        if not pos1 or not pos2 then
            return false, "select /mapblock_pos1 and /mapblock_pos2 first"
        end

        pos1, pos2 = mapblock_lib.sort_pos(pos1, pos2)
        local it = mapblock_lib.pos_iterator(pos1, pos2)
        local worker
        worker = function()
            local mapblock_pos = it()
            if not mapblock_pos then
                minetest.chat_send_player(name, "Placement done")
                return
            end

            mapblock_tileset.remove(mapblock_pos)
            mapblock_tileset.update_surroundings(mapblock_pos)
            minetest.after(0.1, worker)
        end

        worker()
    end
})