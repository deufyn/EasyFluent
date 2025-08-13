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

function EasyFluent.save_config(): ''
    if not isfolder(folder_name) then
        makefolder(folder_name)
    end

    if not isfolder(`{folder_name}/config`) then
        makefolder(`{folder_name}/config`)
    end

    if not isfile(`{folder_name}/config/{game.PlaceId}.json`) then
        writefile(`{folder_name}/config/{game.PlaceId}.json`, HttpService:JSONEncode({}))
    end

    for index: string, value: any in pairs(Connections) do
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

function EasyFluent.read_config(): { [string]: any }
    if not isfolder(folder_name) or not isfile(`{folder_name}/config/{game.PlaceId}.json`) then
        EasyFluent.save_config()
    end

    local success: boolean, result: { [string]: any }? = pcall(function()
        return HttpService:JSONDecode(readfile(`{folder_name}/config/{game.PlaceId}.json`))
    end)

    if success and result then
        ReadConfig = result

        for index: string, value: any in pairs(ReadConfig) do
            Connections[index] = value
        end
    else
        ReadConfig = {}
    end

    return ReadConfig
end

local caller: { [string]: any } = EasyFluent.read_config()

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

function EasyFluent:notify(notification: NotificationConfig): any
    notification.Title = notification.Title or 'Notification'
    notification.Content = notification.Content or 'Content'
    notification.Duration = notification.Duration or 5

    return Fluent:Notify(notification)
end

function EasyFluent:create_tab(window: any, tab: TabConfig): any
    local tab_connection: any = window:AddTab(tab)

    function tab_connection:create_paragraph(paragraph: ParagraphConfig): any
        local paragraph_title: string = paragraph.Title or 'Response'
        local paragraph_content: string = paragraph.Content or 'Content'

        local paragraph_connection: any = tab_connection:AddParagraph({
            Title = paragraph_title,
            Content = paragraph_content
        })

        function paragraph_connection:set(): ''
            paragraph_connection:SetTitle(paragraph_title)
            paragraph_connection:SetDesc(paragraph_content)
        end

        return paragraph_connection
    end

    function tab_connection:create_button(button: ButtonConfig): any
        button.Title = button.Title or 'Button'
        button.Description = button.Description or ''
        button.Callback = button.Callback or function() end

        return tab_connection:AddButton(button)
    end

    function tab_connection:create_dialog(dialog: DialogConfig): any
        dialog.Title = dialog.Title or ''
        dialog.Content = dialog.Content or ''
        dialog.Buttons = dialog.Buttons or {}

        return window:Dialog(dialog)
    end

    function tab_connection:create_toggle(connection: string, toggle: ToggleConfig): any
        toggle.Title = toggle.Title or 'Toggle'
        toggle.Description = toggle.Description or ''
        toggle.Flag = toggle.Flag or connection
        toggle.Default = caller[toggle.Flag] or Connections[toggle.Flag] or false

        local actual_callback: (boolean) -> () = toggle.Callback or function() end

        toggle.Callback = function(value: boolean): ''
            Connections[toggle.Flag] = value
            actual_callback(value)

            EasyFluent.save_config()
        end

        local toggle_connection: any = tab_connection:AddToggle(connection, toggle)

        function toggle_connection:set(bool: boolean): ''
            Fluent.Options[connection]:SetValue(bool)
            Connections[toggle.Flag] = bool

            EasyFluent.save_config()
        end

        return toggle_connection
    end

    function tab_connection:create_slider(connection: string, slider: SliderConfig): any
        local default_config: SliderConfig = {
            Title = 'Slider',
            Description = '',
            Min = 0,
            Max = 5,
            Default = 2,
            Rounding = 1,
            Callback = function(value: number) end
        }

        slider.Flag = slider.Flag or connection
        slider.Default = caller[slider.Flag] or Connections[slider.Flag] or default_config.Default

        Connections[slider.Flag] = slider.Default

        local actual_callback: (number) -> () = slider.Callback or default_config.Callback

        for index, value in pairs(default_config) do
            if slider[index] == nil then
                slider[index] = value
            end
        end

        slider.Callback = function(value: number): ''
            Connections[slider.Flag] = value
            actual_callback(value)

            EasyFluent.save_config()
        end

        local new_slider: any = tab_connection:AddSlider(connection, slider)

        task.defer(function()
            new_slider:SetValue(slider.Default)
        end)

        return new_slider
    end

    function tab_connection:create_dropdown(connection: string, dropdown: DropdownConfig): any
        local dropdown_default: DropdownConfig = {
            Title = 'Dropdown',
            Values = {},
            Multi = false,
            Default = nil,
            Callback = function(value: any) end
        }

        dropdown.Flag = dropdown.Flag or connection

        dropdown.Default = caller[dropdown.Flag] or Connections[dropdown.Flag] or dropdown.Default
        Connections[dropdown.Flag] = dropdown.Default

        for index, value in pairs(dropdown_default) do
            if dropdown[index] == nil then
                dropdown[index] = value
            end
        end

        local new_dropdown: any = tab_connection:AddDropdown(connection, dropdown)

        new_dropdown:OnChanged(function(value: any): ''
            Connections[dropdown.Flag] = value

            EasyFluent.save_config()
        end)

        task.defer(function()
            new_dropdown:SetValue(dropdown.Default)
        end)

        return new_dropdown
    end

    function tab_connection:create_keybind(connection: string, keybind: KeybindConfig): any
        local keybind_default: KeybindConfig = {
            Title = 'Title',
            Mode = 'Toggle',
            Default = 'LeftControl',
            Callback = function(value: boolean) end
        }

        keybind.Flag = keybind.Flag or connection
        keybind.Default = caller[keybind.Flag] or Connections[keybind.Flag] or keybind_default.Default

        local actual_callback: (string) -> () = keybind.Callback or keybind_default.Callback

        for index: string, value: any in pairs(keybind_default) do
            if not keybind[index] then
                keybind[index] = value
            end
        end

        keybind.Callback = function(value: string): ''
            Connections[keybind.Flag] = value
            actual_callback(value)

            EasyFluent.save_config()
        end

        return tab_connection:AddKeybind(connection, keybind)
    end

    function tab_connection:create_input(connection: string, input: InputConfig): any
        local input_default: InputConfig = {
            Title = 'Input',
            Default = '',
            Placeholder = 'Placeholder',
            Numeric = false,
            Finished = true,
            Callback = function(value: string) end
        }

        input.Flag = input.Flag or connection
        input.Default = caller[input.Flag] or Connections[input.Flag] or input_default.Default

        local actual_callback: (string) -> () = input.Callback or input_default.Callback

        for index: string, value: any in pairs(input_default) do
            if not input[index] then
                input[index] = value
            end
        end

        input.Callback = function(value: string): ''
            Connections[input.Flag] = value
            actual_callback(value)

            EasyFluent.save_config()
        end

        return tab_connection:AddInput(connection, input)
    end

    return tab_connection
end

return EasyFluent
