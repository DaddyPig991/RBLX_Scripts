local httpService = game:GetService("HttpService")

local InterfaceManager = {} do
	InterfaceManager.Folder = "FluentSettings"
    InterfaceManager.Settings = {
        Theme = "Dark",
        Acrylic = true,
        Transparency = true,
        MenuKeybind = Enum.KeyCode.Insert,
    }

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

    function InterfaceManager:SetLibrary(library)
		self.Library = library
	end

    function InterfaceManager:BuildFolderTree()
		local paths = {}
		local parts = self.Folder:split("/")
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, "/", 1, idx)
		end

		table.insert(paths, self.Folder)
		table.insert(paths, self.Folder .. "/settings")

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

    function InterfaceManager:SaveSettings()
        local copy = table.clone(self.Settings)
        if typeof(copy.MenuKeybind) == "EnumItem" then
            copy.MenuKeybind = copy.MenuKeybind.Name
        end
        writefile(self.Folder .. "/options.json", httpService:JSONEncode(copy))
    end

    function InterfaceManager:LoadSettings()
        local path = self.Folder .. "/options.json"
        if isfile(path) then
            local data = readfile(path)
            local success, decoded = pcall(httpService.JSONDecode, httpService, data)

            if success then
                for i, v in next, decoded do
                    if i == "MenuKeybind" and typeof(v) == "string" then
                        InterfaceManager.Settings[i] = Enum.KeyCode[v] or Enum.KeyCode.Insert
                    else
                        InterfaceManager.Settings[i] = v
                    end
                end
            end
        end
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")
		local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()

		local section = tab:AddSection("Interface")

		local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
			Title = "Theme",
			Description = "Changes the interface theme.",
			Values = Library.Themes,
			Default = Settings.Theme,
			Callback = function(Value)
				Library:SetTheme(Value)
                Settings.Theme = Value
                InterfaceManager:SaveSettings()
			end
		})
        InterfaceTheme:SetValue(Settings.Theme)
	
		if Library.UseAcrylic then
			section:AddToggle("AcrylicToggle", {
				Title = "Acrylic",
				Description = "The blurred background requires graphic quality 8+",
				Default = Settings.Acrylic,
				Callback = function(Value)
					Library:ToggleAcrylic(Value)
                    Settings.Acrylic = Value
                    InterfaceManager:SaveSettings()
				end
			})
		end
	
		section:AddToggle("TransparentToggle", {
			Title = "Transparency",
			Description = "Makes the interface transparent.",
			Default = Settings.Transparency,
			Callback = function(Value)
				Library:ToggleTransparency(Value)
				Settings.Transparency = Value
                InterfaceManager:SaveSettings()
			end
		})

        -- ✅ Pass .Name (string) as Default to avoid the EnumItem error
		local MenuKeybind = section:AddKeybind("MenuKeybind", {
			Title = "Minimize Bind",
			Default = Settings.MenuKeybind.Name
		})

        -- ✅ Convert back to Enum.KeyCode on change
		MenuKeybind:OnChanged(function()
            local value = MenuKeybind.Value
			if typeof(value) == "string" then
                Settings.MenuKeybind = Enum.KeyCode[value] or Enum.KeyCode.Insert
                InterfaceManager:SaveSettings()
            end
		end)

        Library.MinimizeKeybind = MenuKeybind
    end
end

return InterfaceManager
