local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("IOHUB_GUI") then
    playerGui.IOHUB_GUI:Destroy()
end

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "IOHUB_GUI"
screenGui.ResetOnSpawn = false 

-- // 1. CIRCLE OPEN BUTTON //
local openBtn = Instance.new("TextButton", screenGui)
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0.5, -25)
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
openBtn.Text = "H"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

-- // 2. MAIN FRAME //
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 600, 0, 300)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(50, 50, 50)
stroke.Thickness = 2

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- // 3. HEADER //
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
local gradient = Instance.new("UIGradient", header)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
})
local title = Instance.new("TextLabel", header)
title.Text = "⚡ IOHUB | DEVELOPED BY IYONGOFFICIAL ⚡"
title.Size = UDim2.new(1, 0, 1, 0)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.Code -- Fixed: CodeBold to Code
title.TextSize = 16
title.BackgroundTransparency = 1
local line = Instance.new("Frame", header)
line.Size = UDim2.new(1, 0, 0, 2)
line.Position = UDim2.new(0, 0, 1, 0)
line.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
line.BorderSizePixel = 0

-- // 4. LAYOUT (I-REPLACE ANG LUMANG LAYOUT PART) //
local body = Instance.new("Frame", mainFrame)
body.Size = UDim2.new(1, 0, 1, -50)
body.Position = UDim2.new(0, 0, 0, 50)
body.BackgroundTransparency = 1

-- SIDEBAR SCROLLING SETUP
local sidebarScroll = Instance.new("ScrollingFrame", body)
sidebarScroll.Size = UDim2.new(0.25, 0, 1, 0)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.ScrollBarThickness = 2
sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local sidebarLayout = Instance.new("UIListLayout", sidebarScroll)
sidebarLayout.Padding = UDim.new(0, 5)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- RIGHT SCROLL SETUP
local rightScroll = Instance.new("ScrollingFrame", body)
rightScroll.Size = UDim2.new(0.75, 0, 1, 0)
rightScroll.Position = UDim2.new(0.25, 0, 0, 0)
rightScroll.BackgroundTransparency = 1
rightScroll.ScrollBarThickness = 2
rightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
rightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local rightLayout = Instance.new("UIListLayout", rightScroll)
rightLayout.Padding = UDim.new(0, 10)
rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center


local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function AutoWalkToPath(pathPoints)
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Noclip On
    local noclipConnection = RunService.Stepped:Connect(function()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)

    -- I-loop ang lahat ng points mula 1 hanggang 5 (o kahit ilan)
    for _, point in pairs(pathPoints) do
        -- Gagamit tayo ng CFrame.lookAt para diretsong tingin sa pupuntahan
        local targetCFrame = CFrame.new(point)
        
        -- Dito natin inaayos ang "jitter":
        -- Imbes na tween, diretso nating i-set ang CFrame para smooth ang bawat step
        hrp.CFrame = targetCFrame
        task.wait(0.1) -- Delay sa bawat location para hindi mag-crash ang physics
    end

    -- Noclip Off
    noclipConnection:Disconnect()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end








-- // FUNCTIONS //
local function CreateTP(name, cframe)
	local btn = Instance.new("TextButton", rightScroll)
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamMedium
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.MouseButton1Click:Connect(function()
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = cframe
		end
	end)
end

local function CreateSectionTitle(name)
	local label = Instance.new("TextLabel", rightScroll)
	label.Size = UDim2.new(1, 0, 0, 30)
	label.Text = "  " .. name
	label.TextColor3 = Color3.fromRGB(100, 150, 255)
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
end

