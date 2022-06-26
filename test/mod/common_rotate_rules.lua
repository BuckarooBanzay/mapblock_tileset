
return function(callback)
    print("common_rotate_rules")

    local rules = {
        ["1,0,0"] = {id=1},
        ["0,0,1"] = {id=2},
        ["0,0,3"] = {id=3}
    }

    local rotated_rules = mapblock_tileset.rotate_rules(rules, 90)
    assert(rotated_rules["0,0,-1"].id == 1)
    assert(rotated_rules["1,0,0"].id == 2)
    assert(rotated_rules["3,0,0"].id == 3)

    rotated_rules = mapblock_tileset.rotate_rules(rules, 180)
    assert(rotated_rules["-1,0,0"].id == 1)
    assert(rotated_rules["0,0,-1"].id == 2)
    assert(rotated_rules["0,0,-3"].id == 3)

    rotated_rules = mapblock_tileset.rotate_rules(rules, 270)
    assert(rotated_rules["0,0,1"].id == 1)
    assert(rotated_rules["-1,0,0"].id == 2)
    assert(rotated_rules["-3,0,0"].id == 3)

    callback()
end