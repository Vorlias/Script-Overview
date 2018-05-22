local Parser = {}
local InterpretedType = require(script.Parent.Enum.InterpretedType_Enum)

local string = setmetatable({}, {__index = string})

function string.getlines(input)
    local results = {}

    local currentInput = ""
    local length = 0

    local strOffset = 1

    local lineOffset = 0

    while length < #input do
        local nextCharacter = input:sub(strOffset, strOffset)
        lineOffset = lineOffset + 1

        if (nextCharacter ~= "\n") then
            currentInput = currentInput .. nextCharacter
        else
            if (lineOffset ~= 1) then
                table.insert(results, currentInput)
                lineOffset = 0
            else
                table.insert(results, "\n")
                lineOffset = 0
            end
            currentInput = ""
        end

        strOffset = strOffset + 1
        length = length + 1
    end
    return results
end

local ParserResult = {}
ParserResult.__index = ParserResult

local PATTERN_LOCAL_FUNCTION = "^local function ([%w_]+%((.-)%))"
local PATTERN_ENVIRONMENT_FUNCTION = "^function ([%w_]+%((.-)%))"
local PATTERN_TABLE_FUNCTION = "^function ([%w_.]+)([%.:])([%w_]+%((.-)%))"
local PATTERN_LOCAL_CONST = "^local ([%u_]+)%s*="
local PATTERN_LOCAL = "^local ([%w_]+)%s*="
local PATTERN_MODULE_IMPORT = "^local ([%w_]+)%s*=%s*require%((.*)%)"
local PATTERN_TABLE_DEFINITION ="^local ([%w_]+)%s*=%s*{"
local PATTERN_CALLBACK_DEFINITION = "^local ([%w_]+)[%s+]?=[%s+]?function%((.-)%)"
local PATTERN_ENVIRONMENT_CALLBACK = "^([%w_]+)[%s+]?=[%s+]?function%((.-)%)"

function ParserResult:Raw()
    return self._struct;
end

function Parser.parse(source)
    assert(typeof(source) == "string")

    local result = {
        _struct = {
            __constants = {},
            __locals = {},
            __environment = {}
        }
    }

    local treeList = result._struct
    local segments = string.getlines(source)

    for line, segment in ipairs(segments) do
        local localFunctionName = segment:match(PATTERN_LOCAL_FUNCTION)
        local environmentFunctionName = segment:match(PATTERN_ENVIRONMENT_FUNCTION)
        local tableFunctionParent, tableFunctionCall, tableFunctionName = segment:match(PATTERN_TABLE_FUNCTION)
        --local tableVariableParent, tableVariableName = segment:match("^([%w_.]+)%.([%w_]+)%s*=");
        local constantVariableName = segment:match(PATTERN_LOCAL_CONST)
        local localVariableName = segment:match(PATTERN_LOCAL)

        local requireVariableName, requireVariablePath = segment:match(PATTERN_MODULE_IMPORT)
        local localTableName, localTableValues = segment:match(PATTERN_TABLE_DEFINITION)
        local localCallbackName = segment:match(PATTERN_CALLBACK_DEFINITION)
        local environmentCallbackName = segment:match(PATTERN_ENVIRONMENT_CALLBACK)

        if (constantVariableName and (filter == nil or matchesFilter(constantVariableName, filter)) ) then
            table.insert(treeList.__constants, {
                Type = InterpretedType.ConstantVariable, 
                Line = line, 
                Name = constantVariableName, 
                Icon = ICON_CONST
            });
        elseif (requireVariableName and (filter == nil or matchesFilter(requireVariableName, filter)) ) then
            table.insert(treeList.__constants, {
                Type = InterpretedType.ModuleScript, 
                Line = line, Name = requireVariableName, 
                Icon = ICON_CONST
            });

        elseif (localCallbackName and (filter == nil or matchesFilter(localCallbackName, filter)) ) then
            table.insert(treeList.__locals, {
                Type = InterpretedType.TableFunction,
                Line = line, Name = localCallbackName,
                Icon = ICON_CALLBACK
            });

        elseif (environmentCallbackName and (filter == nil or matchesFilter(environmentCallbackName, filter)) ) then
            table.insert(treeList.__environment, {
                Type = InterpretedType.LocalFunction, 
                Line = line, Name = environmentCallbackName, 
                Icon = ICON_CALLBACK
            });

        elseif (localFunctionName and (filter == nil or matchesFilter(localFunctionName, filter)) ) then
            table.insert(treeList.__locals, {
                Type = InterpretedType.LocalFunction, 
                Line = line, Name = localFunctionName, 
                Icon = ICON_FUNCTION
            });

        elseif (environmentFunctionName and (filter == nil or matchesFilter(environmentFunctionName, filter)) ) then
            table.insert(treeList.__environment, {
                Type = InterpretedType.LocalFunction, 
                Line = line, Name = environmentFunctionName, 
                Icon = ICON_FUNCTION
            });

        elseif (localTableName and (filter == nil or matchesFilter(localTableName, filter)) ) then
            local tbl = {
                Type = InterpretedType.Table, 
                Line = line, Name = localTableName, 
                Icon = ICON_CLASS, 
                Children = {}
            };
            treeList[localTableName] = tbl;

        elseif (localVariableName and (filter == nil or matchesFilter(localVariableName, filter)) ) then
            local tbl = {
                Type = InterpretedType.Variable, 
                Line = line, Name = localVariableName, 
                Icon = ICON_VARIABLE, 
                Children={}
            };
            table.insert(treeList.__locals, tbl);
            --treeList[localVariableName] = tbl;

        elseif (tableFunctionName and (filter == nil or matchesFilter(tableFunctionName, filter)) ) then

            local existing = treeList[tableFunctionParent];
            if (existing) then
                if (not existing.Children) then
                    existing.Children = {};
                end

                print("Add Child", tableFunctionParent, tableFunctionName);
                table.insert(existing.Children, {
                    Type = (tableFunctionCall == ":" and InterpretedType.TableMethod or InterpretedType.TableFunction), 
                    Line = line, Name = tableFunctionName, 
                    Icon = ICON_FUNCTION
                });
            else
                local newTable = {
                    Name = tableFunctionParent,
                    Type = InterpretedType.Table,
                    Children={}
                };
                treeList[tableFunctionParent] = newTable;
                table.insert(newTable.Children, {
                    Type = (tableFunctionCall == ":" and InterpretedType.TableMethod or InterpretedType.TableFunction), 
                    Line = line, Name = tableFunctionName, 
                    Icon = ICON_FUNCTION
                });
            end
        end
    end

    setmetatable(result, ParserResult)
    return result
end

return Parser
