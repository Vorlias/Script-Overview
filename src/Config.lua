return {
    Id = "com.vorlias.scriptbrowser-2.1",
    Version = {2, 0, 1},
    IsDevelopment = true,
    Buttons = {
        Toggle = {
            Name = "Script Browser",
            Icon = "rbxassetid://1692035674",
            Tooltip = "Toggle the Script Overview interface"
        },
        Refresh = {
            Name = "Refresh",
            Icon = "rbxassetid://1692059408",
            Tooltip = "Refresh the Script Overview interface"
        },
    },
    Window = {
        Title = "Script Browser",
        DockState = Enum.InitialDockState.Left,
        InitialEnabled = true,
        OverrideEnabled = false,
        Size = Vector2.new(400, 300),
    },
}