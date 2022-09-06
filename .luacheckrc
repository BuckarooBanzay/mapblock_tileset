globals = {
	"mapblock_tileset"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"minetest",
	"ItemStack",
	"dump", "dump2",
	"VoxelArea",
	"vector",

	-- deps
	"mapblock_lib", "mtt"
}
