local Object = require(script.Parent.Parent.Utility.ModObject);

local _InterpretedTypeEnum = Object:NewEnum("InterpretedType", {
	"ConstantVariable",
	"LocalFunction",
	"TableFunction",
	"TableMethod",
	"Table",
	"Variable",
	"ModuleScript",
}, nil);

-- So the ROBLOX intellisense can display the values.
local InterpretedType = {
	ConstantVariable = _InterpretedTypeEnum.ConstantVariable,
	LocalFunction = _InterpretedTypeEnum.LocalFunction,
	TableFunction = _InterpretedTypeEnum.TableFunction,
	TableMethod = _InterpretedTypeEnum.TableMethod,
	Table = _InterpretedTypeEnum.Table,
	Variable = _InterpretedTypeEnum.Variable,
	ModuleScript = _InterpretedTypeEnum.ModuleScript,
}

function InterpretedType:IsValue(value)
	return typeof(value) == 'table' and Object:IsEnum(value, 'InterpretedType');
end

return InterpretedType;