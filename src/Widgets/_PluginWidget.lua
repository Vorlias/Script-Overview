local Object = require(script.Parent.Parent.Utility.ModObject);

local PluginWidget = Object:NewClass('PluginWidget', nil, {
	operation_tostring = nil
});

function PluginWidget:IsThemeable()
	return self:IsType("ThemeablePluginWidget");
end

function PluginWidget.new()
	local self = PluginWidget:Init()
	return self;
end

return PluginWidget;