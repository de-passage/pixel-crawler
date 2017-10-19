module.exports = (map) ->
  return (->) unless process.env["VERBOSE"]
  ->
    display = []
    for i in [0...10]
      temp = []
      for j in [0...10]
        push = null
        # The coordinates are inverted to iterate through the width first. The second parameter
        # represents the vertical axis, but we want to build lines instead of columns in the inner loop
        if map.terrainAt(j,i).property "seethrough"
          push = "."
        else
          push = "#"
        if (e = map.entitiesAt(j,i)).length > 0
          if e.length > 1
            c = 0
            for el in e
              if !el.property("dead") then c++
            if c == 0
              push = ":"
            else if c == 1
              push "M"
            else
              push = "X"
          else
            switch e[0].property("color")
              when "blue"
                push = "P"
              when "red"
                if e[0].property("dead") then push = ":" else push = "M"
        temp.push push

      display.push temp.join(" ")
    console.log "Map:"
    console.log display.join("\n")
    console.log "\n\n"
