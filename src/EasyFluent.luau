local EasyFluent = {}

local Connections: { [string]: any } = {}
local folder_name: string = 'EasyFluent'

type TabConfig = {
    Title: string,
    Icon: string?,
}

type ParagraphConfig = {
    Title: string,
    Content: string,
}

type ButtonConfig = {
    Title: string,
    Description: string,
    Callback: (any) -> ()?,
}

type DialogConfig = {
    Title: string,
    Content: string,
    Buttons: { any },
}

type ToggleConfig = {
    Title: string,
    Description: string,
    Flag: string,
    Default: boolean,
    Callback: (boolean) -> (),
}

type SliderConfig = {
    Title: string,
    Description: string,
    Min: number,
    Max: number,
    Default: number,
    Rounding: number,
    Flag: string,
    Callback: (number) -> ()?,
}

type DropdownConfig = {
    Title: string,
    Values: { [any]: string }?,
    Multi: boolean,
    Default: any,
    Flag: string,
    Callback: (any) -> ()?,
}

type KeybindConfig = {
    Title: string,
    Mode: string,
    Default: string,
    Flag: string,
    Callback: (boolean) -> ()?,
}

type InputConfig = {
    Title: string,
    Default: string?,
    Placeholder: string,
    Numeric: boolean,
    Finished: boolean,
    Flag: string,
    Callback: (string) -> ()?,
}

type NotificationConfig = {
    Title: string,
    Content: string,
    Duration: number,
}

cloneref = cloneref or function(...) return ... end
local HttpService = cloneref(game:GetService('HttpService'))

local Fluent = loadstring(game:HttpGet('https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua'))()

local ClientConfig: { [string]: any } = {}
local ReadConfig: { [string]: any } = {}

function EasyFluent.save_config()
    if not isfolder(folder_name) then
        makefolder(folder_name)
    end

    if not isfolder(`{folder_name}/config/{game.PlaceId}.json`) then
        makefolder(`{folder_name}/config/{game.PlaceId}.json`)
    end

    if not isfile(`{folder_name}/config/{game.PlaceId}.json`) then
        writefile(`{folder_name}/config/{game.PlaceId}.json`, HttpService:JSONEncode({}))
    end

    for index, value in pairs(Connections) do
        if type(value) == 'table' then
            ClientConfig[index] = HttpService:JSONDecode(HttpService:JSONEncode(value))
        else
            ClientConfig[index] = value
        end
    end

    pcall(function()
        writefile(`{folder_name}/config/{game.PlaceId}.json`, HttpService:JSONEncode(ClientConfig))
    end)
end

function EasyFluent.read_config()
    if not isfolder(folder_name) or not isfile(`{folder_name}/config/{game.PlaceId}.json`) then
        EasyFluent.save_config()
    end

    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(`{folder_name}/config/{game.PlaceId}.json`))
    end)

    if success and result then
        ReadConfig = result

        for index, value in pairs(ReadConfig) do
            Connections[index] = value
        end
    else
        ReadConfig = {}
    end

    return ReadConfig
end

local caller = EasyFluent.read_config()

function EasyFluent:create_window(window)
    local _, window_instance = pcall(function()
        return Fluent:CreateWindow({
            Title = window.Title or 'EasyFluent',
            SubTitle = window.SubTitle or '',
            TabWidth = window.TabWidth or 95,
            Size = window.Size or UDim2.fromOffset(440, 315),
            Acrylic = window.Acrylic or false,
            Theme = window.Theme or 'Darker',
            MinimizeKey = window.MinimizeKey or Enum.KeyCode.Insert
        })
    end)

    return window_instance
end

function EasyFluent:notify(notification: NotificationConfig)
    notification.Title = notification.Title or 'Notification'
    notification.Content = notification.Content or 'Content'
    notification.Duration = notification.Duration or 5

    return Fluent:Notify(notification)
end

