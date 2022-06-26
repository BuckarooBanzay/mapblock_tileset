
local tilesets = {}

function mapblock_tileset.register_tileset(name, tileset_def)
    tileset_def.name = name
    tilesets[name] = tileset_def
end

function mapblock_tileset.get_tileset(name)
    return tilesets[name]
end

function mapblock_tileset.get_tilesets()
    return tilesets
end

local placements = {}

function mapblock_tileset.register_placement(name, placement_def)
    placement_def.name = name
    placements[name] = placement_def
end

function mapblock_tileset.get_placement(name)
    return placements[name]
end