
local formname = "mapblock_tileset_placer_configure"

local function get_formspec(itemstack)
    local meta = itemstack:get_meta()
    local selected_category = meta:get_string("category") or "default"

    local tileset_list = mapblock_tileset.get_tileset_list_by_category(selected_category)

    local selected_tilesetname = meta:get_string("tilesetname")
    if not selected_tilesetname or selected_tilesetname == "" then
        selected_tilesetname = tileset_list[1]
    end

    local selected_tileset = 1
    local textlist = ""

    for i, tileset_def in ipairs(tileset_list) do
        local tilesetname = tileset_def.name
        if selected_tilesetname == tilesetname then
            selected_tileset = i
        end

        textlist = textlist .. tilesetname
        if i < #tileset_list then
            textlist = textlist .. ","
        end
    end

    local categories = mapblock_tileset.get_categories()
    local selected_category_index = 1
    local cat_list = ""

    for i, category in ipairs(categories) do
        if category == selected_category then
            selected_category_index = i
        end

        cat_list = cat_list .. category
        if i < #categories then
            cat_list = cat_list .. ","
        end
    end

    return "size[8,7;]" ..
        "dropdown[0,0.1;8;category;" .. cat_list .. ";" .. selected_category_index .. "]" ..
        "textlist[0,1.1;8,5;tilesetname;" .. textlist .. ";" .. selected_tileset .. "]" ..
        "button_exit[0.1,6.5;8,1;back;Back]"
end

minetest.register_on_player_receive_fields(function(player, f, fields)
    if not minetest.check_player_privs(player, { mapblock_lib = true }) then
        return
    end
    if formname ~= f then
        return
    end
    if fields.quit then
        return
    end

    if fields.tilesetname then
        local parts = fields.tilesetname:split(":")
        if parts[1] == "CHG" then
            local itemstack = player:get_wielded_item()
            local meta = itemstack:get_meta()

            local selected = tonumber(parts[2])
            local selected_category = meta:get_string("category") or "default"
            local tileset_list = mapblock_tileset.get_tileset_list_by_category(selected_category)
            local tileset_def = tileset_list[selected]
            if not tileset_def then
                return
            end

            meta:set_string("tilesetname", tileset_def.name)
            meta:set_string("description", "Selected tileset: '" .. tileset_def.name .. "'")
            player:set_wielded_item(itemstack)
        end

    elseif fields.category then
        local itemstack = player:get_wielded_item()
        local meta = itemstack:get_meta()
        meta:set_string("category", fields.category)
        player:set_wielded_item(itemstack)
        minetest.show_formspec(player:get_player_name(), formname, get_formspec(itemstack))
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
        local mapblock_pos = mapblock_tileset.get_pointed_position(player)
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
        local mapblock_pos = mapblock_tileset.get_pointed_position(player)
        mapblock_tileset.remove(mapblock_pos)
        mapblock_tileset.update_surroundings(mapblock_pos)
    end
})