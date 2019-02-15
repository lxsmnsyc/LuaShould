# LuaShould
BDD-style assertions in Lua

## Usage
### Loading the module
```lua
local this = require "LuaShould"
```
The use of the keyword "this" allows a verbose understanding on what the context/subject of the assertion is.
### Simple assertion
```lua
this(5).should.be.a.Number()
```
Declaring a should context allows you to add words for verbosity.
### Keywords
Keywords signifies the behavior of the assertion sequence.

Keywords are separated by groups:
  * Connectors - relays the context, does nothing.
  * Negators - inverts/negates the next assertion.
  * Connective Preparation - declares scoped assertion.
    * Conjunction - tells the next assertions that all of it should pass. If one of the assertion fails, the whole chain fails.
    * Disjunction - tells the next assertions that one of it should pass. If one of the assertion passes, the whole chain goes on.
  * Connective Conclusion - concludes the scoped assertion.
  * Table Access - tells the next assertion to access the value as a table then check for table properties.
    * Deep Access - tells the next assertion to perform deep access, a recursive form of table access for table values.
    * Reductors - the AND/OR of table evaluation.
      * Table Reductors - tells how to strictly check the keys/values.
      * Parameter Reductors - tells how to check the keys/values based upon the input parameters.
  * Assertion Operators - performs the assertions.
  
LuaShould doesn't really care if the keywords are in upper-case or in lower-case form:
```lua
this("Doesn't care about cases").sHoUlD.bE.tRuThY()
```

except if the keywords are similar to the reserved Lua keywords, you must use the keyword in a different case.

#### Connectors
Connectors are keywords that adds verbosity to the assertions. They pass the context reference to the next keywords.
For example:
```lua
this("Hello World").should.be.of.length(11).and.a.String()
```
The keywords "should", "be", "of", and "a" are all Connectors.
Other connectors includes:
  * an
  * been
  * is
  * which 
  * the
  * it
  * that
  * also
  * but
  
#### Negators
Negators inverts the result of the next assertion.

For example:
```lua
-- test.lua

this(5).should.Not.be.a.Number()
```
throws an error:
```lua
LuaShould/test.lua:3: expected the context to not have 'number' type
```

Other negators includes:
  * not
  * no
  
##### Notes
  * Double-negation is handled, so a sequence ```.Not.Not``` is a double-negative thus negates one another.
  
#### Connective Preparations & Conclusions
Connective Preparation keywords are enables scoped assertions. Scoped assertions are a sequence of keywords that will be evaluated as one once the connective terminates (via Connective Conclusion keywords). 

For example:
```lua
this("5").should.be.either.a.Number.Or.a.String()
```
Here, the connective preparation keyword is the word "either" and the conclusion keyword is the word "or".
The sequence first asserts whether or not "5" is a Number. If it is, the sequence goes on to the next assertion until the next assertion after the conclusion keyword is evaluated, in this case, the sequence concludes when the keywords String asserts the value.

Negators will negate the result of the concluded scoped assertions if declared before the preparation keyword.

For example:
```lua
this("5").should.Not.be.both.a.Number.And.a.String()
```
Successes since the scope "both.a.Number.And.a.String()" fails due to connective conjunction.

You can chain other assertion keywords, as long as the conclusion keyword is not yet met.
```lua
this(5).should.be.both.an.odd.positive.Number.And.finite()
```

Connective Conjunction Preparations keywords only includes the word "both" while the Disjunction includes two words: "whether" and "either".

Connective Conjunction Conclusion keywords only includes the word "and" while the Disjunction includes the word "or".
##### Notes
  * If the sequence did not include a connective conclusion, the whole sequence won't assert.
  * If the scoped sequence fails, specially, before the conclusion, and was doomed to not pass their scoped assertion, the error function will display an "assertion failed!" message.
#### Table Access
Table Access keywords are keywords that only works if the context/subject of assertion is of ```table``` type. These keywords tells the next assertions to be performed on the table keys/values.

For example:
```lua
this({1, 2, 3, 4, 5}).should.be.a.Number()
```
throws the error
```lua
expected the context to have 'number' type
```

While:
```lua
this({1, 2, 3, 4, 5}).should.contain.some.numbers()
```
does not, as it checks the table if it contains one or more numbers.

