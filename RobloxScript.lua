
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer


if getgenv().AutoKillLoaded then return end
getgenv().AutoKillLoaded = true


local Character, Humanoid, Hand, Punch
local LastAttack, LastRespawn = 0, 0
local Running = true
local StartTime = os.time()


local ServerHopInterval = 60 
getgenv().LastServerHop = getgenv().LastServerHop or tick()

local function ServerHop()
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    local Cursor = ""

    while true do
        local Url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if Cursor ~= "" then
            Url = Url .. "&cursor=" .. Cursor
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
        task.wait(0.5)
    end
end

local function UpdateAll()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        Hand = Character:FindFirstChild("LeftHand") or Character:FindFirstChild("Left Arm")
        Punch = Character:FindFirstChild("Punch")
    end
end

UpdateAll()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    UpdateAll()
end)

RunService.RenderStepped:Connect(function()
    if not Running then return end

    local Now = tick()
    if Now - getgenv().LastServerHop >= ServerHopInterval then
        getgenv().LastServerHop = Now
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

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
