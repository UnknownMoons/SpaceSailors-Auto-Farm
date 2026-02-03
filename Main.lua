if not game:IsLoaded() then game.Loaded:Wait() end
if game.GameId ~= 1722988797 then
    error("This script only works for Space Sailors.")
    return
end

local http = game:GetService("HttpService")
local FileName = "Save.JSON"

-- Função para carregar a lógica principal do Farm
local Init = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/UnknownMoons/SpaceSailors-Auto-Farm/refs/heads/main/Main.lua'))()
end

-- Gerenciamento de Dados JSON
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

-- Carregamento da Library
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/7yhx/kwargs_Ui_Library/main/source.lua"))()

local UI = Lib:Create{
   Theme = "Dark",
   Size = UDim2.new(0, 555, 0, 400)
}

-- [ CRIAÇÃO DO BOTÃO FLUTUANTE ]
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

-- Tornar o botão arrastável
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

-- Abrir/Fechar com o clique
OpenBtn.MouseButton1Click:Connect(function()
    UI:Toggle()
end)

-- [ CONTEÚDO DA GUI ]
local Main = UI:Tab{ Name = "Space Sailors" }
Main:Label{ Text = "Versão: 1.0.0 | Status: Active" }

local Divider = Main:Divider{ Name = "Auto Farm" }
local QuitDivider = Main:Divider{ Name = "Quit" }

Divider:Toggle{
    Name = "Auto Farm",
    Description = "Don't spam it - wait for the cycle to complete",
    State = AutoFarm,
    Callback = function(state)
        MainData.AutoFarm = state
        SaveData()
    end
}

-- Botão para fechar o script e destruir a UI
QuitDivider:Button{
   Name = "Close Script",
   Callback = function()
       ScreenGui:Destroy() -- Remove o botão flutuante
       UI:Quit{
           Message = "Close",
           Length = 1
       }
   end
}

-- Execução inicial se o AutoFarm estiver ligado
if AutoFarm then
    Init()
end
