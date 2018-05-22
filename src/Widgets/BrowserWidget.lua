local Object = require(script.Parent.Parent.Utility.ModObject);

local BrowserWidget = Object:NewClass('BrowserWidget', require(script.Parent._PluginWidget), {
	operation_tostring = nil
});

local VariableItemWidget = require(script.Parent.VariableItemWidget);
local GroupItemWidget = require(script.Parent.GroupItemWidget);

function BrowserWidget:ClearResults()
	local scrollGui = self.ContentsScrollingFrame.Contents;
	for _, child in next, scrollGui:GetChildren() do
		if (child:IsA("GuiBase2d")) then
			child:Destroy();
		end
	end	
end

function BrowserWidget:RegisterItem(item)
	assert(Object:IsObject(item, 'VariableItemWidget') or Object:IsObject(item, 'GroupItemWidget'));
	if (item:IsType("GroupItemWidget")) then
		item.MouseButton1Down:connect(function()
			item:Toggle();
			self:AutoResizeContents();		
		end)
		
		table.insert(self.Items, item);
	else
		item.MouseButton1Down:connect(function()
			self.Plugin:OpenScript(item.Script, item.Line);
		end)
		
		table.insert(self.Items, item);
	end		
end

function BrowserWidget:AddItem(item)
	assert(Object:IsObject(item, 'VariableItemWidget') or Object:IsObject(item, 'GroupItemWidget'));

	self:RegisterItem(item);
	item.GuiObject.Parent = self.ContentsScrollingFrame.Contents;
end

function BrowserWidget:UpdateResults(resultsList)
	self:ClearResults();
	self.Items = {};	
	
	if (resultsList.__constants) then
		for _, result in next, resultsList.__constants do
			self:AddItem(VariableItemWidget.new(result, self.ScriptTarget));
		end
	end
	
	if (resultsList.__locals) then	
		for _, result in next, resultsList.__locals do
			self:AddItem(VariableItemWidget.new(result, self.ScriptTarget));
		end
	end
		
	if (resultsList.__environment) then	
		for _, result in next, resultsList.__environment do
			self:AddItem(VariableItemWidget.new(result, self.ScriptTarget));
		end
	end
	
	for namespaceName, namespace in next, resultsList do
		if (namespaceName ~= "__locals" and namespaceName ~= "__environment" and namespaceName ~= "__constants") then
			print("Attempt Add", namespaceName, "namespace");
			if (namespace.Children and #namespace.Children > 0) then
				self:AddItem(GroupItemWidget.new(self, namespace, self.ScriptTarget));
			else
				self:AddItem(VariableItemWidget.new(namespace, self.ScriptTarget));
			end
			
		end
	end
	
	self:AutoResizeContents();
end

function BrowserWidget:RemoveScriptTarget()
	self.ScriptTarget = nil;
end

function BrowserWidget:SetScriptTarget(scriptTarget)
	assert(typeof(scriptTarget) == 'Instance' and scriptTarget:IsA("LuaSourceContainer"));
	
	self.ScriptTarget = scriptTarget;
end

function BrowserWidget:AutoResizeContents()
	game:GetService("RunService").Stepped:Wait();
	local scrollGui = self.ContentsScrollingFrame;
	local contentSize = scrollGui.Contents.UIListLayout.AbsoluteContentSize;
	scrollGui.CanvasSize = UDim2.new(0, contentSize.X, 0, contentSize.Y);
end

local ui = script.Parent.UI.BrowserWidget;

function BrowserWidget.new(plugin, parentTo)
	local gui = ui.BrowserWidget:Clone();
	local filterInput = gui.Filter.Contents.FilterInput;
	local contentsScrollFrame = gui.Contents.ContentsScrolling;
	local scrollButtons = gui.Contents.ScrollButtons;
	gui.Parent = parentTo;

	local self = BrowserWidget:Init()
	self.GuiObject = gui;
	self.Items = {};
	self.Plugin = plugin;
	self.FilterInput = filterInput;
	self.ContentsScrollingFrame = contentsScrollFrame;
	
	game:GetService("RunService").RenderStepped:connect(function()
		local contentSize = contentsScrollFrame.AbsoluteSize;
		local viewSize = contentsScrollFrame.AbsoluteWindowSize;
		if (contentSize.X > viewSize.X) then
			scrollButtons.Visible = true;
		else
			scrollButtons.Visible = false;
		end
	end);
	
	return self, gui;
end

return BrowserWidget;