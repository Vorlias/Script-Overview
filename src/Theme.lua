local settings = settings();

function isThemeSwitchingEnabled()
	return settings:GetFFlag("StudioThemeSwitchingEnabled");
end

local Theme = {
	Dark = 1;
	Light = 0;


	DarkSettings = {
		BackgroundColor3 = Color3.fromRGB(46, 46, 46);
		TitleColor3 = Color3.fromRGB(53, 53, 53);
		InputColor3 = Color3.fromRGB(37, 37, 37);
		BorderColor3 = Color3.fromRGB(34, 34, 34);
		SelectionColor3 = Color3.fromRGB(53, 181, 255);
		TextColor3 = Color3.fromRGB(170, 170, 170);
	};

	LightSettings = {
		BackgroundColor3 = Color3.new(1,1,1);
		TitleColor3 = Color3.fromRGB(208, 208, 208);
		BorderColor3 = Color3.fromRGB(196, 196, 196);
		InputColor3 = Color3.new(1,1,1);
		SelectionColor3 = Color3.fromRGB(96, 140, 210);
		TextColor3 = Color3.fromRGB(30, 30, 30);
	};
}

function getThemeType()
	local uiTheme = isThemeSwitchingEnabled() and settings.Studio["UI Theme"];
	if (uiTheme) then
		if (uiTheme == Enum.UITheme.Dark) then 
			return Theme.Dark;
		else
			return Theme.Light;
		end
	else
		return Theme.Light;
	end
end

function Theme:GetTheme()
	return getThemeType();
end

function Theme:GetSettings()
	local theme = self:GetTheme();
	if (theme == self.Light) then 
		return self.LightSettings;
	else
		return self.DarkSettings;
	end
end

shared.ThemeSettings = setmetatable({}, {__index = Theme});
return Theme;