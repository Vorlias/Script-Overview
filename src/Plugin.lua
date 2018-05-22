local Config = require(script.Parent.Config);
local Plugin = {};
Plugin.__index = Plugin;

function Plugin:GetWindowState()
    return {
        Enabled = self._window.Enabled,
        Title = self._window.Title,
        Restored = self._window.HostWidgetWasRestored,
    };
end

function Plugin:GetWindow()
    return self._window;
end

function Plugin:Refresh()

end

function Plugin:Toggle()
    self._enabled = not self._enabled;
    self._window.Enabled = self._enabled;

    return self._enabled;
end

function Plugin.new(plugin)
    assert(typeof(plugin) == "Instance" and plugin:IsA("Plugin"));
    local self = {
        _enabled = false;
        _window = nil,
        _windowButon = nil,
    };

    -- Setup Window
    do
        local window;
        local info = DockWidgetPluginGuiInfo.new(
            Config.Window.DockState,
            Config.Window.InitialEnabled,
            Config.Window.OverrideEnabled,
            Config.Window.Size.X,
            Config.Window.Size.Y
        );

        window = plugin:CreateDockWidgetPluginGui(Config.Id, info);
        window.Title = Config.Window.Title;
        window.Name = "ScriptBrowserV2";
        self._window = window;
    end

    setmetatable(self, Plugin)
    return self;
end

return Plugin;