function EasyFluent:create_tab(window: any, tab: TabConfig)
    local tab_connection = window:AddTab(tab)

    function tab_connection:create_paragraph(paragraph: ParagraphConfig)
        local paragraph_title = paragraph.Title or 'Response'
        local paragraph_content = paragraph.Content or 'Content'

        local paragraph_connection = tab_connection:AddParagraph({
            Title = paragraph_title,
            Content = paragraph_content
        })

        function paragraph_connection:set()
            paragraph_connection:SetTitle(paragraph_title)
            paragraph_connection:SetDesc(paragraph_content)
        end

        return paragraph_connection
    end

    function tab_connection:create_button(button: ButtonConfig)
        button.Title = button.Title or 'Button'
        button.Description = button.Description or ''
        button.Callback = button.Callback or function() end

        return tab_connection:AddButton(button)
    end

    function tab_connection:create_dialog(dialog: DialogConfig)
        dialog.Title = dialog.Title or ''
        dialog.Content = dialog.Content or ''
        dialog.Buttons = dialog.Buttons or {}

        return window:Dialog(dialog)
    end

    function tab_connection:create_toggle(connection: string, toggle: ToggleConfig)
        toggle.Title = toggle.Title or 'Toggle'
        toggle.Description = toggle.Description or ''
        toggle.Flag = toggle.Flag or connection
        toggle.Default = (type(caller[toggle.Flag]) == 'boolean' and caller[toggle.Flag]) or (type(Connections[toggle.Flag]) == 'boolean' and Connections[toggle.Flag]) or false

        local actual_callback = toggle.Callback or function() end

        toggle.Callback = function(value: boolean)
            Connections[toggle.Flag] = value
            actual_callback(value)

            EasyFluent.save_config()
        end

        local toggle_connection = tab_connection:AddToggle(connection, toggle)

        function toggle_connection:set(bool: boolean)
            Fluent.Options[connection]:SetValue(bool)
            Connections[toggle.Flag] = bool

            EasyFluent.save_config()
        end

        return toggle_connection
    end

    function tab_connection:create_slider(connection: string, slider: SliderConfig)
        local default_config = {
            Title = 'Slider',
            Description = '',
            Min = 0,
            Max = 5,
            Default = 2, Rounding = 1,
            Callback = function(_) end
        }

        slider.Flag = slider.Flag or connection

        if not tonumber(caller[slider.Flag]) and not tonumber(Connections[slider.Flag]) then
            Connections[slider.Flag] = slider.Min or default_config.Min
        end

        slider.Default = tonumber(caller[slider.Flag]) or tonumber(Connections[slider.Flag]) or default_config.Default
        local actual_callback = slider.Callback or default_config.Callback

        for index, value in pairs(default_config) do
            if slider[index] == nil then
                slider[index] = value
            end
        end

        slider.Callback = function(value: number)
            Connections[slider.Flag] = value
            actual_callback(value)

            EasyFluent.save_config()
        end

        local new_slider = tab_connection:AddSlider(connection, slider)

        function new_slider:set(value: number)
            new_slider:SetValue(value)
            Connections[slider.Flag] = value

            EasyFluent.save_config()
        end

        return new_slider
    end

    function tab_connection:create_dropdown(connection: string, dropdown: DropdownConfig)
        local dropdown_default = {
            Title = 'Dropdown',
            Values = {},
            Multi = false,
            Default = nil,
            Callback = function(_) end
        }

        dropdown.Flag = dropdown.Flag or connection

        if dropdown.Multi then
            if type(caller[dropdown.Flag]) ~= 'table' and type(Connections[dropdown.Flag]) ~= 'table' then
                Connections[dropdown.Flag] = {}

                for _, value in pairs(dropdown.Values or {}) do
                    Connections[dropdown.Flag][value] = false
                end
            end
        elseif caller[dropdown.Flag] == nil and Connections[dropdown.Flag] == nil then
            Connections[dropdown.Flag] = dropdown.Default
        end

        dropdown.Default = caller[dropdown.Flag] or Connections[dropdown.Flag]

        for index, value in pairs(dropdown_default) do
            if dropdown[index] == nil then
                dropdown[index] = value
            end
        end

        local new_dropdown = tab_connection:AddDropdown(connection, dropdown)

        new_dropdown:OnChanged(function(value: any)
            Connections[dropdown.Flag] = value

            EasyFluent.save_config()
        end)

        function new_dropdown:set(value: any)
            new_dropdown:SetValue(value)
            Connections[dropdown.Flag] = value

            EasyFluent.save_config()
        end

        return new_dropdown
    end

    function tab_connection:create_keybind(connection: string, keybind: KeybindConfig)
        local keybind_default = {
            Title = 'Title',
            Mode = 'Toggle',
            Default = 'LeftControl',
            Callback = function(_) end
        }

        keybind.Flag = keybind.Flag or connection
        local saved = caller[keybind.Flag] or Connections[keybind.Flag]

        keybind.Default = (type(saved) == 'string' and saved) or keybind_default.Default
        local actual_callback = keybind.Callback or keybind_default.Callback

        for index, value in pairs(keybind_default) do
            if keybind[index] == nil then
                keybind[index] = value
            end
        end

        keybind.Callback = function(value: string)
            Connections[keybind.Flag] = value
            actual_callback(value)

            EasyFluent.save_config()
        end

        return tab_connection:AddKeybind(connection, keybind)
    end

    function tab_connection:create_input(connection: string, input: InputConfig)
        local input_default = {
            Title = 'Input',
            Default = '',
            Placeholder = 'Placeholder',
            Numeric = false,
            Finished = true,
            Callback = function(_) end
        }

        input.Flag = input.Flag or connection
        local saved = caller[input.Flag] or Connections[input.Flag]

        input.Default = (type(saved) == 'string' and saved) or input_default.Default
        local actual_callback = input.Callback or input_default.Callback

        for index, value in pairs(input_default) do
            if input[index] == nil then
                input[index] = value
            end
        end

        input.Callback = function(value: string)
            Connections[input.Flag] = value
            actual_callback(value)

            EasyFluent.save_config()
        end

        return tab_connection:AddInput(connection, input)
    end

    return tab_connection
end

return EasyFluent
