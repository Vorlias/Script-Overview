local Config = require(script.Parent.Config);
local Plugin = require(script.Parent.Plugin);
local Selection = require(script.Parent.Selection);
local BrowserWidget = require(script.Parent.Widgets.BrowserWidget);
local Parser = require(script.Parent.Parser);
local Theme = require(script.Parent.Theme);

local selection = Selection.new();
local plScriptBrowser = Plugin.new(plugin);
local wndState = plScriptBrowser:GetWindowState();
local window = plScriptBrowser:GetWindow();
local browser = BrowserWidget.new(plugin, window);
local version = string.format("%d.%d.%d", Config.Version[1], Config.Version[2], Config.Version[3]);
local active = wndState.Enabled;

local toolbar = plugin:CreateToolbar(
    string.format("%s %s", Config.Window.Title, version)
);

local selectedItem; -- TODO: Multi-select display eventually:tm:
local function updateBrowserDisplay()
    if (selectedItem) then 
        browser:UpdateResults(Parser.parse(selectedItem.Source):Raw());
    else
        browser:UpdateResults({});
    end
end

-- Toggle Button --
local toggleButton do
    toggleButton = toolbar:CreateButton(
        Config.Buttons.Toggle.Name,
        Config.Buttons.Toggle.Tooltip,
        Config.Buttons.Toggle.Icon
    );

    local function onToggle()
        local toggleResult = plScriptBrowser:Toggle();
        toggleButton:SetActive(toggleResult);
        active = toggleResult;
    end
    toggleButton.ClickableWhenViewportHidden = true;
    toggleButton.Click:Connect(onToggle);
    toggleButton:SetActive(wndState.Enabled);
end

local refreshButton do
    local function onRefresh()
        if (selectedItem) then
            updateBrowserDisplay();
        end
    end

    refreshButton = toolbar:CreateButton(
        Config.Buttons.Refresh.Name,
        Config.Buttons.Refresh.Tooltip,
        Config.Buttons.Refresh.Icon
    );
    refreshButton.ClickableWhenViewportHidden = true;
    refreshButton.Enabled = false;
    refreshButton.Click:Connect(onRefresh);
end



selection:CreateSelectionSignal("LuaSourceContainer"):Connect(function(item, selected)
    if (active) then
        if (selected) then
            refreshButton.Enabled = true;
            selectedItem = item;
            browser:SetScriptTarget(item);
            updateBrowserDisplay();
            
        elseif (selectedItem == item) then
            refreshButton.Enabled = false;
            selectedItem = nil;
            browser:RemoveScriptTarget();
            updateBrowserDisplay();
            
        end
    end
end)

print(string.format("[ScriptBrowser] ScriptBrowser v%s loaded.", version));