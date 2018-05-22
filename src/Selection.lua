local Signal = require(script.Parent.Parent.modules.Signal);
local SelectionService = game:GetService("Selection");
local Selection = {};
Selection.__index = Selection;

function Selection:CreateSelectionSignal(className)
    local signal = Signal.new();
    self._signals[className] = signal;
    return signal;
end

function Selection.new()
    local self = {
        _enabled = false,
        _selected = {},
        _signals = {};
    };

    local function onSelectionChanged()
        local selection = SelectionService:Get();
        if (#selection > 0) then
            for _, selected in next, selection do
                local inArray = false;

                for _, existing in next, self._selected do
                    if selected == existing then
                        inArray = true;
                    end
                end

                if not inArray then
                    table.insert(self._selected, selected);

                    for signalName, signal in next, self._signals do
                        if (selected:IsA(signalName)) then
                            signal:Fire(selected, true);
                        end
                    end
                end
            end

            for i, selected in next, self._selected do
                local inArray = false;

                for _, existing in next, selection do
                    if selected == existing then
                        inArray = true;
                    end
                end

                if not inArray then
                    table.remove(self._selected, i);

                    for signalName, signal in next, self._signals do
                        if (selected:IsA(signalName)) then
                            signal:Fire(selected, false);
                        end
                    end
                end
            end
        else
            for _, selected in next, self._selected do
                for signalName, signal in next, self._signals do
                    if (selected:IsA(signalName)) then
                        signal:Fire(selected, false);
                    end
                end
            end
        end
    end
    SelectionService.SelectionChanged:Connect(onSelectionChanged);

    setmetatable(self, Selection);
    return self;
end

return Selection;