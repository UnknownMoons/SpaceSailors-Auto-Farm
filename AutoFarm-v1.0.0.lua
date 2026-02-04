local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- ===== Utils =====
local function SendNotif(title, text, delay)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = delay
        })
    end)
end

local function IsInGateway()
    return game.PlaceId == 5515926734
end

local function TpToGateway()
    TeleportService:Teleport(5515926734)
end

local function GetChildrenOfClass(parent, className)
    local t = {}
    for _, v in ipairs(parent:GetChildren()) do
        if v:IsA(className) then
            table.insert(t, v)
        end
    end
    return t
end

-- ===== Player / Character (anti-respawn crash) =====
local plr = Players.LocalPlayer
local Char = plr.Character or plr.CharacterAdded:Wait()
local hum = Char:WaitForChild("Humanoid")

plr.CharacterAdded:Connect(function(c)
    Char = c
    hum = c:WaitForChild("Humanoid")
end)

-- ===== Connections cleanup =====
_G.Connections = _G.Connections or {}
for _, c in pairs(_G.Connections) do
    if typeof(c) == "RBXScriptConnection" then
        c:Disconnect()
    end
end
_G.Connections = {}

-- ===== Save System =====
local FileName = "Save.JSON"

local DefaultData = {
    AutoFarm = false,
    CameFromPlanet = false
}

local MainData = DefaultData

if game.GameId ~= 1722988797 then
    warn("Not Space Sailors")
    return
end

if not isfile(FileName) then
    writefile(FileName, HttpService:JSONEncode(DefaultData))
end

local function LoadData()
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(FileName))
    end)
    if success and typeof(decoded) == "table" then
        MainData = decoded
    else
        MainData = DefaultData
        writefile(FileName, HttpService:JSONEncode(DefaultData))
    end
end

local function SaveData()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(MainData)
    end)
    if success then
        writefile(FileName, encoded)
    end
end

LoadData()

local AutoFarm = MainData.AutoFarm or false
local CameFromPlanet = MainData.CameFromPlanet or false

if not game:IsLoaded() then game.Loaded:Wait() end

-- ===== Planets =====
local Planets = {
    [5534753074] = {
        {"LanderAscentStage", "Lunar", " Sample", "Lander2", "GatewayRemote"},
        {"LLAMA", "Lunar", " Sample", "LLAMA", "GatewayRemote"},
        {"AftCargoHold", "Lunar", " Sample", "LLAMA", "GatewayRemote"},
    }
}

local SpecialLanders = {
    [5515926734] = {"LLAMA", "ToMoonRemote"}
}

local function Get_Names()
    return Planets[game.PlaceId]
end

local function GetSpecialLanderName()
    return SpecialLanders[game.PlaceId]
end

local function IsInOrbiter()
    return game.PlaceId == 5534753074
end

-- ===== Early exits =====
local Cashout = ReplicatedStorage:FindFirstChild("Cashout")
if Cashout then
    Cashout:FireServer()
    SendNotif("Cashout", "Cashed out", 3)
end

if not AutoFarm then
    print("AutoFarm disabled")
    return
end

if game.PlaceId == 5000143962 then
    MainData.CameFromPlanet = false
    SaveData()
    TpToGateway()
    return
end

if IsInOrbiter() and CameFromPlanet then
    MainData.CameFromPlanet = false
    SaveData()
    TpToGateway()
    return
else
    MainData.CameFromPlanet = false
    SaveData()
end

-- ===== Lander detection (anti-nil) =====
local function GetLander()
    if _G.lander then return _G.lander end

    repeat task.wait() until workspace:FindFirstChildWhichIsA("Model")

    for _, l in ipairs(workspace:GetChildren()) do
        if l:IsA("Model") and l:FindFirstChild("LanderOwner") then
            if l.LanderOwner.Value == plr.Name then
                _G.lander = l
                return l
            end
        end
    end
end

-- ===== Tool =====
local function GetTool()
    for _, v in ipairs(plr.Backpack:GetChildren()) do
        if v.Name:sub(1, 7) == "Pick Up" then
            return v
        end
    end
end

-- ===== Warp =====
local Warp
for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
    if v.Name == "WarpLandRemote" then
        Warp = v
        break
    end
end

if Warp then
    Warp:FireServer(plr.Name)
end

SendNotif("Waiting to land", "Autofarm will start when you land", 5)

-- ===== Autofarm core =====
local Collected = false

local function CollectSamples(prompt)
    local Tool = GetTool()
    if not Tool then return end

    hum:EquipTool(Tool)

    repeat
        fireproximityprompt(prompt)
        task.wait(0.5)
    until Collected

    MainData.CameFromPlanet = true
    SaveData()
end

local function AutoFarmFunc(prompt)
    Collected = true
    fireproximityprompt(prompt)
end

-- Hook
table.insert(_G.Connections, plr.Backpack.ChildAdded:Connect(function()
    Collected = true
end))

-- ===== Wait for lander =====
local lander = GetLander()
local landed = lander:WaitForChild("Landed")
if not landed.Value then
    landed:GetPropertyChangedSignal("Value"):Wait()
end

SendNotif("Autofarming", "Started autofarm", 5)

-- Aqui assumes que já tens o prompt certo
local prompt
repeat
    for _, d in ipairs(lander:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            prompt = d
            break
        end
    end
    task.wait()
until prompt

CollectSamples(prompt)