-- // UPDATE SA FUNCTIONS //
-- Palitan ang sidebar sa createTab function:
local function createTab(name, contentFunc)
	-- Dati ay 'sidebar', palitan ito ng 'sidebarScroll'
	local btn = Instance.new("TextButton", sidebarScroll) 
	btn.Size = UDim2.new(0.9, 0, 0, 45)
	btn.Text = "  " .. name
	btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.BackgroundTransparency = 1
	btn.Font = Enum.Font.GothamBold
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.MouseButton1Click:Connect(function()
		-- Dito rin, palitan ang 'sidebar' ng 'sidebarScroll'
		for _, c in pairs(sidebarScroll:GetChildren()) do if c:IsA("TextButton") then c.TextColor3 = Color3.fromRGB(150, 150, 150) end end
		btn.TextColor3 = Color3.new(1,1,1)
		for _, c in pairs(rightScroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
		contentFunc()
	end)
end



local function CreateAllCodesBox()
    local container = Instance.new("Frame", rightScroll)
    container.Size = UDim2.new(1, -20, 0, 70)
    container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local display = Instance.new("TextLabel", container)
    display.Size = UDim2.new(0.65, 0, 1, 0)
    display.Text = "[?][?][?][?][?][?]"
    display.TextColor3 = Color3.new(1, 1, 1)
    display.Font = Enum.Font.Code
    display.TextSize = 18
    display.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0.3, 0, 0.6, 0)
    btn.Position = UDim2.new(0.67, 0, 0.2, 0)
    btn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    btn.Text = "GET ALL"
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
        btn.MouseButton1Click:Connect(function()
        -- Ito ang listahan ng floors base sa iyong Explorer
        local floors = {"6thFloor", "5thFloor", "4thFloor", "3rdFloor", "2ndFloor", "1stFloor"}
        local resultText = ""
        
        for _, fName in pairs(floors) do
            -- Sinusundan natin ang hierarchy na nakita sa Explorer: Section1 > PlayerObjective > CodeNumbers > [Floor] > SurfaceGui > Random
            local folder = workspace:FindFirstChild("Section1")
            local objective = folder and folder:FindFirstChild("PlayerObjective")
            local codeNums = objective and objective:FindFirstChild("CodeNumbers")
            local floor = codeNums and codeNums:FindFirstChild(fName)
            local surfaceGui = floor and floor:FindFirstChild("SurfaceGui")
            local randomLabel = surfaceGui and surfaceGui:FindFirstChild("Random")
            
            -- Kinukuha ang laman ng TextLabel
            if randomLabel and randomLabel:IsA("TextLabel") then
                -- Sinusubukan muna ang ContentText, kung wala ay Text
                local code = (randomLabel.ContentText ~= "" and randomLabel.ContentText) or randomLabel.Text
                resultText = resultText .. "[" .. code .. "]"
            else
                resultText = resultText .. "[?]" -- Kung hindi mahanap, lalabas ang [?]
            end
        end
        
        display.Text = resultText
        display.TextColor3 = Color3.fromRGB(100, 255, 100) -- Magiging green pag-click
    end)

end



createTab("SECTION1", function()
    
    CreateSectionTitle("Teleport Locations")
    CreateTP("SKIP CAVE", CFrame.new(-1235.36902, 4.00000048, -2943.79761, 0.0479142852, 0, -0.998851478, 0, 1, 0, 0.998851478, 0, 0.0479142852))
    CreateTP("Starter Cinematic", CFrame.new(-1155.50256, 4.00000095, -2934.6958))
    CreateTP("Skip to White Door", CFrame.new(4944.86719, -64.27565, 1206.07715))
    CreateTP("Floor 6 BOSS NPC", CFrame.new(4449.49902, 43.9929123, 1659.43604))
   CreateSectionTitle("All Floor Codes")
   CreateAllCodesBox()
end)

