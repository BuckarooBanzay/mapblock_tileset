
local tilesets = {}
local categories = {}

function mapblock_tileset.register_tileset(name, tileset_def)
    tileset_def.name = name
    tileset_def.category = tileset_def.category or "default"
    tilesets[name] = tileset_def

    for _, c in ipairs(categories) do
        if c == tileset_def.category then
            -- category already exists
            return
        end
    end
    table.insert(categories, tileset_def.category)
end

function mapblock_tileset.get_categories()
    return categories
end

function mapblock_tileset.get_tileset(name)
    return tilesets[name]
end

function mapblock_tileset.get_tilesets()
    return tilesets
end

function mapblock_tileset.get_tileset_list_by_category(category)
    local list = {}
    for _, tileset_def in pairs(tilesets) do
        if tileset_def.category == category then
            table.insert(list, tileset_def)
        end
    end
    table.sort(list, function(a,b) return a.name < b.name end)
    return list
end
