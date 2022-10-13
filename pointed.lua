
-- playername -> mapblock_pos
local last_pointed_positions = {}

-- playername -> os.time()
local last_updated = {}

function mapblock_tileset.get_pointed_position(player)
    return mapblock_lib.get_pointed_position(player, 2)
end

-- clear marker
local function clear_pointed_position(player)
    local playername = player:get_player_name()
    local last_pointed_position = last_pointed_positions[playername]
    if last_pointed_position then
        local center = mapblock_lib.get_mapblock_center(vector.multiply(last_pointed_position, 16))
        local objects = minetest.get_objects_inside_radius(center, 1)
        for _, object in ipairs(objects) do
            if object:get_luaentity().name == "mapblock_lib:display" then
                -- remove mapblock display objects
                object:remove()
            end
        end
    end
    last_pointed_positions[playername] = nil
    last_updated[playername] = nil
end

-- update or clear marker
local function pointed_player_display(player, text)
    local playername = player:get_player_name()
    local last_pointed_position = last_pointed_positions[playername]
    local mapblock_pos = mapblock_tileset.get_pointed_position(player)

    if last_pointed_position and not vector.equals(last_pointed_position, mapblock_pos) then
        -- position moved, remove old entity
        clear_pointed_position(player)
    end

    local now = os.time()
    if last_updated[playername] and (last_updated[playername] + 2) > now then
        -- recently updated, skip
        return
    end

    -- refresh entity
    mapblock_lib.display_mapblock_at_mapblock_pos(mapblock_pos, text, 2)
    last_pointed_positions[playername] = mapblock_pos
    last_updated[playername] = now
end

-- check for tools
local function pointed_check()
    for _, player in ipairs(minetest.get_connected_players()) do
        local itemstack = player:get_wielded_item()
        local name = itemstack and itemstack:get_name()
        if name == "mapblock_tileset:place" then
            pointed_player_display(player, "Place")
        elseif name == "mapblock_tileset:remove" then
            pointed_player_display(player, "Remove")
        else
            clear_pointed_position(player)
        end
    end
    minetest.after(0, pointed_check)
end

minetest.after(0, pointed_check)
minetest.register_on_leaveplayer(clear_pointed_position)