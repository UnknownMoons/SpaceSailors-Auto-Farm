local TeleportService = game:GetService("TeleportService")

function SendNotif(title, text, delay)
    game.StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = delay})
end

function IsInGateway()
    return game.PlaceId == 5515926734
end

function TpToGateway()
    TeleportService:Teleport(5515926734)
end

local function GetChildrenOfClass(parent, ClassName)
    local childrenOfClass = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA(ClassName) then
            table.insert(childrenOfClass, child)
        end
    end
    return childrenOfClass
end

_G.Connections = _G.Connections or {}
for _, Connection in pairs(_G.Connections) do 
    Connection:Disconnect()
end 
_G.Connections = {}

local Collected = false
local FileName = "Save.JSON"
local plr = game.Players.LocalPlayer
local Char = plr.Character
local hum = Char:WaitForChild("Humanoid")

local DefaultData = {
    AutoFarm = false,
    CameFromPlanet = false
}
local MainData
local AutoFarm
local CameFromPlanet
local http = game:GetService("HttpService")

if game.GameId ~= 1722988797 then
    print("this isnt space sailors")
    return
end

if not isfile(FileName) then
    local data = http:JSONEncode(DefaultData)
    writefile(FileName, data)
    MainData = http:JSONDecode(readfile(FileName))
else
    MainData = http:JSONDecode(readfile(FileName))
    AutoFarm = MainData.AutoFarm
    CameFromPlanet = MainData.CameFromPlanet
end

function SaveData()
    local data = http:JSONEncode(MainData)
    delfile(FileName)
    writefile(FileName, data)
    MainData = http:JSONDecode(readfile(FileName))
end



if not game:IsLoaded() then game.Loaded:Wait() end
if AutoFarm==false then
    print("AutoFarm Disabled")
    return false
end
if game.PlaceId == 5000143962 then 
    MainData.CameFromPlanet = false
    SaveData()
    TpToGateway()
    return
end
local Planets = {
    [5534753074] = {
        {"LanderAscentStage", "Lunar", " Sample", "Lander2", "GatewayRemote"},
        {"LLAMA", "Lunar", " Sample", "LLAMA", "GatewayRemote"}
    }
}

local SpecialLanders = {
    [5515926734] = {"LLAMA", "ToMoonRemote"}
}

local function Get_Names()
    return Planets[game.PlaceId] or false
end

local function GetSpecialLanderName()
    for id, name in pairs(SpecialLanders) do
        if game.PlaceId == id then
            return name
        end
    end
end

local function SpecialLanderOwnership()
    for _, val in pairs(GetChildrenOfClass(Char, "BoolValue")) do
        if string.find(val.Name, "Access") then 
            return val.Value
        end
    end
    return false
end

local Cashout = game:GetService("ReplicatedStorage"):FindFirstChild("Cashout")
if Cashout then 
    Cashout:FireServer()
    SendNotif('Cashout Success', 'Cashed out, 3) 
end

local function GetSpecialLanderByRemote(RemoteName)
    for _, Name in pairs(SpecialLanders) do
        if Name[2] == RemoteName then
            return Name
        end
    end
end

local function IsInOrbiter()
    local OrbiterIds = {
        5534753074 
    }
    for _, id in pairs(OrbiterIds) do
        if game.PlaceId == id then
            return true
        end
    end
    return false
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
wait(3)
if not Get_Names() then
    if IsInOrbiter() == false and IsInGateway() == true then
        local t = {}
        for _, Table in pairs(SpecialLanders) do
           table.insert(t, Table[2])
        end
        local RemoteName = t[math.random(1, #t)]
        local CustomLander = GetSpecialLanderByRemote(tostring(RemoteName))[1]
        game.ReplicatedStorage[RemoteName]:FireServer(CustomLander)
    else
        game.ReplicatedStorage[GetSpecialLanderName()[2]]:FireServer(GetSpecialLanderName()[1])
    end
    return
end 

local function IsMultipleLanderOption()
    return typeof(Get_Names()[1]) == "table"
end

local function GetLander()
    if _G.lander and _G.PlanetInstanceNames then 
        return _G.lander 
    end

    for _, l in pairs(GetChildrenOfClass(workspace, "Model")) do
        if IsMultipleLanderOption() then 
            for _, LanderOption in pairs(Get_Names()) do
                if l.Name == LanderOption[4] and l:FindFirstChild("LanderOwner").Value == plr.Name then
                    _G.lander = l 
                    _G.PlanetInstanceNames = LanderOption
                    return _G.lander
                end
            end
        end
    end
end

local function GetTool()
    for _, v in pairs(plr.Backpack:GetChildren()) do
        if v.Name:sub(1, 7) == "Pick Up" then
            return v
        end 
    end
end

local function GetNames() 
    return _G.PlanetInstanceNames
end

local function GetPrompt() 
    return GetLander()[GetNames()[1]].Deposit.ProximityPrompt 
end

function CollectSamples()
    local Prompt = GetPrompt()
    local Tool = GetTool()
    local PickUp = Tool.PickUp
    local AmountStored = Prompt.Parent.Parent.Parent.ResourceValues.Storage
    local Capacity = AmountStored.Parent.Capacity
    
    repeat
        if GetLander().Name == "LLAMA" then
            hum.Sit = false
        end
        PickUp:FireServer()
        while task.wait() do
            if Collected then break end
        end
        task.wait()
        Collected = false
    until AmountStored.Value >= Capacity.Value 
    
    MainData.CameFromPlanet = true
    SaveData()
    game:GetService("ReplicatedStorage")[GetNames()[5]]:FireServer(plr.Name)
end

local Warp
for _, v in pairs(game.ReplicatedStorage:GetDescendants()) do
    if v.Name == "WarpLandRemote" then
        Warp = v.Parent:FindFirstChild(v.Name)
        break
    end
end

if Warp then
    Warp:FireServer(plr.Name)
end

SendNotif('Waiting to land', 'autofarm will begin when you land', 5)

local function QuickTpToPrompt(prompt)
    if GetLander().Name == "LLAMA" then
        hum.Sit = false
        task.wait()
        Char.HumanoidRootPart.CFrame = prompt.Parent.CFrame
    end
end

local landed = GetLander().Landed
if not landed.Value then 
    landed:GetPropertyChangedSignal("Value"):Wait()
end

SendNotif('Autofarming', 'started to autofarm', 5)
wait(1)


QuickTpToPrompt(GetPrompt())
local function RockAdded()
    local Rock = plr.Backpack:FindFirstChild(GetNames()[2] .. GetNames()[3])
    if not Rock then return end
    hum:EquipTool(Rock)
    fireproximityprompt(GetPrompt())
    Collected = true 
end

table.insert(_G.Connections, plr.Backpack.ChildAdded:Connect(RockAdded))
CollectSamples()
