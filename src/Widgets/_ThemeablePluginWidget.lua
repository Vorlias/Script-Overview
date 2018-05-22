local Object = require(script.Parent.Parent.Utility.ModObject);

local ThemeablePluginWidget = Object:NewClass('ThemeablePluginWidget', require(script.Parent._PluginWidget), {
	operation_tostring = nil
});

function ThemeablePluginWidget.new(primaryColor, secondaryColor)
	local self = ThemeablePluginWidget:Init()
	self.ThemeColor = {Primary = primaryColor, Secondary = secondaryColor};
	return self;
end

return ThemeablePluginWidget;