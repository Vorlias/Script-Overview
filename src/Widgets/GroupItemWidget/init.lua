local Object = require(script.Parent.Parent.Utility.ModObject);
local InterpretedType = require(script.Parent.Parent.Enum.InterpretedType_Enum);
local VariableItemWidget = require(script.Parent.VariableItemWidget);

local GroupItemWidget = Object:NewClass('GroupItemWidget', require(script.Parent._PluginWidget), {
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

function GroupItemWidget:AddChild(item)
	assert(Object:IsObject(item, "VariableItemWidget"));
	local childGui = item.GuiObject;
	local gui = self.GuiObject;
	local open = self.IsOpen;
	childGui.Parent = gui.Contents;
	childGui.Visible = open;
	table.insert(self.Items, item);
end

function GroupItemWidget:Update()
	local gui = self.GuiObject;

	game:GetService("RunService").Stepped:Wait();
	local contents = gui.Contents;	
	local absSizeInner = gui.Contents.UIListLayout.AbsoluteContentSize;
	
	contents.Size = UDim2.new(1, 0, 0, absSizeInner.Y);
	
	game:GetService("RunService").Stepped:Wait();
	local absSize = gui.UIListLayout.AbsoluteContentSize;	
	gui.Size = UDim2.new(1, 0, 0, absSize.Y);
	
end

function GroupItemWidget:Toggle()
	self.IsOpen = not self.IsOpen;
	local gui = self.GuiObject;	
	local open = self.IsOpen;	
	gui.Header.DropArrow.Rotation = open and 90 or 0;
	
	for _, child in next, self.Items do
		child.GuiObject.Visible = open;
	end
	
	self:Update();
end

--[[@dox GroupItemWidget.new 
	Test
	@namespace GroupItemWidget
	@returns GroupItemWidget
	@constructor
--]]
function GroupItemWidget.new(bw, namespace, scriptTarget)
	assert(typeof(namespace) == 'table');
	assert(typeof(scriptTarget) == 'Instance' and scriptTarget:IsA("LuaSourceContainer"));
	local scriptLine = namespace and namespace.Line;
			
	local gui = require(script.UI)();
	
	gui.Header.Icon.Image = ICONS_ID;
	gui.Header.Icon.ImageRectSize = Vector2.new(18, 18);
	gui.Header.Icon.ImageRectOffset = IconOffset[namespace.Type] or IconOffset.Default;
	
	gui.MouseEnter:connect(function()
		gui.Image = 'rbxassetid://1685309204';
	end);
	
	gui.MouseLeave:connect(function()
		gui.Image = '';
	end)
	
	gui.Header.ItemName.Text = tostring(namespace.Name);
	
	--gui.Parent = browserWidget.ContentsScrollingFrame.Contents;
	local clickEvent = Instance.new("BindableEvent", gui);
	
	gui.MouseButton1Down:connect(function()
		clickEvent:Fire();
	end)
	
	local self = GroupItemWidget:Init()
	self.GuiObject = gui;
	self.IsOpen = false;
	self.Items = {};
	self.Script = scriptTarget;
	self.Line = scriptLine;
	self.MouseButton1Down = clickEvent.Event;
	
	if (namespace) then
		for _, result in next, namespace.Children do
			local item = VariableItemWidget.new(result, self.Script);

			self:AddChild(item);
			bw:RegisterItem(item, true);
		end
	end
	
	spawn(function()
		self:Update();
	end);
	
	return self, gui;
end

return GroupItemWidget;