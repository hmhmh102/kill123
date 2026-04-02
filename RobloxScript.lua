local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RivalsUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

--// COLORS
local bg = Color3.fromRGB(22,22,28)
local accent = Color3.fromRGB(120,50,180)
local text = Color3.fromRGB(210,210,220)

--// MAIN
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 320)
main.Position = UDim2.new(0.5, -150, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(14,14,18)

--// TABS BAR
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,0,0,30)
tabBar.BackgroundColor3 = Color3.fromRGB(10,10,14)

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal

--// CONTENT HOLDER
local pages = {}

local function createPage(name)
	local page = Instance.new("ScrollingFrame", main)
	page.Size = UDim2.new(1,0,1,-30)
	page.Position = UDim2.new(0,0,0,30)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.ScrollBarThickness = 4
	page.CanvasSize = UDim2.new(0,0,0,0)

	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0,6)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
	end)

	pages[name] = page
	return page
end

local function switchTab(name)
	for n, p in pairs(pages) do
		p.Visible = (n == name)
	end
end

local function createTab(name)
	local btn = Instance.new("TextButton", tabBar)
	btn.Size = UDim2.new(0,100,1,0)
	btn.Text = name
	btn.BackgroundColor3 = bg
	btn.TextColor3 = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11

	btn.MouseButton1Click:Connect(function()
		switchTab(name)
	end)
end

--// UI ELEMENTS

local function createToggle(parent, textLabel, callback)
	local state = false

	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1,-8,0,40)
	frame.BackgroundColor3 = bg

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1,-60,1,0)
	label.Position = UDim2.new(0,8,0,0)
	label.BackgroundTransparency = 1
	label.Text = textLabel
	label.TextColor3 = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0,50,0,22)
	btn.Position = UDim2.new(1,-55,0.5,-11)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,60)
	btn.Text = "OFF"

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = state and "ON" or "OFF"
		btn.BackgroundColor3 = state and accent or Color3.fromRGB(50,50,60)
		if callback then callback(state) end
	end)
end

-- 🔥 SLIDER
local function createSlider(parent, name, min, max, default, callback)
	local value = default

	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1,-8,0,50)
	frame.BackgroundColor3 = bg

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1,0,0,20)
	label.BackgroundTransparency = 1
	label.Text = name.." : "..value
	label.TextColor3 = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 11

	local bar = Instance.new("Frame", frame)
	bar.Size = UDim2.new(1,-20,0,6)
	bar.Position = UDim2.new(0,10,0,30)
	bar.BackgroundColor3 = Color3.fromRGB(40,40,50)

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = accent

	local dragging = false

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local pos = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
			pos = math.clamp(pos, 0, 1)

			fill.Size = UDim2.new(pos,0,1,0)
			value = math.floor(min + (max-min)*pos)

			label.Text = name.." : "..value
			if callback then callback(value) end
		end
	end)
end

local function createButton(parent, textLabel, callback)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1,-8,0,40)
	frame.BackgroundColor3 = bg

	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1,-10,1,-10)
	btn.Position = UDim2.new(0,5,0,5)
	btn.BackgroundColor3 = accent
	btn.Text = textLabel
	btn.TextColor3 = Color3.new(1,1,1)

	btn.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
end

--// CREATE TABS
createTab("Main")
createTab("Player")
createTab("Misc")

local mainPage = createPage("Main")
local playerPage = createPage("Player")
local miscPage = createPage("Misc")

switchTab("Main")

--// ADD STUFF

-- MAIN TAB
createToggle(mainPage, "Enable Void", function(v)
	print("Void:", v)
end)

createSlider(mainPage, "Orbit Speed", 1, 100, 25, function(v)
	print("Speed:", v)
end)

-- PLAYER TAB
createSlider(playerPage, "WalkSpeed", 16, 100, 16, function(v)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = v
	end
end)

createSlider(playerPage, "JumpPower", 50, 150, 50, function(v)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.JumpPower = v
	end
end)

-- MISC TAB
createButton(miscPage, "Print Hello", function()
	print("Hello clicked")
end)