The table access keywords include:
  * contains
  * contain
  * has
  * have
  * with
  * composed
  * composes
  * consisted
  * consists
  
##### Deep Access
Deep Access allows for recursive table access assertion: if the context table has a table value that did not pass the assertion, it will then be accessed to perform the same assertino to its keys/values.
```lua
this({1, 2, 3, {4, 5, {6, 7, 8}}}).should.deeply.contain.only.numbers()
```
##### Reductors
There are two kinds of reductors: Table Reductors which tells the conjunction of its assertion, and Parameter Reductors which tells if some or all of the parameters passed to the assertion have to be evaluated.

###### Table Reductors
Keywords include "some" which checks for 1 or more occurences (connective disjunction) and "only" which checks if all of the keys/values of the context table passes the assertion (connective conjunction).

Both of the example sequences below passes the assertion.
```lua
this({123, -124, 0}).should.contain.some.negative()
this({-123, -321, -231}).should.contain.only.negative()
```
###### Parameter Reductors
Keywords include "any" which passes the assertion if one of the given parameters passes the assertion and "all" which requires all of the given parameters to pass the assertion.

```lua
this({1, 2, 3, 4, 5}).should.contain.any.of.the.values(9, 6, 3)
this({1, 2, 3, 4, 5}).should.contain.all.of.the.values(1, 2, 3)
```
##### Notes
  * if the Table Access keyword is encountered before a Connective Preparation keyword, all of the assertions in that scope will have perform the table access as well.
  * by default, all sequences have the table reductor as "some" and parameter reductor as "any"
  
#### Assertion Operators
Assertion operators are keywords that performs the assertions to the context/subject of the sequence. 

```lua
this(2147483647).should.be.positive()
```
the keyword "positive" is an assertion operator which performs a test if the context/subject or the table values (if a Table Access keyword is encountered) is a positive number.

Parentheses can be omitted if the assertion operator does not necessarily need a parameter, but to prevent compiler errors, it is recommended to use parentheses, regardless of the parameter requirement, if the test is done without a variable assignment.

```lua
this(123456789).should.be.a.Number() -- required parentheses, as the compiler throws an error if the parentheses is omitted.
local test = this(123456789).should.be.a.Number -- does not throw an error
```

Parentheses can also be omitted if the operator is chained
```lua
this(12345).should.be.a.Number.but.should.be.positive()
```

Assertion operators can also be defined by the user, using the function ```this.define``` which receives the keyword string as the first argument and an assertion function, which is required to throw an error if the evaluation fails. The assertion function receives a table as a first variable which contains the current state of the sequence, which includes:
  * value = the value/reference of the context
  * negates = a boolean value which holds the value "true" if a negation recently occured in the sequence (scope).
  * tableAccess = a boolean value which holds the value "true" if a Table Access keyword recently occured in the sequence (scope).
  * deepAccess = a boolean value which holds the value "true" if a Deep Access keyword recently occured in the sequence (scope).
  * tableReductor = a string value which holds the table reduction types: "some" and "only".
  * parameterReductor = a string value which holds the parameter reduciton types: "any" and "all".

```lua
this.define("divisibleby3", function (x)
  assert(x % 3 == 0, "this is not divisible by 3!")
end)
```
then be used as: 
```lua
this(21).is.divisibleBy3()
this(21).is.DiViSiBlEbY3() -- since the keywords do not really care about their cases.
```

### A Very Long Example
Most of the operators and the examples here are included:
```lua
local this = require "LuaShould"

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

this("5").should.be.either.Not.a.Number.Or.a.String()
this(5).should.be.both.an.odd.positive.Number.And.finite()
this({1, 2, 3, 4, 5}).should.contain.some.numbers()

this({1, 2, 3, {4, 5, {6, 7, 8}}}).should.deeply.contain.only.numbers()

this({1, 2, 3, 4, 5}).should.contain.any.of.the.values(9, 6, 3)
this({1, 2, 3, 4, 5}).should.contain.all.of.the.values(1, 2, 3)

this.define("divisibleby3", function (x)
  assert(x.value % 3 == 0, "this is not divisible by 3!")
end)

this(21).is.divisibleBy3()
```

### Author Notes
The library is still in the development. Operators and keywords would be extended in the future.
