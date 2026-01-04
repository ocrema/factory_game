local Levels = {}

Levels.defaultCharacterDefinitions = {}
Levels.defaultCharacterDefinitions[" "] = {tile = "void", locked = true}
Levels.defaultCharacterDefinitions["#"] = {tile = "wall", locked = true}
Levels.defaultCharacterDefinitions["."] = {tile = "empty"}

table.insert(Levels, {
    name = "Level 1",
    layout = [[
#########
#.......#
#A.....B#
#.......#
#########]],
    A = {tile = "input", locked = true, rotation = 0, timeBetweenInputs = 3, input = "red_block"},
    B = {tile = "output", locked = true, rotation = 0, output = "red_block"},
})

table.insert(Levels, {
    name = "Level 2",
    layout = [[
###########
#.........#
#A....#...#
#.....#...#
#######...#
      #...#
      #.B.#
      #####]],
    A = {tile = "input", locked = true, rotation = 0, timeBetweenInputs = 3, input = "green_block"},
    B = {tile = "output", locked = true, rotation = 0, output = "green_block"},
})

table.insert(Levels, {
    name = "Level 3",
    layout = [[
#######
#..A..#
#.....#######
#...........#
#.........BB#
#...........#
#############]],
    A = {tile = "input", locked = true, rotation = 1, timeBetweenInputs = 2, input = "blue_block"},
    B = {tile = "output", locked = true, rotation = 0, output = "blue_block"},
})

for i = 1, #Levels do
    for char, definition in pairs(Levels.defaultCharacterDefinitions) do
        if not Levels[i][char] then
            Levels[i][char] = definition
        end
    end
end

return Levels