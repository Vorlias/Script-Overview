local Object = require(script.Parent.Parent.Utility.ModObject);
local InterpretedType = require(script.Parent.Parent.Enum.InterpretedType_Enum);

local VariableItemWidget = Object:NewClass('VariableItemWidget', require(script.Parent._PluginWidget), {
	operation_tostring = nil
});

local IconOffset = {
	[InterpretedType.ConstantVariable] = Vector2.new(18 * 3, 0),
	[InterpretedType.LocalFunction] = Vector2.new(0, 0),
	[InterpretedType.Table] = Vector2.new(18 * 1, 0),
	[InterpretedType.TableFunction] = Vector2.new(0, 0),
	[InterpretedType.TableMethod] = Vector2.new(0, 0),
	[InterpretedType.Variable] = Vector2.new(18 * 2),
	[InterpretedType.ModuleScript] = Vector2.new(18 * 5, 0);
	Default = Vector2.new(18 * 2),
}

local ICONS_ID = 'rbxassetid://1691493749';

local ui = script.Parent.UI.VariableItemWidget;

--[[@dox VariableItemWidget.new 
	Test
	@namespace VariableItemWidget
	@returns VariableItemWidget
	@constructor
--]]
function VariableItemWidget.new(result, scriptTarget)
	--assert(Object:IsObject(browserWidget, "BrowserWidget"), "Requires BrowserWidget");
	assert(typeof(result) == 'table');
	assert(InterpretedType:IsValue(result.Type), 'Invalid Enum value for variableType: ' .. Object:TypeName(result.Type));
	assert(typeof(scriptTarget) == 'Instance' and scriptTarget:IsA("LuaSourceContainer"), 'scriptTarget ' .. tostring(scriptTarget) .. ' is not a LuaSourceContainer!');
	---assert(typeof(scriptLine) == 'number');
	local scriptLine = result.Line;
	--VariableItemWidget.new(self, result.Name, result.Type, self.ScriptTarget, result.Line, result.Icon);
		
--[[
		VariableItemWidget.new(self, result, self.ScriptTarget);
		VariableItemWidget.new(self, result.Name, result.Type, self.ScriptTarget, result.Line, result.Icon);
--]]		
			
	local gui = ui.Item:Clone();
	
	gui.Icon.Image = ICONS_ID;
	gui.Icon.ImageRectSize = Vector2.new(18, 18);
	gui.Icon.ImageRectOffset = IconOffset[result.Type] or IconOffset.Default;
	
	gui.MouseEnter:connect(function()
		gui.Image = 'rbxassetid://1685309204';
	end);
	
	gui.MouseLeave:connect(function()
		gui.Image = '';
	end)
	
	gui.ItemName.Text = result.Name;
	
	--gui.Parent = browserWidget.ContentsScrollingFrame.Contents;
	local clickEvent = Instance.new("BindableEvent", gui);
	
	gui.MouseButton1Down:connect(function()
		clickEvent:Fire();
	end)
	
	local self = VariableItemWidget:Init()
	self.GuiObject = gui;
	self.Script = scriptTarget;
	self.Line = scriptLine;
	self.MouseButton1Down = clickEvent.Event;
	return self, gui;
end

return VariableItemWidget;