--[[
    __  ____________  ____  ___________    _______   _____________   ________
   / / / / ____/ __ \/ __ \/ ____/ ___/   / ____/ | / / ____/  _/ | / / ____/
  / /_/ / __/ / /_/ / / / / __/  \__ \   / __/ /  |/ / / __ / //  |/ / __/
 / __  / /___/ _, _/ /_/ / /___ ___/ /  / /___/ /|  / /_/ // // /|  / /___
/_/ /_/_____/_/ |_|\____/_____//____/  /_____/_/ |_/\____/___/_/ |_/_____/

	ModObject
		24/02/2016 NZDT

	Information:
		Module for object-oriented programming in lua used by the Heroes Engine.

	Author:
		Vorlias

	Requires:
--]]

--[[@documentation

	// Methods

	public LuaObject LuaClass (Variant... args)
		- Alternate LuaObject constructor

	public string __typeof (Variant anyValue)
		- Hacky implementation of built-in 'typeof'


namespace LuaClass
{
	// Constructors

	public LuaClass (Variant... args)
		- Constructor for LuaClass


	// Methods

	public LuaObject LuaClass::Init (Variant... args)
		- Initializes object from class


}
namespace Object
{
	// Constructors

	public Object ()
		- Creates a blank object ' used for internal stuff


	// Properties

	public string Object::ClassName 

	public bool Object::IsClass 

	public LuaObject Object::ParentClass 


	// Methods

	public bool Object::Assert (Variant value, string typeName, optional string errMsg)
		- Assert type

	public LuaObject Object::Create (string objName, Variant... args)
		[Deprecated]

	public Namespace Object::GetNamespace (string namespace)
		- Gets a namespace

	public LuaClass Object::GetType (string name)
		- Gets a type by path

	public bool Object::IsClass (Variant value, optional string typeName)
		- Checks if the value is a class

	public bool Object::IsEnum (Variant value, optional string typeName)
		- Checks if the value is an enum

	public bool Object::IsObject (Variant value, optional string typeName)
		- Checks if the value is an object

	public bool, string Object::IsType (string str)
		- Returns whether or not the object is the specified type, or inherits it

	public LuaClass Object::NewClass (string className, optional LuaClass inheritance, optional table classT, optional string namespace)
		- Creates a new class

	public LuaEnum Object::NewEnum (string enumName, table<string> enumValues, optional string namespace)
		- Creates a new enum

	public LuaClass Object::NewType (table obj, string className, optional LuaClass inherits, optional string namespace)
		- Creates a new class

	public string, bool Object::TypeName (Variant value)
		- Gets the typename of the value, returns the type name.


}
namespace LuaObject
{
	// Methods

	public void LuaObject::BaseCall (string name, Variant... args)
		[Deprecated]

	public Object LuaObject::CastType (string typeName)
		- Casts the object to the specified type (if possible)
		- The object's class must have a To[typeName]( ) method.

	public void LuaObject::Copy (LuaObject obj, Variant... args)
		[Deprecated]

	public void LuaObject::PureVirtual (string name)
		[Deprecated]


}
namespace Namespace
{
	// Methods

	public Namespace Namespace::GetNamespace (string namespace)
		- Gets the specified sub-namespace from the namespace

	public LuaClass Namespace::GetType (string typeName)
		- Gets the specified type from the namespace


}

--]]

--[[@dox LuaClass.new
	@param Variant... args
--]]

--[[@dox LuaClass
	Alternate LuaObject constructor
	@param Variant... args
	@returns LuaObject
--]]

--[[@dox Object::ClassName
	@property
	@returns string
--]]

--[[@dox Object::ParentClass
	@property
	@returns LuaObject
--]]

--[[@dox Object::IsClass
	@property
	@returns bool
--]]

ModObject = {
	Version = 2.4;
	EnableStructConstructor = true;
};

CustomObjects = {
};

CustomObjectsFullName = {
};

CustomNamespaces = {
};

local Object = {
	ClassName = "Object";
	ParentClass = nil;
	IsClass = true;
}

function TableCopy(old) -- %.Copy( Table )
	local _new = {};
	for index,value in pairs(old) do
		if (type(value) == 'table') then
			_new[index] = TableCopy(value);
		elseif (value ~= nil) then
			_new[index] = value;
		end
	end
	return _new;
