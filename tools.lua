
local formname = "mapblock_tileset_placer_configure"

local tileset_list = {}
minetest.register_on_mods_loaded(function()
    for tilesetname in pairs(mapblock_tileset.get_tilesets()) do
        table.insert(tileset_list, tilesetname)
    end
    table.sort(tileset_list)
end)

local function get_formspec(itemstack)
    local meta = itemstack:get_meta()
    local selected_tilesetname = meta:get_string("tilesetname")
    if not selected_tilesetname or selected_tilesetname == "" then
        selected_tilesetname = tileset_list[1]
    end

    local selected = 1
    local list = ""

    for i, tilesetname in ipairs(tileset_list) do
        if selected_tilesetname == tilesetname then
            selected = i
        end

        list = list .. tilesetname
        if i < #tileset_list then
            list = list .. ","
        end
    end

    return "size[8,6;]" ..
        "textlist[0,0.1;8,5;tilesetname;" .. list .. ";" .. selected .. "]" ..
        "button_exit[0.1,5.5;8,1;back;Back]"
end

minetest.register_on_player_receive_fields(function(player, f, fields)
    if not minetest.check_player_privs(player, { mapblock_lib = true }) then
        return
    end
    if formname ~= f then
        return
    end

    if fields.tilesetname then
        local parts = fields.tilesetname:split(":")
        if parts[1] == "CHG" then
            local selected = tonumber(parts[2])
            local tilesetname = tileset_list[selected]
            local itemstack = player:get_wielded_item()
            local meta = itemstack:get_meta()
            meta:set_string("tilesetname", tilesetname)
            meta:set_string("description", "Selected tileset: '" .. tilesetname .. "'")
            player:set_wielded_item(itemstack)
        end
    end
end)

minetest.register_tool("mapblock_tileset:place", {
    description = "Mapblock tile placer",
    inventory_image = "mapblock_tileset_place.png",
    stack_max = 1,
    range = 0,
    on_secondary_use = function(itemstack, player)
        minetest.show_formspec(player:get_player_name(), formname, get_formspec(itemstack))
    end,
    on_use = function(itemstack, player)
        local meta = itemstack:get_meta()
        local tilesetname = meta:get_string("tilesetname")
        if not mapblock_tileset.get_tileset(tilesetname) then
            minetest.chat_send_player(
                player:get_player_name(),
                "Placer unconfigured or selected tileset not found"
            )
            return
        end
        local ppos = player:get_pos()
        local mapblock_pos = mapblock_lib.get_mapblock(ppos)
        local success, err = mapblock_tileset.place(mapblock_pos, tilesetname)
        if not success then
            minetest.chat_send_player(player:get_player_name(), err)
            return
        end

        success, err = mapblock_tileset.update_surroundings(mapblock_pos)
        if not success then
            minetest.chat_send_player(player:get_player_name(), err)
            return
        end
    end
})

minetest.register_tool("mapblock_tileset:remove", {
    description = "Mapblock tile remover",
    inventory_image = "mapblock_tileset_remove.png",
    stack_max = 1,
    range = 0,
    on_use = function(_, player)
        local ppos = player:get_pos()
        local mapblock_pos = mapblock_lib.get_mapblock(ppos)
        mapblock_tileset.remove(mapblock_pos)
        mapblock_tileset.update_surroundings(mapblock_pos)
    end
})