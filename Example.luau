local EasyFluent = loadstring(game:HttpGet('https://raw.githubusercontent.com/deufyn/EasyFluent/refs/heads/main/src/EasyFluent.luau'))()
-- local Flag = EasyFluent.Connections

local Window = EasyFluent:create_window({
    Title = 'EasyFluent',
    SubTitle = '',
    TabWidth = 95,
    Size = UDim2.fromOffset(440, 315),
    Acrylic = false,
    Theme = 'Dark',
    MinimizeKey = Enum.KeyCode.Insert
})

-- Icons: https://lucide.dev/icons/
local Main = EasyFluent:create_tab(Window, { Title = 'Main', Icon = '' })

do
    local Toggle = Main:create_toggle('', {
        Title = 'Toggle',
        Description = '',
        -- Default = ''
        Flag = 'toggle',
        Callback = function(value)
            print(`toggle value: {value}`)
        end
    })

    Main:create_button({
        Title = 'Button',
        Description = '',
        Callback = function()
            print('clicked')
        end
    })

    local Dropdown = Main:create_dropdown('', {
        Title = 'Dropdown',
        Values = {
            'One',
            'Two',
            'Three'
        },
        -- Default = 1,
        Flag = 'dropdown',
        Callback = function(value)
            print(`dropdown value: {value}`)
        end
    })

    local Slider = Main:create_slider('', {
        Title = 'Slider',
        Min = 1,
        Max = 100,
        Default = 50,
        Rounding = 1,
        Flag = 'slider',
        Callback = function(value)
            print(`dropdown value: {value}`)
        end
    })

    local Keybind = Main:create_keybind('', {
        Title = 'Keybind',
        Mode = 'Toggle', -- Hold
        Default = 'E',
        Callback = function(value)
            print(`keybind value: {value}`)
        end
    })

    local Input = Main:create_input('', {
        Title = 'Input',
        Default = '',
        Placeholder = '...',
        Numeric = false,
        Finished = true,
        Callback = function(value)
            print(`input value: {value}`)
        end
    })
end

Window:SelectTab(1)

EasyFluent:notify({
    Title = `Welcome to EasyFluent {game.Players.LocalPlayer.DisplayName}.`,
    Content = 'Fluent UI Library with new features!',
    Duration = 7
})
