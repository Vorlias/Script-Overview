
local partsWithId = {}
local awaitRef = {}

local Theme = shared.ThemeSettings:GetSettings();

local root = {
	ID = 0;
	Type = "ImageButton";
	Properties = {
		Name = "Item";
		Size = UDim2.new(1,0,0,20);
		BorderColor3 = Theme.BorderColor3;
		BackgroundColor3 = Theme.BackgroundColor3;
		BorderSizePixel = 0;
		AutoButtonColor = false;
	};
	Children = {
		{
			ID = 1;
			Type = "Frame";
			Properties = {
				LayoutOrder = 1;
				Name = "Contents";
				Size = UDim2.new(1,0,0,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Theme.BorderColor3;
			};
			Children = {
				{
					ID = 2;
					Type = "UIListLayout";
					Properties = {};
					Children = {};
				};
				{
					ID = 3;
					Type = "UIPadding";
					Properties = {
						PaddingLeft = UDim.new(0,20);
					};
					Children = {};
				};
			};
		};
		{
			ID = 4;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 1;
				Size = UDim2.new(1,0,0,20);
				Name = "Header";
				BackgroundColor3 = Theme.BackgroundColor3;
			};
			Children = {
				{
					ID = 5;
					Type = "ImageLabel";
					Properties = {
						Image = "rbxassetid://1691615388";
						Name = "DropArrow";
						Position = UDim2.new(0,2,0,1);
						ImageRectSize = Vector2.new(16,16);
						BackgroundTransparency = 1;
						Size = UDim2.new(0,18,0,18);
						BackgroundColor3 = Theme.BackgroundColor3;
					};
					Children = {};
				};
				{
					ID = 6;
					Type = "ImageLabel";
					Properties = {
						Image = "rbxassetid://656467823";
						Name = "Icon";
						Position = UDim2.new(0,18,0,1);
						ImageRectSize = Vector2.new(18,18);
						BackgroundTransparency = 1;
						Size = UDim2.new(0,18,0,18);
						BackgroundColor3 = Theme.BackgroundColor3;
					};
					Children = {};
				};
				{
					ID = 7;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Theme.TextColor3;
						Text = "testFunction";
						TextXAlignment = Enum.TextXAlignment.Left;
						Font = Enum.Font.SourceSansItalic;
						Name = "ItemName";
						Position = UDim2.new(0,40,0,0);
						BackgroundTransparency = 1;
						Size = UDim2.new(0.5,0,0,20);
						TextSize = 14;
						BackgroundColor3 = Theme.BackgroundColor3;
					};
					Children = {};
				};
				{
					ID = 8;
					Type = "TextLabel";
					Properties = {
						Visible = false;
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Theme.TextColor3;
						Text = "function";
						TextXAlignment = Enum.TextXAlignment.Left;
						Font = Enum.Font.SourceSans;
						Name = "ItemType";
						Position = UDim2.new(0,25,0,0);
						BackgroundTransparency = 1;
						Size = UDim2.new(0.5,0,0,20);
						TextSize = 14;
						BackgroundColor3 = Theme.BackgroundColor3;
					};
					Children = {};
				};
				{
					ID = 9;
					Type = "Frame";
					Properties = {
						Visible = false;
						Name = "Deprecated";
						Position = UDim2.new(0,8,0,10);
						BorderColor3 = Theme.BorderColor3;
						Size = UDim2.new(0,10,0,0);
						BackgroundColor3 = Theme.BackgroundColor3;
					};
					Children = {};
				};
			};
		};
		{
			ID = 10;
			Type = "UIListLayout";
			Properties = {
				SortOrder = Enum.SortOrder.LayoutOrder;
			};
			Children = {};
		};
	};
};

local function Scan(item, parent)
	local obj = Instance.new(item.Type)
	if (item.ID) then
		local awaiting = awaitRef[item.ID]
		if (awaiting) then
			awaiting[1][awaiting[2]] = obj
			awaitRef[item.ID] = nil
		else
			partsWithId[item.ID] = obj
		end
	end
	for p,v in pairs(item.Properties) do
		if (type(v) == "string") then
			local id = tonumber(v:match("^_R:(%w+)_$"))
			if (id) then
				if (partsWithId[id]) then
					v = partsWithId[id]
				else
					awaitRef[id] = {obj, p}
					v = nil
				end
			end
		end
		obj[p] = v
	end
	for _,c in pairs(item.Children) do
		Scan(c, obj)
	end
	obj.Parent = parent
	return obj
end

return function() return Scan(root, nil) end