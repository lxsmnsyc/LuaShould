--[[
    Lua Should
	
    MIT License
    Copyright (c) 2019 Alexis Munsayac
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

--[[
    Connectors
    
    Passes the should reference
--]]

local CONNECTORS = {
    ["be"] = 1,
    ["an"] = 1, 
    ["of"] = 1,
    ["a"] = 1,
    ["been"] = 1,
    ["is"] = 1,
    ["which"] = 1,
    ["the"] = 1,
    ["it"] = 1,
    ["should"] = 1,
    ["that"] = 1,
    ["also"] = 1,
    ["but"] = 1
}

--[[
    Negators
    
    notifies the next assertion to do an inverse evaluation
--]]
local NEGATORS = {
    ["not"] = 1,
    ["no"] = 1,
}

--[[
    Conjunction preparation
    
    Declares a scoped Should that aggregates all result
    and throws an error if one of the keywords fail.
--]]
local PREPARES_CONJUNCTION = {
    ["both"] = 1
}

--[[
    Disjunction preparation
    
    Declares a scoped Should that prevents an error from
    occuring until all keywords fail.
--]]
local PREPARES_DISJUNCTION = {
    ["either"] = 1,
    ["whether"] = 1,
}

--[[
    Conjunctions
    
    Signifies that the next keyword should be the last 
    to be aggregated with.
    
    All states such as table events, negation levels,
    will be set to their original values.
--]]
local CONJUNCTIONS = {
    ["and"] = 1
}

--[[
    Disjunctions
    
    Signifies that the next keyword should be the last 
    to be aggregated with.
    
    All states such as table events, negation levels,
    will be set to their original values.
--]]
local DISJUNCTIONS = {
    ["or"] = 1
}

local TABLE_ACCESS = {
    ["contains"] = 1,
    ["contain"] = 1,
    ["has"] = 1,
    ["have"] = 1,
    ["with"] = 1,
    ["composed"] = 1,
    ["composes"] = 1,
    ["consisted"] = 1,
    ["consists"] = 1
}

local NEGATIVE_TABLE_ACCESS = {
    ["without"] = 1,
}

local DEEP_SEARCH = {
    ["deeply"] = 1,
    ["recursively"] = 1
}

local TABLE_REDUCTOR = {
    ["only"] = "only",
    ["some"] = "some"
}

local PARAMETER_REDUCTOR = {
    ["any"] = "any",
    ["all"] = "all",
}

local RESERVED = {
    ["_scopes"] = 1,
    ["_scope"] = 1,
    ["_value"] = 1
}

local DEFS = {}
local CALLABLE = {}

local function evaluate(self, k, ...)
    --[[
        Get the scope
    ]]--
    local scope = self._scope
    --[[
        do a protected call to the definition
    --]]
    local try, catch = pcall(DEFS[k], {
        value = self._value,
        negates = scope._negates,
        tableAccess = scope._tableAccess,
        deepAccess = scope._deepAccess, 
        tableReductor = scope._tableReductor,
        parameterReductor = scope._parameterReductor
    }, ...)
    --[[
    
    --]]
    local requestError = false
    --[[
        Check for conjunction
    --]]
    if(scope._isConjunction) then 
        --[[
            Check if the call is successful
        --]]
        if(not try) then 
            scope._failed = true
        end
        if(scope._requestConjunction) then   
            if(scope._failed) then 
                requestError = true
            end
            --[[
                Return to the original scope
            --]]
            local parentScope = self._scopes[scope]
            self._scope = parentScope 
            scope = parentScope
            if(scope._negates) then 
                requestError = not requestError
            end
        end 
    elseif(scope._isDisjunction) then 
        if(try) then 
            scope._failed = false 
        end
        if(scope._requestDisjunction) then            
            if(scope._failed) then 
                requestError = true
            end
            --[[
                Return to the original scope
            --]]
            local parentScope = self._scopes[scope]
            self._scope = parentScope   
            scope = parentScope
            
            if(scope._negates) then 
                requestError = not requestError
            end
        end
    else 
        if(not try) then 
           requestError = true  
        end
    end
    
    scope._negates = false
    
    if(requestError) then 
        error(catch or "assertion failed!", 2)
    end
    
    return self
end 

local function indexer(self, k)
    --[[
        Convert value to lower case
    --]]
    k = string.lower(k)
    
    local scope = self._scope
    --[[
        Check if the keyword is conjunction preparation
        or disjunction preparation
    --]]
    if(PREPARES_CONJUNCTION[k] or PREPARES_DISJUNCTION[k]) then 
        --[[
            Create a new scope
        --]]
        local newScope = {
            --[[
                Setup the states
            --]]
            _negates = false, 

            _isConjunction = PREPARES_CONJUNCTION[k],
            _isDisjunction = PREPARES_DISJUNCTION[k],
            _tableAccess = scope._tableAccess,
            _deepAccess = scope._deepAccess,
            
            _parameterReductor = "all",
            _tableReductor = scope._tableReductor,
            
            _requestConjunction = false,
            _requestDisjunction = false,
            
            _failed = PREPARES_DISJUNCTION[k]
        }
            
        --[[
            Set it as the current scope
        --]]
        self._scope = newScope 
        --[[
            Link the new scope
        --]]
        self._scopes[newScope] = scope
        return self
    end 
    --[[
        Check if it is a conjunction
    --]]
    if(CONJUNCTIONS[k] and self._scopes[scope]) then 
        scope._requestConjunction = true 
        return self
    end
    --[[
        Check if it is a disjunction
    --]]
    if(DISJUNCTIONS[k] and self._scopes[scope]) then 
        scope._requestDisjunction = true
        return self 
    end
    
    if(NEGATORS[k]) then 
        scope._negates = not scope._negates
        return self 
    end
    
    if(TABLE_ACCESS[k]) then 
        scope._tableAccess = true 
        return self 
    end 
    
    if(NEGATIVE_TABLE_ACCESS[k]) then 
        scope._negates = not scope._negates
        scope._tableAccess = true 
        return self 
    end 
    
    if(PARAMETER_REDUCTOR[k]) then 
        scope._parameterReductor = PARAMETER_REDUCTOR[k]
        return self
    end     
    
    if(TABLE_REDUCTOR[k]) then 
        scope._tableReductor = TABLE_REDUCTOR[k]
        return self 
    end
    
    if(DEEP_SEARCH[k]) then 
        scope._deepAccess = true 
        return self 
    end
    
    if(DEFS[k]) then 
        if(CALLABLE[k]) then 
            return function (...)
                return evaluate(self, k, ...)
            end
        end 
        return evaluate(self, k)
    end
    
    if(CONNECTORS[k]) then 
        return self
    end 
end 

local function define(word, assertion)
    word = string.lower(word)
    DEFS[word] = assertion 
    CALLABLE[word] = debug.getinfo(assertion).nparams > 1
end 

local M = {
    __call = function () end,
    __index = indexer
}

local function should(_, value)
    local scope = {
        --[[
            Setup the states
        --]]
        _negates = false, 

        _tableAccess = false,
        _parameterReductor = "all",
        _tableReductor = "some",
        
        _deepAccess = false,
        
        _failed = true
    }
    return setmetatable({
        _scopes = {scope},
        _scope = scope,
        _value = value
    }, M)
end 

local this = setmetatable({
    define = define
}, {
    __call = should
})

local function shallowIterate(tbl, fn, reductor)
    for k, v in pairs(tbl) do 
        local r = fn(v, k)
        if(reductor == "some") then 
            if(r) then 
                return true 
            end 
        elseif(reductor == "only") then 
            if(not r) then 
                return false 
            end 
        end 
    end
    return reductor == "only"
end 

local function deepIterate(tbl, fn, reductor)
    return shallowIterate(tbl, function (v)
        if(fn(v, k)) then 
            return true 
        elseif(type(v) == "table") then 
            return deepIterate(v, fn, reductor)
        end 
        return false
    end, reductor)
end 

local function iterate(tbl, deepAccess, fn, reductor) 
    --[[
        Check for deep access
    --]]
    if(deepAccess) then 
        --[[
            Perform a deep search
        --]]
        return deepIterate(tbl, fn, reductor)
    end 
    --[[
        Otherwise, perform a
        shallow iteration
    --]]
    return shallowIterate(tbl, fn, reductor)
end

local function validateTable(tbl, tableAccess, deepAccess, fn, reductor)
    if(type(tbl) == "table") then 
        --[[
            Check if a table access event has
            occured in the keywords
        --]]
        if(tableAccess) then
            --[[
                iterate
            --]]
            return iterate(tbl, deepAccess, fn, reductor)
        end 
        --[[
            Otherwise, assert tbl to its test function
        --]]
    end
    return fn(tbl)
end

local function modAssert(evaluation, negates, tableAccess, deepAccess, reductor, msg)
    local doNegate = negates and " not" or ""
    local final 
    if(tableAccess) then
        final = "expected the table context to"..doNegate
        if(deepAccess) then 
            final = final.." deeply"
        end 
        final = final.." have "..reductor.." "..msg.."s"
    else
        final = "expected the context to"..doNegate.." have "..msg
    end 
    if(negates) then 
        evaluation = not evaluation 
    end
    if(not evaluation) then 
        error(final, 0)
    end
end 

local function testedWith(x, fn, msg)
    local r = validateTable(x.value, x.tableAccess, x.deepAccess, function (v, k) 
        return fn(v, k)
    end, x.tableReductor)
    modAssert(r, x.negates, x.tableAccess, x.deepAccess, x.tableReductor, msg)
end

define("testedwith", testedWith)

local function comparedWith(x, y, fn, msg)
    testedWith(x, function (v)
        return fn(v, y)
    end, msg)
end 

define("comparedwith", comparedWith)

local function typeof(x, y)
    testedWith(x, function (v)
        return type(v) == y
    end, "'"..y.."' type")
end

define("type", typeof)

local function isBoolean(x)
    typeof(x, "boolean") 
end
local function isNumber(x) 
    typeof(x, "number") 
end
local function isString(x) 
    typeof(x, "string") 
end
local function isTable(x) 
    typeof(x, "table") 
end
local function isFunction(x) 
    typeof(x, "function") 
end
local function isCoroutine(x)
    typeof(x, "thread") 
end
local function isUserdata(x)
    typeof(x, "userdata")
end

define("table", isTable)
define("coroutine", isCoroutine)
define("thread", isCoroutine)
define("userdata", isUserdata)

define("tables", isTable)
define("coroutines", isCoroutine)
define("threads", isCoroutine)


--[[
    Booleans
--]]
define("boolean", isBoolean)
define("booleans", isBoolean)

define("true", function (x)
    testedWith(x, function (v)
        return v == true
    end, "'true' value")
end)

define("false", function (x)
    testedWith(x, function (v)
        return v == false
    end, "'false' value")
end)

local function exists(x)
    testedWith(x, function (v)
        return v ~= nil
    end, "existing value")
end

define("exists", exists)
define("exist", exists)

define("nil", function (x)
    testedWith(x, function (v)
        return v == nil
    end, "nil value")
end)

local function truthy(x)
    testedWith(x, function (v)
        return v
    end, "'truthy' value")
end

define("truthy", truthy)
define("ok", truthy)
define("okay", truthy)

local function falsey(x)
    testedWith(x, function (v)
        return not v
    end, "'falsey' value")
end

define("falsey", falsey)
define("notok", falsey)
define("notokay", falsey)


--[[
    Numbers
--]]
define("number", isNumber)
define("numbers", isNumber)

define("even", function (x)
    testedWith(x, function (v)
        return type(v) == "number" and v % 2 == 0
    end, "'even' number")
end)

define("odd", function (x)
    testedWith(x, function (v)
        return type(v) == "number" and v % 2 == 1
    end, "'odd' number")
end)

define("positive", function (x)
    testedWith(x, function (v)
        return type(v) == "number" and v > 0
    end, "'positive' number")
end)

define("negative", function (x)
    testedWith(x, function (v)
        return type(v) == "number" and v < 0
    end, "'negative' number")
end)

local huge = math.huge

define("finite", function (x)
    testedWith(x, function (v)
        return type(v) == "number" and not (v == huge or v == -huge)
    end, "'finite' number")
end)

define("infinite", function (x)
    testedWith(x, function (v)
        return type(v) == "number" and (v == huge or v == -huge)
    end, "'infinite' value")
end)

define("nan", function (x)
    testedWith(x, function (v)
        return type(v) == "number" and v ~= v
    end, "'NaN' value")
end)

define("numeric", function (x)
    testedWith(x, function (v)
        return tonumber(v)
    end, "'numeric' value")
end)
--[[
    Strings
--]]
define("string", isString)
define("strings", isString)

define("blank", function (x)
    testedWith(x, function (v)
        return type(v) == "string" and v == ""
    end, "'blank' string")
end)

define("length", function (x, y)
    testedWith(x, function (v)
        return type(v) == "string" and #v == y
    end, "string of character length "..y)
end)

local function matches(x, y)
    testedWith(x, function (v)
        return type(v) == "string" and v:match(y)
    end, "string that matches '"..y.."'")
end 

define("matches", matches)
define("match", matches)

define("alpha", function (x)
    testedWith(x, function (v)
        return type(v) == "string" and not v:match("%A")
    end, "letter string")
end)

define("decimal", function (x)
    testedWith(x, function (v)
        return type(v) == "string" and not v:match("%D")
    end, "decimal string")
end)


define("hexadecimal", function (x)
    testedWith(x, function (v)
        return type(v) == "string" and not v:match("%X")
    end, "hexadecimal string")
end)

define("alphanumeric", function (x)
    testedWith(x, function (v)
        return type(v) == "string" and not v:match("%W")
    end, "alphanumeric string")
end)

define("whitespace", function (x)
    testedWith(x, function (v)
        return type(v) == "string" and not v:match("%S")
    end, "whitespace string")
end)

define("upper", function (x)
    testedWith(x, function (v)
        return type(v) == "string" and v == string.upper(v)
    end, "upper string")
end)

define("lower", function (x)
    testedWith(x, function (v)
        return type(v) == "string" and v == string.lower(v)
    end, "lower string")
end)

--[[
    Function
--]]
define("function", isFunction)
define("functions", isFunction)

define("parameterLength", function (x, y)
    testedWith(x, function (v)
        return type(v) == "function" and debug.getinfo(v).nparams == y
    end, "function with parameter length of "..y)
end)

--[[
    Table
--]]
define("empty",  function (x)
    testedWith(x, function (v)
        return type(v) == "table" and next(v) == nil
    end, "empty table")
end)

define("key", function (x, key)
    testedWith(x, function (v, k)
        return type(v) == "table" and k == key
    end, "key '"..key.."'")
end)


define("keys", function (x, key1, ...)
    local keys = {key1, ...}
    local parameterReductor = x.parameterReductor
    local keysSize = #keys
    local c = keysSize
    testedWith(x, function (v, k)
        if(not type(v) == "table") then return false end
        
        for i, j in pairs(keys) do 
            local r = k == j 
            if(parameterReductor == "any") then 
                if(r) then 
                    return true 
                end 
            elseif(parameterReductor == "all") then
                if(r) then 
                    c = c - 1
                end
            end
        end 
        if(parameterReductor == "any") then 
            return false 
        elseif(parameterReductor == "all") then 
            return c == 0
        end
    end, "of "..parameterReductor.." the ("..table.concat(keys, ", ")..") key")
end)


define("values", function (x, value1, ...)
    local values = {value1, ...}
    local parameterReductor = x.parameterReductor
    local valueSize = #values
    local c = valueSize
    testedWith(x, function (v, k)
        if(not type(v) == "table") then return false end
        
        for i, j in pairs(values) do 
            local r = v == j 
            if(parameterReductor == "any") then 
                if(r) then 
                    return true 
                end 
            elseif(parameterReductor == "all") then
                if(r) then 
                    c = c - 1
                end
            end
        end 
        if(parameterReductor == "any") then 
            return false 
        elseif(parameterReductor == "all") then 
            return c == 0
        end
    end, "of "..parameterReductor.." the ("..table.concat(values, ", ")..") value")
end)


return this