end

Object.__index = Object

Object.__eq = (function(self, other)
	return self == other;
end);

if (ModObject.EnableStructConstructor) then
	Object.__call = (function(self, ...) -- Constructor{}
		--[[
			Person("John Doe", 20)
		&&
			Person{
				"John Doe", -- required constructor arguments (if needed)
				20,

				Address = "123 Example Street"; -- Assigning properties within the constructor
				City = "SomeCity";
			}
		]]
		local params = {...};
		local tbl = unpack(params);
		local obj;

		if (#params == 1 and type(tbl) == 'table') then
			obj = self.new( unpack(tbl) );
			for i,v in pairs(tbl) do
				if (type(i) == 'string' and rawget(obj,i) == nil) then
					warn(obj.ClassName .. " does not contain a member '" .. i .. "'");
				elseif (type(i) == 'string') then
					obj[i] = v;
				end
			end
		else
			obj = self.new(...);
		end

		return obj;
	end);
else
	Object.__call = (function(self, ...)
		return self.new(...);
	end);
end

Object.__tostring = (function(self, ...)
	return "[LuaClass " .. self.ClassName .. "]";
end);


--[[@dox Object.new
	@description Creates a blank object ' used for internal stuff
	@returns Object
--]]
function Object.new()
    local newobj = {}
	newobj.IsClass = false;
	newobj.LuaObject = true;
    setmetatable(newobj, Object)

    return newobj
end


--[[@dox Create
	@deprecated
	@namespace Object
	@param string objName
	@param Variant... args
	@returns LuaObject
--]]
function Object:Create(objName, ...)
	if (self ~= Object) then
		error("Cannot call static member 'Create' (Object::Create) from object " .. self.ClassName); end

	local t = CustomObjects[objName];
	if (t and t.new) then
		return t.new(...);
	end

	error("Could not instantiate type " .. objName);
end

--[[@dox IsType
	@namespace Object
	@description Returns whether or not the object is the specified type, or inherits it
	@param string str
	@returns bool, string
--]]
function Object:IsType(str)
	if (str == self.ClassName) then
		return true, self.ClassName;
	elseif (self.ParentClass ~= nil) then
		return self.ParentClass:IsType(str);
	else
		return false, self.ClassName;
	end
end

local function objectGetTypes(self, tb)
	if (self.Parent ~= nil) then
		objectGetTypes(self.Parent, tb);
	end
	
	table.insert(tb, self.ClassName);	
end

function Object:GetTypes()
	assert(self ~= Object, "Cannot call on base class.");	
	
	local data = {};
	objectGetTypes(self, data);
	return data;
end

--[[@dox Copy
	@namespace LuaObject
	@param LuaObject obj
	@param Variant... args
	@deprecated
--]]
function Object:Copy(obj, ...)
	if (not self.IsClass) then
		error("Cannot call static member Object::Copy() from class "..self.ClassName); end

	local _type = Object:GetTypeByName(obj.ClassName);
	local newObj = _type.new(...);
	for i,v in pairs(obj) do
		if (i ~= "Id" and i ~= "Name") then
			if (type(v) == 'table') then
				newObj[i] = TableCopy(v);
			else
				newObj[i] = v;
			end
		end
	end

	return newObj;
end

--[[@dox GetType
	@namespace Object
	@description Gets a type by path
	@param string name
	@returns LuaClass
--]]
function Object:GetType(name)
	if (not self.IsClass) then
		error("Cannot call static member Object::GetTypeByName() from class "..self.ClassName); end

	return CustomObjectsFullName[name] or CustomObjects[name];
end

Object.GetTypeByName = Object.GetType;



--------------------------- Mod Path -------------------------------------------
local ModPath = {};

local pathSeparator = "/";

--- Converts a path to a table
function ModPath:PathToTable(path)
	path = "/" .. path;

	local args_templ = string.gmatch(path, pathSeparator .. "([a-zA-Z0-9_,%.]+)"); -- get the arguments
	local args = {};
	for word in args_templ do table.insert(args,word); end -- list the arguments
	return args;
end


function ModPath:__ParseLuaPathIntl(path)
	local env = getfenv(1);
	local fullPath = self:PathToTable(path);
	local ancestor = env[fullPath[1]];
	local obj = env;
	local parentObj = nil;
	if (ancestor) then
		parentObj = obj;

		for i,v in pairs(fullPath) do
			if (obj ~= nil) then
				obj = obj[v];
			else
				return nil;
			end
		end

		return obj, parentObj, ancestor;
	else
		return nil;
	end
end


--- Finds the value relative to the specified environment value.
-- @param string path - The path of the value
-- example: FindValue("string/find") would get string.find
-- note: Does not work for local variables, keep that in mind.
function ModPath:FindValue(path)
	local val, p, a = self:__ParseLuaPathIntl(path);
	return val, p , a;
end

function ModPath:CreateRelativeNamespace(path)
	local pieces = ModPath:PathToTable(path);
	local targetTable = CustomNamespaces;
	for index, piece in pairs(pieces) do
		local value = targetTable[piece]; 
		if (not value) then
			print("CreatePiece", piece , "under", targetTable,targetTable == CustomNamespaces);
			targetTable[piece] = {};
			value = targetTable[piece];
		end
		
		targetTable = value;
	end
	
	return targetTable;
end
--------------------------------------------------------------------------------

--[[@dox GetNamespace
	@namespace Object
	@description Gets a namespace
	@param string namespace
	@returns Namespace
--]]
function Object:GetNamespace(namespace)
	if (self ~= Object) then
	error("Cannot call static  member 'NewType' (Object::NewType) from object " .. self.ClassName); end
	
	
	local targetNamespace = ModPath:FindValue("CustomNamespaces/"..tostring(namespace));
	
--[[@dox Namespace::GetType
	Gets the specified type from the namespace
	@param string typeName
	@returns LuaClass
--]]	
--[[@dox Namespace::GetNamespace
	Gets the specified sub-namespace from the namespace
	@param string namespace
	@returns Namespace
--]]
	
	return setmetatable({
		GetType = (function(self, ns)
			local value = targetNamespace[ns];
			if (tostring(value):sub(1,8) == 'LuaClass') then
				return value;
			else
				error("[Namespace::GetType] Type is not class, use GetNamespace!");
			end
		end);
		GetNamespace = (function(self, ns)
			local value = Object:GetNamespace(namespace .. "/" .. tostring(ns));
			return value;
		end);
	},{ 
		__tostring=(function() return tostring(namespace); end), 
		__newindex = (function() error("Cannot write to namespace"); end),
		__index = (function(self, i)
			return rawget(targetNamespace, i) or rawget(self, i);
		end)
	}) ;
		
end


--[[@dox NewType
	@namespace Object
	@description Creates a new class
	@param table obj
	@param string className
	@param? LuaClass inherits
	@param? string namespace
	@returns LuaClass
--]]
function Object:NewType(obj, className, inherits, namespace)

	if (self ~= Object) then
		error("Cannot call static member 'NewType' (Object::NewType) from object " .. self.ClassName); end

	inherits = inherits or Object;

	obj.__index = obj;

	obj.__tostring = (function(self)
		if (self.operation_tostring) then
			return "[LuaObject "..self:operation_tostring() .. "]";
		else
			return "[LuaObject "..self.ClassName .. "]";
		end
	end);

	obj.__call = (function(self, ...)
		if (self.operation_call) then
			return self:operation_call(...);
		else
			error("Attempt to call object");
		end
	end);

	obj.__newindex = (function(self, i,v)
		if (i ~= 'ClassName' and i ~= 'ParentClass' and i ~= 'LuaObject') then
			rawset(self, i, v);
		else
			error("Cannot set read-only property " .. i);
		end
	end);

	obj.ClassName = className or 'Object';
	obj.ParentClass = inherits;

	setmetatable(obj, inherits);

	local spec = {};
	function spec:__ExtendsObject(inherits)
		for i,v in pairs(inherits) do
			if (i ~= 'ClassName' and i ~= 'ParentClass' and i ~= '__index' and i ~= 'new') then
				obj[i] = type(v) == 'table' and TableCopy(v) or v;
			end
		end
	end

	function spec:Extends(inherits)
		obj.ParentClass = inherits;

		if (inherits.__inheritable and inherits.__inheritable == false) then
			error("Cannot inherit class " .. inherits.ClassName .. ", it is not inheritable."); end

		if (inherits.__extend and type(inherits.__extend) == 'function') then
			inherits.__extend(obj, inherits);
		else
			spec:__ExtendsObject(inherits);
		end

	end

	if (type(namespace) == 'string') then
		CustomObjects[namespace .. "/" .. className] = obj;
		ModPath:CreateRelativeNamespace(namespace)[className] = obj;
		
		Instance.new("StringValue", script).Name = namespace .. "/" .. className;
	else
		CustomObjects[className] = obj;
		
		Instance.new("StringValue", script).Name = className;
	end

	return spec;
end

--[[@dox BaseCall
	@namespace LuaObject
	@param string name
	@param Variant... args
	@deprecated
--]]
function Object:BaseCall(name, ...)
	if (self == Object) then
		error("Cannot call static member 'Init' (Object::Init) from SuperClass 'Object'"); end

	self.ParentClass[name](self, ...);
end

--[[@dox NewClass
	@namespace Object
	@description Creates a new class
	@param string className
	@param? LuaClass inheritance
	@param? table classT
	@param? string namespace
	@returns LuaClass
--]]
function Object:NewClass(className, inheritance, classT, namespace)
	local _class = classT or {};

	if (inheritance ~= nil) then
		Object:NewType(_class, className, nil, namespace):Extends(
			type(inheritance) == 'string'
			and Object:GetTypeByName(inheritance)
			or inheritance
		);
	else
		Object:NewType(_class, className, nil, namespace);
	end

	return _class;
end

--[[@dox Init
	@namespace LuaClass
	@description Initializes object from class
	@param Variant... args
	@returns LuaObject
--]]
function Object:Init(...)
	if (self == Object) then
		error("Cannot call static member 'Init' (Object::Init) from SuperClass 'Object'"); end

	if (self.ParentClass ~= nil) then
		local obj = self.ParentClass.new(...);
		setmetatable(obj, self);

		return obj;
	else
		error("Class '" .. self.ClassName .. " does not inherit an object.");
	end
end

--[[@dox IsClass
	@namespace Object
	@description Checks if the value is a class
	@param Variant value
	@param? string typeName
	@returns bool
--]]
function Object:IsClass(val, typeName)
	if (self ~= Object) then
		error("Cannot call static member 'IsClass' (Object::IsClass) from object " .. self.ClassName); end

	if (typeName) then
		return (tostring(val):sub(2, 9) == "LuaClass") and val.ClassName == typeName;
	else
		return (tostring(val):sub(2, 9) == "LuaClass");
	end
end

--[[@dox IsObject
	@namespace Object
	@description Checks if the value is an object
	@param Variant value
	@param? string typeName
	@returns bool
--]]
function Object:IsObject(val, typeName)
	if (self ~= Object) then
		error("Cannot call static member 'IsObject' (Object::IsObject) from object " .. self.ClassName); end

	if (typeName) then
		return (tostring(val):sub(2, 10) == "LuaObject") and val:IsType(typeName);
	else
		return (tostring(val):sub(2, 10) == "LuaObject");
	end

end

--[[@dox LuaObject::CastType
	Casts the object to the specified type (if possible)
	The object's class must have a To[typeName]( ) method.
	@param string typeName
	@returns Object|nil
--]]
function Object:CastType(newType)
	if (self == Object) then
		error("Cannot cast base class!");
	end
	
	local convert = self["To"..newType];

	if (type(convert) == 'function') then
		return convert(self);
	else
		error("[Object::CastType] Cannot perform conversion on " .. tostring(self) .. " to type " .. newType);
	end
end


--[[@dox Assert
	@namespace Object
	@description Assert type
	@param Variant value
	@param string typeName
	@param? string errMsg
	@returns bool
--]]
local strfmt = string.format;
function Object:Assert(value, typename, errMsg)
	errMsg = errMsg or "Assertion Failed! - expected %s, got %s";

	assert(self:IsObject(value), strfmt(errMsg, typename, type(value)) );
	---assert(value:IsType(typename), strfmt(errMsg, typename, value.ClassName));
	if (not value:IsType(typename)) then
		--[[print(value:IsType(typename));
		if (value.ParentClass ~= nil) then
			print(value.ParentClass.ClassName);
			if (value.ParentClass.ParentClass ~= nil) then
				print(value.ParentClass.ParentClass.ClassName);
			end
		end		]]
		
		error(strfmt(errMsg, typename, value.ClassName), 2);
		

	end
end

--[[@dox __typeof
	Hacky implementation of built-in 'typeof'
	@param Variant anyValue
	@deprecated
	@returns string
--]]
function __typeof(anyValue)
	-- << Upvalues >>
	local anyvalueType
	-- << Execution of function >>
	local ran, _error = pcall(string.dump, anyValue)
	if not (ran) then
		anyvalueType = _error:match("got (%a+)")
	else
		anyvalueType = "function"
	end
	-- << Logic for "typeof" compatibility >>
	if (anyvalueType == "Object") then
		anyvalueType = "Instance"
	end
	-- << Return AnyvalueType >>
	return anyvalueType
end

--[[@dox TypeName
	Gets the type name
	@namespace Object
	@description Gets the typename of the value, returns the type name.
	@param Variant value
	@returns T<string,bool>
--]]
function Object:TypeName(value)
	if (self ~= Object) then
		warn("Object::TypeName should be called statically.");
	end
	
	if (Object:IsObject(value)) then
		return value.ClassName, true;
	else
		local typeName = (typeof or __typeof)(value);
		return typeName, false;
	end		
end

--[[@dox PureVirtual
	@namespace LuaObject
	@param string name
	@deprecated
--]]
function Object:PureVirtual(name)
	assert(self ~= Object, "Object::PureVirtual is not a static method!");

	self[name] = (function() error("Method " .. self.ClassName .. "::" .. name .. " is purely virtual, it must be overriden by the child class.") end);
end


--[[@dox NewEnum
	@namespace Object
	@description Creates a new enum
	@param string enumName
	@param table<string> enumValues
	@param? string namespace
	@returns LuaEnum
--]]
function Object:NewEnum(enumName, enumValues, namespace)
	assert(type(enumName) == 'string', "Argument #1 'enumName' to Object::NewEnum - string expected, got " .. type(enumName));
	
	assert(type(enumValues) == 'table', "Argument #2 'enumValues' to Object::NewEnum - table expected, got " .. type(enumName));
	assert(#enumValues > 0, "Argument #2 'enumValues' to Object::NewEnum - Enums should be number indexed, and require at least one value. ");
	
	local EnumClass = Object:NewClass(enumName, nil, { 
		IsEnum = true;		
		
		GetName = function(self)
			return self.Name;
		end;
		
		GetValue = function(self)
			return self.Value;
		end;
		
		Is = function(self, other)
			if (Object:IsObject(other) and other:IsType(enumName)) then
				return self.Value == other.Value;
			else
				return false;
			end
		end;
		
		operation_tostring = function(self)
			return ("Enum:%s[%d] (%s)"):format(enumName, self.Value, self.Name);
		end
	}, namespace);
	
	EnumClass.Name = enumName;
	
	for i,v in pairs(enumValues) do
		local enumValueObject = EnumClass:Init();
		enumValueObject.Name = v;
		enumValueObject.Value = i;
		EnumClass[v] = enumValueObject;
	end

	return EnumClass;
end


--[[@dox IsEnum
	@namespace Object
	@description Checks if the value is an enum
	@param Variant value
	@param? string typeName
	@returns bool
--]]
function Object:IsEnum(value, typename)
	assert(type(typename) == 'string' or typename == nil, "Argument #2 'typename' to Object::IsEnum - string or nil expected, got " .. type(typename));	
	
	if (self ~= Object) then
	error("Cannot call static member 'IsEnum' (Object::IsEnum) from object " .. self.ClassName); end

	if (typename) then
		return Object:IsObject(value) and value:IsType(typename) and value.IsEnum;	
	else
		return Object:IsObject(value) and value.IsEnum;	
	end
end


Object.Super = Object.Init;

return Object;