createTab("SECTION2", function()
    CreateSectionTitle("Teleport Locations")
    CreateTP("NPC1", CFrame.new(-1218.073, -165.374435, -963.733826, 0.604715049, 7.11412046e-15, 0.796441913, -3.91128602e-15, 1, -5.9626537e-15, -0.796441913, 4.90594495e-16, 0.604715049))
    CreateTP("NPC2", CFrame.new(-1194.18591, -165.374435, -1003.34747, 0.0708335862, -1.11711369e-08, 0.997488141, 1.5711108e-09, 1, 1.10876996e-08, -0.997488141, 7.81782805e-10, 0.0708335862))
    CreateTP("NPC3", CFrame.new(-1144.55237, -142.647232, -1037.26892, 0.999931157, 3.00928562e-08, 0.0117337871, -2.99023704e-08, 1, -1.64095812e-08, -0.0117337871, 1.60575837e-08, 0.999931157))
    CreateTP("NPC4", CFrame.new(-1108.55176, -142.274261, -1038.53027, 0.996299922, -1.92125893e-09, 0.0859442279, 2.29395969e-09, 1, -4.23778213e-09, -0.0859442279, 4.41925474e-09, 0.996299922))
    CreateTP("LEAVE THE MALL", CFrame.new(-1335.1084, -165.374435, -1118.14185, -0.087827906, 7.42749462e-09, -0.996135652, 2.10487155e-10, 1, 7.43774997e-09, 0.996135652, 4.43568238e-10, -0.087827906))
    CreateTP("CAROUSEL", CFrame.new(-1284.86865, -141.74498, -1096.00964, -0.167772949, -1.23703159e-09, -0.985825658, -8.48931769e-09, 1, 1.89938648e-10, 0.985825658, 8.40085423e-09, -0.167772949))
    CreateTP("SPEAKER", CFrame.new(-1230.00476, -166.651611, -1004.56494, 0, 0, -1, 0, 1, 0, 1, 0, 0))
    CreateTP("END THE MALL", CFrame.new(-1424.72717, -118.009972, -938.393677, -0.418884575, 0.0159111526, -0.907900095, 1.98539896e-09, 0.999846458, 0.0175225325, 0.90803951, 0.00733991619, -0.418820262))
   CreateTP("SKIP CHASE 1", CFrame.new(-3294.05835, -187.955933, -944.276062, -0.521288276, -3.49310647e-09, -0.85338068, -4.13962725e-10, 1, -3.84038756e-09, 0.85338068, -1.6486813e-09, -0.521288276))
   CreateTP("SKIP CHASE 2", CFrame.new(-3911.04688, -252.090607, -1103.42798, 0.418543696, -0.0546392314, 0.90655154, 0.00858846679, 0.998382092, 0.056208808, -0.908155978, -0.0157399513, 0.418335795))
end)


createTab("ESP", function()
    local espBtn = Instance.new("TextButton", rightScroll)
    espBtn.Size = UDim2.new(1, -20, 0, 40)
    espBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    espBtn.Text = "Toggle Monster ESP"
    espBtn.TextColor3 = Color3.new(1,1,1)
    espBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 8)
    
    local espEnabled = false
    local targetMonsters = {["Tenome"] = true, ["Tsukiya"] = true, ["Rin"] = true}
    local activeObjects = {} -- Dito natin ilalagay ang Highlight at BillboardGui

    local function createESP(model)
        -- Highlight
        local h = Instance.new("Highlight", model)
        h.FillColor = Color3.fromRGB(255, 50, 50)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.Adornee = model
        h.Enabled = true
        
        -- BillboardGui (Para sa Name Tag)
        local bg = Instance.new("BillboardGui", model)
        bg.Name = "ESP_NameTag"
        bg.Size = UDim2.new(0, 200, 0, 50)
        bg.StudsOffset = Vector3.new(0, 3, 0)
        bg.AlwaysOnTop = true
        
        local lbl = Instance.new("TextLabel", bg)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 20
        lbl.Text = model.Name -- Dito lalabas ang pangalan ng monster
        
        table.insert(activeObjects, h)
        table.insert(activeObjects, bg)
    end

    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        
        if espEnabled then
            espBtn.Text = "ESP: ON"
            for _, obj in pairs(workspace:GetDescendants()) do
                if targetMonsters[obj.Name] then
                    createESP(obj)
                end
            end
        else
            espBtn.Text = "Toggle Monster ESP"
            for _, obj in pairs(activeObjects) do
                if obj then obj:Destroy() end
            end
            activeObjects = {}
        end
    end)
    
    
    CreateSectionTitle("MALL SAFE LOCATIONS")
    CreateTP("SAFE ESCALATOR", CFrame.new(-1160.70581, -149.304581, -1011.77954, 0.991296649, -7.29874339e-09, 0.131647274, 8.19504553e-09, 1, -6.26657481e-09, -0.131647274, 7.29089011e-09, 0.991296649))
    
    
    
