local this = require "should"

this("Doesn't care about cases").sHoUlD.bE.tRuThY()

this({"table","contains","no","numbers"}).should.contain.only.Strings()
this({1, 2, 3, 4, 5}).should.be.without.Strings()

--[[
    Booleans
--]]
this(true).should.be.a.Boolean()
this(12345).should.Not.be.a.Boolean()
this({true, 123, true}).should.contain.some.Booleans()
this({true, true, true}).should.contain.only.Booleans()

this(true).should.be.True()
this(123).should.Not.be.True()
this({true, 123, true}).should.contain.some.True()
this({true, true, true}).should.contain.only.True()

this(false).should.be.False()
this(123).should.Not.be.False()
this({false, 123, false}).should.contain.some.False()
this({false, false, false}).should.contain.only.False()

this(123).should.be.Truthy()
this(nil).should.Not.be.Truthy()
this({1, false, {}}).should.contain.some.Truthy()
this({1, "A", {}}).should.contain.only.Truthy()

this(nil).should.be.Falsey()
this(123).should.Not.be.Falsey()
this({123, false, 123}).should.contain.some.Falsey()
this({false, false, false}).should.contain.only.Falsey()

this(123).should.exist()
this(nil).should.Not.exist()
this({nil, 123, nil}).should.contain.some.that.exists()
this({false, false, false}).should.contain.only.that.exists()

this(nil).should.be.Nil()
this(123).should.Not.Nil()
-- this({}).should.contain.some.Nil() -- always false, as tables cannot contain nil
this({}).should.contain.only.Nil() -- always true if tables are empty

this(1234).should.be.a.Number()
this("1234").should.Not.be.a.Number()
this({124, "142", 214}).should.contain.some.numbers()
this({124, 124, 124}).should.contain.only.numbers()

this(124).should.be.even()
this(123).should.Not.be.even()
this({123, 124, 123}).should.contain.some.even()
this({124, 124, 124}).should.contain.only.even()


this(123).should.be.odd()
this(124).should.Not.be.odd()
this({123, 124, 123}).should.contain.some.odd()
this({123, 321, 231}).should.contain.only.odd()


this(2147483647).should.be.positive()
this(-1).should.Not.be.positive()
this({123, -124, 0}).should.contain.some.positive()
this({123, 321, 231}).should.contain.only.positive()

this(-1).should.be.negative()
this(2147483647).should.Not.be.negative()
this({123, -124, 0}).should.contain.some.negative()
this({-123, -321, -231}).should.contain.only.negative()

this(-1).should.be.finite()
this(1/0).should.Not.be.finite()
this({-math.huge, -124, 1/0}).should.contain.some.finite()
this({-123, -321, -231}).should.contain.only.finite()

this(math.huge).should.be.infinite()
this(1e308).should.Not.be.infinite()
this({-math.huge, -124, 1/0}).should.contain.some.infinite()
this({1/0, 1e308*2, 2^1024}).should.contain.only.infinite()

this(0/0).should.be.nan()
this(1e309).should.Not.be.nan()
this({math.huge, 0/0, math.huge}).should.contain.some.nan()
this({math.huge/math.huge, 0/0, math.huge*0}).should.contain.only.nan()

this("123").should.be.numeric()
this(false).should.Not.be.numeric()
this({print, "0xDEAD", false}).should.contain.some.numeric()
this({"123", "0xDEAD", "1e5"}).should.contain.only.numeric()
