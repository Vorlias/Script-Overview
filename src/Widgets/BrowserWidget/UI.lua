
local partsWithId = {}
local awaitRef = {}

local Theme = shared.ThemeSettings:GetSettings();

local root = {
	ID = 0;
	Type = "Frame";
	Properties = {
		Size = UDim2.new(1,0,1,0);
		Name = "BrowserWidget";
		BackgroundColor3 = Theme.BackgroundColor3;
	};
	Children = {
		{
			ID = 1;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 1;
				Size = UDim2.new(1,0,0,20);
				Name = "Filter";
				BackgroundColor3 = Theme.InputColor3;
			};
			Children = {
				{
					ID = 2;
					Type = "Frame";
					Properties = {
						Name = "Contents";
						Position = UDim2.new(0,1,0,1);
						BorderColor3 = Theme.BorderColor3;
						Size = UDim2.new(1,-2,0,18);
						BackgroundColor3 = Theme.BackgroundColor3;
					};
					Children = {
						{
							ID = 3;
							Type = "TextBox";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								BorderColor3 = Theme.BorderColor3;
								Text = "";
								PlaceholderColor3 = Theme.TextColor3;
								TextColor3 = Theme.TextColor3;
								BackgroundTransparency = 1;
								Font = Enum.Font.SourceSans;
								Name = "FilterInput";
								TextXAlignment = Enum.TextXAlignment.Left;
								Size = UDim2.new(1,-1,1,-1);
								PlaceholderText = "Filter Script (NotYetImplemented)";
								TextSize = 14;
								BackgroundColor3 = Theme.BackgroundColor3;
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 4;
			Type = "Frame";
			Properties = {
				LayoutOrder = 1;
				Name = "Contents";
				Position = UDim2.new(0,1,0,25);
				BorderColor3 = Theme.BorderColor3;
				Size = UDim2.new(1,-2,1,-26);
				BackgroundColor3 = Theme.BackgroundColor3;
			};
			Children = {
				{
					ID = 5;
					Type = "ScrollingFrame";
					Properties = {
						MidImage = "rbxassetid://37912058";
						BorderColor3 = Theme.BorderColor3;
						ScrollBarThickness = 15;
						VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
						Name = "ContentsScrolling";
						TopImage = "rbxassetid://37912058";
						Size = UDim2.new(1,0,1,0);
						BottomImage = "rbxassetid://37912058";
						BackgroundColor3 = Theme.BackgroundColor3;
						CanvasSize = UDim2.new(0,0,0,0);
					};
					Children = {
						{
							ID = 6;
							Type = "Frame";
							Properties = {
								Size = UDim2.new(1,0,1,0);
								BorderSizePixel = 0;
								BackgroundColor3 = Theme.BackgroundColor3;
							};
							Children = {};
						};
						{
							ID = 7;
							Type = "Frame";
							Properties = {
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,0);
								Name = "Contents";
								BackgroundColor3 = Theme.BackgroundColor3;
							};
							Children = {
								{
									ID = 8;
									Type = "UIListLayout";
									Properties = {
										Padding = UDim.new(5,1);
									};
									Children = {};
								};
							};
						};
					};
				};
				{
					ID = 9;
					Type = "Frame";
					Properties = {
						BackgroundTransparency = 1;
						Size = UDim2.new(1,0,1,0);
						Name = "ScrollButtons";
						BackgroundColor3 = Theme.BackgroundColor3;
					};
					Children = {
						{
							ID = 10;
							Type = "ImageButton";
							Properties = {
								Name = "ScrollUp";
								Position = UDim2.new(1,-15,0,0);
								BorderColor3 = Color3.new(0.76862752437592,0.76862752437592,0.76862752437592);
								Size = UDim2.new(0,15,0,15);
								BackgroundColor3 = Theme.BackgroundColor3;
								AutoButtonColor = false;
							};
							Children = {};
						};
						{
							ID = 11;
							Type = "ImageButton";
							Properties = {
								Name = "ScrollDown";
								Position = UDim2.new(1,-15,1,-15);
								BorderColor3 = Color3.new(0.76862752437592,0.76862752437592,0.76862752437592);
								Size = UDim2.new(0,15,0,15);
								BackgroundColor3 = Theme.BackgroundColor3;
								AutoButtonColor = false;
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 12;
			Type = "Frame";
			Properties = {
				Visible = false;
				Name = "ExtraInfo";
				Position = UDim2.new(0,0,1,-200);
				BorderColor3 = Color3.new(0.67058825492859,0.67058825492859,0.67058825492859);
				Size = UDim2.new(1,0,0,200);
				BackgroundColor3 = Color3.new(0.8156863451004,0.8156863451004,0.8156863451004);
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