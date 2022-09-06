local store = mapblock_lib.create_data_storage(minetest.get_mod_storage())

function mapblock_tileset.get_mapblock_data(mapblock_pos)
    return store:get(mapblock_pos)
end

function mapblock_tileset.set_mapblock_data(mapblock_pos, data)
    store:set(mapblock_pos, data)
end

minetest.register_chatcommand("tileset_info", {
    func = function(name)
        local player = minetest.get_player_by_name(name)
        local ppos = player:get_pos()
        local mapblock_pos = mapblock_lib.get_mapblock(ppos)
        local data = mapblock_tileset.get_mapblock_data(mapblock_pos)
        return true, "Data for mapblock " .. minetest.pos_to_string(mapblock_pos) .. ": " .. dump(data)
    end
})