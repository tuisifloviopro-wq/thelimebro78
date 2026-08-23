-- Steal an Egg - Optimized Elite Hub with Floating Menu Toggle Button
-- High performance, zero lag, manual key entry, and a UI toggle button

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Prevent duplicate UI instances to avoid memory leaks and crashes
if CoreGui:FindFirstChild("AxiomStealAnEggUI") then
    CoreGui.AxiomStealAnEggUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxiomStealAnEggUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Constants & State
local CORRECT_KEY = "ADMINNICETEST"
local KEY_DURATION = 3600 -- 1 hour in seconds
local keyExpiryTime = 0
local isKeyAuthenticated = false

--------------------------------------------------------------------------------
-- KEY SYSTEM WINDOW
--------------------------------------------------------------------------------
local KeyWindow = Instance.new("Frame")
KeyWindow.Name = "KeyWindow"
KeyWindow.Size = UDim2.new(0, 420, 0, 240)
KeyWindow.Position = UDim2.new(0.5, -210, 0.5, -120)
KeyWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
KeyWindow.BorderSizePixel = 0
KeyWindow.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 10)
KeyCorner.Parent = KeyWindow

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Text = "MANUAL KEY AUTHENTICATION"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 16
KeyTitle.Parent = KeyWindow

local KeyInputBox = Instance.new("TextBox")
KeyInputBox.Size = UDim2.new(0.85, 0, 0, 45)
KeyInputBox.Position = UDim2.new(0.075, 0, 0.35, 0)
KeyInputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
KeyInputBox.BorderSizePixel = 0
KeyInputBox.Font = Enum.Font.Gotham
KeyInputBox.PlaceholderText = "Type key here manually..."
KeyInputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
KeyInputBox.Text = ""
KeyInputBox.ClearTextOnFocus = false
KeyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInputBox.TextSize = 14
KeyInputBox.Parent = KeyWindow

local KeyInputCorner = Instance.new("UICorner")
KeyInputCorner.CornerRadius = UDim.new(0, 8)
KeyInputCorner.Parent = KeyInputBox

local VerifyButton = Instance.new("TextButton")
VerifyButton.Size = UDim2.new(0.85, 0, 0, 45)
VerifyButton.Position = UDim2.new(0.075, 0, 0.62, 0)
VerifyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
VerifyButton.BorderSizePixel = 0
VerifyButton.Font = Enum.Font.GothamBold
VerifyButton.Text = "VERIFY KEY"
VerifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyButton.TextSize = 14
VerifyButton.Parent = KeyWindow

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 8)
VerifyCorner.Parent = VerifyButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0.85, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Text = "Status: Enter key manually"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12
StatusLabel.Parent = KeyWindow

--------------------------------------------------------------------------------
-- FLOATING TOGGLE MENU BUTTON (Nút Bật/Tắt Menu trên màn hình)
--------------------------------------------------------------------------------
local ToggleMenuButton = Instance.new("TextButton")
ToggleMenuButton.Name = "ToggleMenuButton"
ToggleMenuButton.Size = UDim2.new(0, 110, 0, 40)
ToggleMenuButton.Position = UDim2.new(0, 20, 0.5, -20)
ToggleMenuButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleMenuButton.BorderSizePixel = 0
ToggleMenuButton.Font = Enum.Font.GothamBold
ToggleMenuButton.Text = "MENU [ON]"
ToggleMenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuButton.TextSize = 13
ToggleMenuButton.Visible = false -- Chỉ hiện khi đã nhập key xong
ToggleMenuButton.Parent = ScreenGui

local ToggleMenuCorner = Instance.new("UICorner")
ToggleMenuCorner.CornerRadius = UDim.new(0, 8)
ToggleMenuCorner.Parent = ToggleMenuButton

