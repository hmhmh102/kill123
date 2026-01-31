-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ANTI DOUBLE LOAD
if getgenv().AutoKillLoaded then return end
getgenv().AutoKillLoaded = true

-- VARIABLES
local Character, Humanoid, Hand, Punch, Animator
local LastAttack, LastRespawn, LastCheck = 0, 0, 0
local Running = true
local StartTime = os.time()

local WhitelistFriends = true
local KillOnlyWeaker = true

-- SERVER HOP SETTINGS
local LastServerHop = 0
local ServerHopInterval = 60 -- seconds

getgenv().WhitelistedPlayers = getgenv().WhitelistedPlayers or {}
getgenv().TempWhitelistStronger = getgenv().TempWhitelistStronger or {}

-- SERVER HOP FUNCTION
local function ServerHop()
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    local Cursor = ""

    while true do
        local Url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if Cursor ~= "" then
            Url ..= "&cursor=" .. Cursor
        end

        local Success, Response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(Url))
        end)

        if Success and Response and Response.data then
            for _, Server in ipairs(Response.data) do
                if Server.playing < Server.maxPlayers and Server.id ~= JobId then
                    TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, LocalPlayer)
                    return
                end
            end
            Cursor = Response.nextPageCursor
            if not Cursor then break end
        else
            break
        end
        task.wait(0.4)
    end
end

-- BLOCKED ANIMS
local BlockedAnimations = {
    ["rbxassetid://3638729053"] = true,
    ["rbxassetid://3638749874"] = true,
    ["rbxassetid://3638767427"] = true,
    ["rbxassetid://102357151005774"] = true
}

-- UTILS
local function GetPlayerStatValue(Player, Names)
    if type(Names) == "string" then Names = {Names} end
    for _, n in ipairs(Names) do
        local v = Player:GetAttribute(n)
        if v then return tonumber(v) end
    end
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        for _, n in ipairs(Names) do
            local v = ls:FindFirstChild(n)
            if v then return tonumber(v.Value) end
        end
    end
end

local function GetLocalPlayerDamage()
    return GetPlayerStatValue(LocalPlayer, {"Damage","DMG","Attack","Strength","Str"}) or 1
end

local function GetTargetHealth(p)
    return p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.MaxHealth or 100
end

-- UPDATE CHARACTER
local function UpdateAll()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        Hand = Character:FindFirstChild("LeftHand") or Character:FindFirstChild("Left Arm")
        Punch = Character:FindFirstChild("Punch")
    end
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    if not Running then return end

    -- AUTO SERVER HOP
    local Now = os.clock()
    if Now - LastServerHop >= ServerHopInterval then
        LastServerHop = Now
        ServerHop()
        return
    end

    if Now - LastAttack < 0.05 then return end
    LastAttack = Now

    if not Character or not Humanoid then
        UpdateAll()
        return
    end

    if not Punch then
        local Tool = LocalPlayer.Backpack:FindFirstChild("Punch")
        if Tool then
            Humanoid:EquipTool(Tool)
            Punch = Character:FindFirstChild("Punch")
        else
            if Now - LastRespawn > 3 then
                Humanoid.Health = 0
                LastRespawn = Now
            end
            return
        end
    end

    Punch.attackTime.Value = 0
    Punch:Activate()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local head = p.Character:FindFirstChild("Head")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if h and head and root and h.Health > 0 then
                root.Anchored = true
                firetouchinterest(head, Hand, 0)
                firetouchinterest(head, Hand, 1)
                root.Anchored = false
            end
        end
    end
end)

-- ANTI AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)