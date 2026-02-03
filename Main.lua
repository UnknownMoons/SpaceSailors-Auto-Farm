if not game:IsLoaded() then game.Loaded:Wait() end
if game.GameId ~= 1722988797 then
    error("this isnt space sailors code wont run")
    return
end

local http = game:GetService("HttpService")
local FileName = "Save.JSON"

local Init = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/UnknownMoons/SpaceSailors-Auto-Farm/refs/heads/main/AutoFarm-v1.0.0.lua'))()
end

if not isfile(FileName) then
    local DefaultData = {AutoFarm = false, CameFromPlanet = false}
    writefile(FileName, http:JSONEncode(DefaultData))
end

local MainData = http:JSONDecode(readfile(FileName))
local AutoFarm = MainData.AutoFarm

function SaveData()
    writefile(FileName, http:JSONEncode(MainData))
    MainData = http:JSONDecode(readfile(FileName))
    Init()
end

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/7yhx/kwargs_Ui_Library/main/source.lua"))()

local UI = Lib:Create{
   Theme = "Dark",
   Size = UDim2.new(0, 555, 0, 400)
}

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "🚀"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.TextSize = 25
local corner = Instance.new("UICorner", OpenBtn)
corner.CornerRadius = UDim.new(0, 12)

local dragging, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = OpenBtn.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
OpenBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

OpenBtn.MouseButton1Click:Connect(function()
    UI:Toggle()
end)

-- [ CONTEÚDO CORRIGIDO ]
local Main = UI:Tab{ Name = "Space Sailors" }

-- Na kwargs, você usa o nome do Divider para passar informações ou usa Section DENTRO do divider
local InfoDivider = Main:Divider{ Name = "Info: v1.0.0 | Status: Active" }

local FarmDivider = Main:Divider{ Name = "Auto Farm" }

FarmDivider:Toggle{
    Name = "Ativar Farm",
    Description = "Aguarde o ciclo completar",
    State = AutoFarm,
    Callback = function(state)
        MainData.AutoFarm = state
        SaveData()
    end
}

local QuitDivider = Main:Divider{ Name = "Configurações" }

QuitDivider:Button{
   Name = "Fechar Script",
   Callback = function()
       ScreenGui:Destroy()
       UI:Quit{
           Message = "Encerrando...",
           Length = 1
       }
   end
}

if AutoFarm then
    task.spawn(Init)
end
