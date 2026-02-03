if not game:IsLoaded() then game.Loaded:Wait() end
if game.GameId ~= 1722988797 then
    warn("Not Space Sailors")
    return
end

local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

local FileName = "Save.JSON"

local DefaultData = {
    AutoFarm = false,
    CameFromPlanet = false
}

-- Create / Read JSON
if not isfile(FileName) then
    writefile(FileName, HttpService:JSONEncode(DefaultData))
end

local function ReadData()
    return HttpService:JSONDecode(readfile(FileName))
end

local function SaveData(tbl)
    writefile(FileName, HttpService:JSONEncode(tbl))
end

-- UI kwargs
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/7yhx/kwargs_Ui_Library/main/source.lua"))()

local UI = Lib:Create{
    Theme = "Dark",
    Size = UDim2.new(0, 555, 0, 400)
}

-- Floating Button 🚀
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "🚀"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.TextSize = 25
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- Drag
local dragging, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = OpenBtn.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

OpenBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

OpenBtn.MouseButton1Click:Connect(function()
    UI:Toggle()
end)

-- UI Content
local Main = UI:Tab{ Name = "Space Sailors" }

local Info = Main:Divider{ Name = "Info | Version: 1.0.0 | Status: Active" }
local Farm = Main:Divider{ Name = "Auto Farm" }
local Actions = Main:Divider{ Name = "Actions" }

Farm:Toggle{
    Name = "Enable Auto Farm",
    Description = "Saves to JSON and starts the script",
    State = ReadData().AutoFarm,
    Callback = function(state)
        local data = ReadData()
        data.AutoFarm = state
        SaveData(data)

        if state then
            task.spawn(function()
                loadstring(game:HttpGet(
                    "https://raw.githubusercontent.com/UnknownMoons/SpaceSailors-Auto-Farm/refs/heads/main/AutoFarm-v1.0.0"
                ))()
            end)
        else
            warn("AutoFarm disabled")
        end
    end
}

Actions:Button{
    Name = "Close UI",
    Callback = function()
        UI:Toggle()
    end
}

-- Auto start if enabled in JSON
if ReadData().AutoFarm then
    task.spawn(function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/UnknownMoons/SpaceSailors-Auto-Farm/refs/heads/main/AutoFarm-v1.0.0"
        ))()
    end)
end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "🚀"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.TextSize = 25
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- Drag
local dragging, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = OpenBtn.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

OpenBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

OpenBtn.MouseButton1Click:Connect(function()
    UI:Toggle()
end)

-- Conteúdo
local Main = UI:Tab{ Name = "Space Sailors" }

local Info = Main:Divider{ Name = "Info | v1.0.0 | Status: Active" }

local Farm = Main:Divider{ Name = "Auto Farm" }

Farm:Toggle{
    Name = "Ativar Auto Farm",
    Description = "Não spammar – espera o ciclo terminar",
    State = MainData.AutoFarm,
    Callback = function(state)
        MainData.AutoFarm = state
        SaveData()
        if state then
            task.spawn(Init)
        end
    end
}

local Quit = Main:Divider{ Name = "Configurações" }

Quit:Button{
    Name = "Fechar Script",
    Callback = function()
        ScreenGui:Destroy()
        UI:Quit{ Message = "Encerrado", Length = 1 }
    end
}

if MainData.AutoFarm then
    task.spawn(Init)
end

