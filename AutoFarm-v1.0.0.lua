local TeleportService = game:GetService("TeleportService")
local http = game:GetService("HttpService")

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
local Char = plr.Character or plr.CharacterAdded:Wait()
local hum = Char:WaitForChild("Humanoid")

local DefaultData = {
    AutoFarm = true,
    CameFromPlanet = false
}
local MainData
local AutoFarm
local CameFromPlanet

if game.GameId ~= 1722988797 then
    print("this isnt space sailors")
    return
end

if not isfile(FileName) then
    writefile(FileName, http:JSONEncode(DefaultData))
    MainData = http:JSONDecode(readfile(FileName))
else
    MainData = http:JSONDecode(readfile(FileName))
    AutoFarm = MainData.AutoFarm
    CameFromPlanet = MainData.CameFromPlanet
end

function SaveData()
    if isfile(FileName) then delfile(FileName) end
    writefile(FileName, http:JSONEncode(MainData))
    MainData = http:JSONDecode(readfile(FileName))
end

if not game:IsLoaded() then game.Loaded:Wait() end
if AutoFarm == false then
    print("wont autofarm")
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

local function Get_Names() return Planets[game.PlaceId] or false end

local function GetSpecialLanderName()
    for id, name in pairs(SpecialLanders) do
        if game.PlaceId == id then return name end
    end
end

local Cashout = game:GetService("ReplicatedStorage"):FindFirstChild("Cashout")
if Cashout then 
    Cashout:FireServer()
    SendNotif('Cashout Success', 'Cashed out', 3) 
end

local function GetSpecialLanderByRemote(RemoteName)
    for _, Name in pairs(SpecialLanders) do
        if Name[2] == RemoteName then return Name end
    end
end

local function IsInOrbiter()
    local OrbiterIds = { 5534753074 }
    for _, id in pairs(OrbiterIds) do if game.PlaceId == id then return true end end
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

task.wait(3)

if not Get_Names() then
    if IsInOrbiter() == false and IsInGateway() == true then
        local t = {}
        for _, Table in pairs(SpecialLanders) do table.insert(t, Table[2]) end
        local RemoteName = t[math.random(1, #t)]
        local CustomLander = GetSpecialLanderByRemote(tostring(RemoteName))[1]
        game.ReplicatedStorage[RemoteName]:FireServer(CustomLander)
    else
        local spec = GetSpecialLanderName()
        if spec then game.ReplicatedStorage[spec[2]]:FireServer(spec[1]) end
    end
    return
end 

local function IsMultipleLanderOption() return typeof(Get_Names()[1]) == "table" end

local function GetLander()
    if _G.lander and _G.PlanetInstanceNames then return _G.lander end
    for _, l in pairs(GetChildrenOfClass(workspace, "Model")) do
        if IsMultipleLanderOption() then 
            for _, LanderOption in pairs(Get_Names()) do
                if l.Name == LanderOption[4] and l:FindFirstChild("LanderOwner") and l.LanderOwner.Value == plr.Name then
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
        if v.Name:sub(1, 7) == "Pick Up" then return v end 
    end
end

local function GetNames() return _G.PlanetInstanceNames end
local function GetPrompt() 
    local ldr = GetLander()
    local names = _G.PlanetInstanceNames
    if ldr and names then
        local target = ldr:FindFirstChild(names[1]) -- Evita erro de index nil
        if target and target:FindFirstChild("Deposit") then
            return target.Deposit.ProximityPrompt
        end
    end
end

-- NOVA FUNÇÃO DE TELEPORTE (5 STUDS + LOOK AT)
local function QuickTpToPrompt(prompt)
    if not prompt or not prompt.Parent then return end
    
    local targetPos = prompt.Parent.Position
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    
    if not root then return end
    
    -- Se for a LLAMA, garante que não estás sentado
    if GetLander().Name == "LLAMA" then 
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.Sit = false end 
    end
    local offsetPos = targetPos + Vector3.new(0, 0, 0) 
    root.CFrame = CFrame.new(offsetPos, targetPos)
    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
    plr.CameraMode = Enum.CameraMode.LockFirstPerson
end

function CollectSamples()
    local Prompt = GetPrompt()
    local Tool = GetTool()
    if not Tool then return end
    local PickUp = Tool.PickUp
    local AmountStored = Prompt.Parent.Parent.Parent.ResourceValues.Storage
    local Capacity = AmountStored.Parent.Capacity
    
    repeat
        QuickTpToPrompt(Prompt)
        PickUp:FireServer()
        local start = tick()
        while task.wait() do if Collected or (tick() - start > 2) then break end end
        task.wait(0.1)
        Collected = false
    until AmountStored.Value >= Capacity.Value 
    
    MainData.CameFromPlanet = true
    SaveData()
    game:GetService("ReplicatedStorage")[GetNames()[5]]:FireServer(plr.Name)
end

local Warp = game.ReplicatedStorage:FindFirstChild("WarpLandRemote", true)
if Warp then Warp:FireServer(plr.Name) end

SendNotif('Waiting to land', 'autofarm will begin when you land', 5)

local ldr = GetLander()
if ldr and ldr:FindFirstChild("Landed") then
    if not ldr.Landed.Value then ldr.Landed:GetPropertyChangedSignal("Value"):Wait() end
end

SendNotif('Autofarming', 'Iniciado!', 5)
task.wait(1)

local function RockAdded()
    local names = GetNames()
    if not names then return end
    local Rock = plr.Backpack:FindFirstChild(names[2] .. names[3])
    if not Rock then return end
    
    hum:EquipTool(Rock)
    task.wait(0.2)
    fireproximityprompt(GetPrompt())
    Collected = true 
end

table.insert(_G.Connections, plr.Backpack.ChildAdded:Connect(RockAdded))
CollectSamples()

