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
local Char = plr.Character or plr.CharacterAdded:Wait()
local hum = Char:WaitForChild("Humanoid")
local root = Char:WaitForChild("HumanoidRootPart")

-- CONFIGURAÇÃO DE CÂMERA (PRIMEIRA PESSOA)
local function SetFirstPerson(enabled)
    if enabled then
        plr.CameraMode = Enum.CameraMode.LockFirstPerson
    else
        plr.CameraMode = Enum.CameraMode.Classic
    end
end

local DefaultData = {
    AutoFarm = false,
    CameFromPlanet = false
}
local MainData
local http = game:GetService("HttpService")

if not isfile(FileName) then
    writefile(FileName, http:JSONEncode(DefaultData))
end
MainData = http:JSONDecode(readfile(FileName))

function SaveData()
    writefile(FileName, http:JSONEncode(MainData))
end

if not game:IsLoaded() then game.Loaded:Wait() end
if MainData.AutoFarm == false then return end

local Planets = {
    [5534753074] = {
        {"LanderAscentStage", "Lunar", " Sample", "Lander2", "GatewayRemote"},
        {"LLAMA", "Lunar", " Sample", "LLAMA", "GatewayRemote"}
    }
}

local function Get_Names() return Planets[game.PlaceId] or false end

local function GetLander()
    for _, l in pairs(workspace:GetChildren()) do
        if l:IsA("Model") and l:FindFirstChild("LanderOwner") and l.LanderOwner.Value == plr.Name then
            for _, opt in pairs(Get_Names()) do
                if l.Name == opt[4] then
                    _G.PlanetInstanceNames = opt
                    return l
                end
            end
        end
    end
end

local function GetNames() return _G.PlanetInstanceNames end
local function GetPrompt() 
    local lander = GetLander()
    return lander and lander[GetNames()[1]].Deposit.ProximityPrompt 
end

-- TELEPORTE E OLHAR PARA O DEPÓSITO
local function TpAndLookAtDeposit()
    local prompt = GetPrompt()
    if prompt and root then
        hum.Sit = false
        task.wait(0.2)
        -- Posiciona o jogador na frente do depósito e faz ele olhar para o prompt
        local targetPos = prompt.Parent.Position
        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 4), targetPos) 
        -- O CFrame acima coloca você a 4 studs de distância e 2 de altura, olhando para o alvo
    end
end

function CollectSamples()
    local Prompt = GetPrompt()
    if not Prompt then return end
    
    local Tool
    repeat 
        for _, v in pairs(plr.Backpack:GetChildren()) do
            if v.Name:sub(1, 7) == "Pick Up" then Tool = v break end
        end
        task.wait(0.5)
    until Tool
    
    local PickUp = Tool.PickUp
    local AmountStored = Prompt.Parent.Parent.Parent.ResourceValues.Storage
    local Capacity = AmountStored.Parent.Capacity
    
    SetFirstPerson(true)
    TpAndLookAtDeposit()

    repeat
        PickUp:FireServer()
        while task.wait() do if Collected then break end end
        task.wait(0.1)
        Collected = false
        -- Garante que continua olhando se algo empurrar o player
        TpAndLookAtDeposit() 
    until AmountStored.Value >= Capacity.Value 
    
    SetFirstPerson(false)
    MainData.CameFromPlanet = true
    SaveData()
    game:GetService("ReplicatedStorage")[GetNames()[5]]:FireServer(plr.Name)
end

-- Início do Script
if game.PlaceId == 5534753074 then -- Se estiver em um planeta (Ex: Lua)
    local lander = GetLander()
    if lander then
        if not lander.Landed.Value then 
            SendNotif("Aguardando", "Aguardando pouso para iniciar...", 5)
            lander.Landed:GetPropertyChangedSignal("Value"):Wait() 
        end
        
        SendNotif("Farm Iniciado", "Teleportando e focando no depósito", 5)
        
        table.insert(_G.Connections, plr.Backpack.ChildAdded:Connect(function(item)
            if item.Name:find("Sample") then
                hum:EquipTool(item)
                task.wait(0.1)
                fireproximityprompt(GetPrompt())
                Collected = true
            end
        end))
        
        CollectSamples()
    end
end