end)


createTab("MALL COINS", function()
    CreateSectionTitle("Coin Locations")
    CreateTP("Coin 1", CFrame.new(-1248.91333, -145.623291, -882.680908, -1.10864639e-05, 0.9999547, 0.00954827666, 0.0275003016, 0.00954473019, -0.999576449, -0.999621987, 0.000251710415, -0.0274993181))
    CreateTP("Coin 2", CFrame.new(-1281.35315, -145.654755, -1194.84045, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 3", CFrame.new(-1342.40283, -146.400894, -922.307007, -0.578587532, 0.815587223, 0.00734505057, -0.00588667393, 0.00482952595, -0.999970973, -0.815599084, -0.578613937, 0.00200682878))
    CreateTP("Coin 4", CFrame.new(-1219.13257, -145.044785, -1078.73792, 4.88758087e-06, 0.999998331, 0.00190168619, -0.00267848372, 0.00190150738, -0.999994755, -0.999996603, 2.98023224e-08, 0.00267827511))
    CreateTP("Coin 5", CFrame.new(-1306.45715, -146.524261, -886.15448, -3.09944153e-06, 0.999822855, 0.018820405, 3.01003456e-06, 0.018820405, -0.999822855, -1, -3.01003456e-06, -3.09944153e-06))
    CreateTP("Coin 6", CFrame.new(-1071.29517, -145.502792, -936.500244, -0.287276983, 0.957847595, -2.89678574e-05, -2.89678574e-05, -3.89814377e-05, -1, -0.957847595, -0.287276953, 3.89814377e-05))
    CreateTP("Coin 7", CFrame.new(-1067.19897, -145.483475, -1006.92938, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 8", CFrame.new(-1032.94006, -145.458328, -1049.8689, -0.61596477, 0.787773609, 1.74343586e-05, 1.74343586e-05, 3.57627869e-05, -1, -0.787773609, -0.61596477, -3.57627869e-05))
    CreateTP("Coin 9", CFrame.new(-1052.22314, -145.458328, -1072.41028, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 10", CFrame.new(-1052.09326, -145.537979, -1024.84753, -0.448631406, 0.893716872, 2.44379044e-06, 2.44379044e-06, 3.93390656e-06, -1, -0.893716872, -0.448631406, -3.93390656e-06))
    CreateTP("Coin 11", CFrame.new(-1090.16333, -145.486877, -943.461426, 0.699726522, 0.714410782, -7.83801079e-06, 7.83801079e-06, -1.87158585e-05, -1, -0.714410782, 0.699726582, -1.87158585e-05))
    CreateTP("Coin 12", CFrame.new(-1122.32166, -145.502808, -936.392883, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 13", CFrame.new(-1137.14355, -145.253815, -947.75708, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 14", CFrame.new(-1189.40649, -145.372665, -946.010986, -1.66893005e-06, 0.999973774, 0.00724217296, -0.00197651982, 0.00724220276, -0.999971867, -0.999997973, -1.60038471e-05, 0.00197649002))
    CreateTP("Coin 15", CFrame.new(-1273.26685, -145.878616, -903.746948, -4.529953e-06, 0.999961495, 0.00877809525, 0.00713804364, 0.00877797604, -0.999935985, -0.999974489, 5.8054924e-05, -0.00713777542))
    CreateTP("Coin 16", CFrame.new(-1314.76758, -145.999847, -923.409546, 0.293923736, 0.948396981, 0.118962318, -0.104334414, 0.155550241, -0.982302666, -0.950117469, 0.276310235, 0.144670367))
    CreateTP("Coin 17", CFrame.new(-1236.62927, -145.669815, -891.602844, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 18", CFrame.new(-1375.49731, -146.797852, -909.723572, -3.69548798e-06, 0.999952078, 0.00978437066, 0.0122875869, 0.0097836256, -0.999876618, -0.999924541, 0.000116556883, -0.0122870207))
    CreateTP("Coin 19", CFrame.new(-1088.85156, -145.537979, -993.942993, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 20", CFrame.new(-1088.49377, -145.486923, -964.888733, 0.239873588, 0.970804095, -2.48849392e-05, 2.48849392e-05, -3.18288803e-05, -1, -0.970804095, 0.239873618, -3.18288803e-05))
    CreateTP("Coin 21", CFrame.new(-1090.51697, -145.499374, -1036.5824, -0.448631406, 0.893716872, -2.44379044e-06, -2.44379044e-06, -3.93390656e-06, -1, -0.893716872, -0.448631406, 3.93390656e-06))
    CreateTP("Coin 22", CFrame.new(-1112.62598, -145.219757, -1024.08057, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 23", CFrame.new(-1095.69092, -145.237869, -1072.6543, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 24", CFrame.new(-1103.64185, -145.458328, -1050.98877, -0.461249948, 0.887270331, -2.33054161e-05, -2.33054161e-05, -3.83853912e-05, -1, -0.887270331, -0.461249888, 3.83257866e-05))
    CreateTP("Coin 25", CFrame.new(-1109.09033, -145.237869, -1097.60779, 0, 1, 0, 0, 0, -1, -1, 0, 0))
    CreateTP("Coin 26", CFrame.new(-1196.90039, -145.079071, -1042.84033, 2.48551369e-05, 0.999967158, 0.00809910893, 0.0190609097, 0.00809717178, -0.999785542, -0.999818325, 0.000179201365, -0.0190601349))
    CreateTP("Coin 27", CFrame.new(-1184.13745, -145.166473, -1073.42908, 0.620764196, 0.783997357, -9.47713852e-06, 9.47713852e-06, -1.95503235e-05, -1, -0.783997357, 0.620764256, -1.95503235e-05))
    CreateTP("Coin 28", CFrame.new(-1191.24829, -145.150558, -1064.48706, 5.00679016e-06, 0.999998569, 0.00172907114, -0.00285112858, 0.00172901154, -0.999994516, -0.999996006, 8.94069672e-08, 0.00285112858))
    CreateTP("Coin 29", CFrame.new(-1213.25684, -145.251907, -1091.03809, -5.24520874e-06, -0.999998331, 0.00190168619, 0.00267848372, -0.00190186501, -0.999994755, 0.999996603, -2.98023224e-08, 0.00267827511))
end)

createTab("MALL EYES", function()
CreateSectionTitle("EyePunch Locations")
    CreateTP("EyePunch 1", CFrame.new(-1090.96033, -163.724213, -1027.39709, 1, 0, 0, 0, 1, 0, 0, 0, 1))
    CreateTP("EyePunch 2", CFrame.new(-1162.49756, -163.718704, -1140.53198, 0, 0, 1, 0, 1, -0, -1, 0, 0))
    CreateTP("EyePunch 3", CFrame.new(-1174.35486, -140.808289, -1033.46033, 2.68220901e-06, 0.0331400707, -0.999450743, -0.0109273419, 0.999391019, 0.0331380628, 0.999940336, 0.010921251, 0.000364780426))
    CreateTP("EyePunch 4", CFrame.new(-1092.61462, -159.449341, -1182.24219, 1.81794167e-05, -0.0142828561, 0.999898016, 0.00610414566, 0.99987936, 0.014282479, -0.999981344, 0.00610326324, 0.000105321407))
end)

createTab("AutoPath", function()
    local walkBtn = Instance.new("TextButton", rightScroll)
    walkBtn.Size = UDim2.new(1, -20, 0, 40)
    walkBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    walkBtn.Text = "Execute Fast Path"
    walkBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", walkBtn).CornerRadius = UDim.new(0, 8)
    
    walkBtn.MouseButton1Click:Connect(function()
    local myPath = {
        Vector3.new(-1155, 4, -2934), -- Start Location
        Vector3.new(4944, -64, 1206), -- Location 2
        Vector3.new(4449, 43, 1659),  -- Location 3
        Vector3.new(1000, 10, 1000),  -- Location 4
        Vector3.new(2000, 10, 2000)   -- Location 5 (End)
         }
        AutoWalkToPath(myPath)
end)