--------------------------------------------------------------------------------
-- MAIN SCRIPT WINDOW
--------------------------------------------------------------------------------
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 500, 0, 350)
MainWindow.Position = UDim2.new(0.5, -250, 0.5, -175)
MainWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false
MainWindow.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainWindow

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(0, 260, 0, 40)
MainTitle.Position = UDim2.new(0.05, 0, 0.03, 0)
MainTitle.BackgroundTransparency = 1
MainTitle.Font = Enum.Font.GothamBold
MainTitle.Text = "Steal an Egg - Optimized Hub"
MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTitle.TextSize = 15
MainTitle.TextXAlignment = Enum.TextXAlignment.Left
MainTitle.Parent = MainWindow

local TimeKeyLabel = Instance.new("TextLabel")
TimeKeyLabel.Size = UDim2.new(0, 200, 0, 40)
TimeKeyLabel.Position = UDim2.new(0.52, 0, 0.03, 0)
TimeKeyLabel.BackgroundTransparency = 1
TimeKeyLabel.Font = Enum.Font.GothamMedium
TimeKeyLabel.Text = "EXP: --:--"
TimeKeyLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
TimeKeyLabel.TextSize = 13
TimeKeyLabel.TextXAlignment = Enum.TextXAlignment.Right
TimeKeyLabel.Parent = MainWindow

-- Toggle Button Generator Function for features
local function createToggle(name, yPos, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
    ToggleBtn.Position = UDim2.new(0.05, 0, yPos, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = name .. " [OFF]"
    ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleBtn.TextSize = 14
    ToggleBtn.Parent = MainWindow

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ToggleBtn

    local active = false
    ToggleBtn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.Text = name .. " [ON]"
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            ToggleBtn.Text = name .. " [OFF]"
        end
        
        local success, err = pcall(function()
            callback(active)
        end)
        if not success then
            warn("Feature Error: " .. tostring(err))
        end
    end)
end

-- Feature Implementation
createToggle("Auto Steal Eggs", 0.18, function(state)
    -- Insert farm loop here
end)

createToggle("Auto Collect Rewards", 0.34, function(state)
    -- Insert collect loop here
end)

createToggle("Anti-AFK / Bypass", 0.50, function(state)
    if state then
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

createToggle("Speed Boost", 0.66, function(state)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = state and 32 or 16
    end
end)

--------------------------------------------------------------------------------
-- EVENT LOGIC & MENU TOGGLE CONTROLS
--------------------------------------------------------------------------------
VerifyButton.MouseButton1Click:Connect(function()
    local enteredKey = KeyInputBox.Text
    if enteredKey == CORRECT_KEY then
        isKeyAuthenticated = true
        keyExpiryTime = tick() + KEY_DURATION
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
        StatusLabel.Text = "Status: Key Verified!"
        
        task.wait(0.3)
        KeyWindow.Visible = false
        MainWindow.Visible = true
        ToggleMenuButton.Visible = true -- Hiện nút bật/tắt menu ngoài màn hình
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        StatusLabel.Text = "Status: Invalid Key. Type Correctly."
    end
end)

-- Click floating button to show/hide the main menu
ToggleMenuButton.MouseButton1Click:Connect(function()
    MainWindow.Visible = not MainWindow.Visible
    if MainWindow.Visible then
        ToggleMenuButton.Text = "MENU [ON]"
        ToggleMenuButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    else
        ToggleMenuButton.Text = "MENU [OFF]"
        ToggleMenuButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- Non-laggy timer check running on a lightweight task thread
task.spawn(function()
    while true do
        task.wait(1)
        if isKeyAuthenticated then
            local timeLeft = keyExpiryTime - tick()
            if timeLeft > 0 then
                local minutes = math.floor(timeLeft / 60)
                local seconds = math.floor(timeLeft % 60)
                TimeKeyLabel.Text = string.format("EXP: %02d:%02d", minutes, seconds)
            else
                isKeyAuthenticated = false
                MainWindow.Visible = false
                ToggleMenuButton.Visible = false
                KeyWindow.Visible = true
                StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
                StatusLabel.Text = "Status: Key Expired. Re-enter Key."
                TimeKeyLabel.Text = "EXP: 00:00"
            end
        end
    end
end)
