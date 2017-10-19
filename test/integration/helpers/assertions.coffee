module.exports = (map, player) ->

  assertPlayerIsAt: (x, y) ->
    e = map.entitiesAt x, y
    e.length.should.equal 1
    e[0].property("color").should.equal "blue"
    player.x.should.equal x
    player.y.should.equal y

  assertMonsterAt: (x, y, n = 1) ->
    e = map.entitiesAt x, y
    e.length.should.equal n
    for m in e
      m.property("color").should.equal "red"
      m.x.should.equal x
      m.y.should.equal y

  assertNoOneAt: (x, y) ->
    map.entitiesAt(x,y).length.should.equal 0
