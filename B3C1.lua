local players = game:GetService("Players")
local coreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local localPlayer = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait() or players.LocalPlayer

-- File configuration path para sa save/load
local configFileName = "IOHUB_Config.json"
local currentConfigData = {
    toggles = {},
    dropdowns = {}
}

-- Load saved config if exists
if readfile and pcall(readfile, configFileName) then
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(configFileName))
    end)
    if success and decoded then
        currentConfigData = decoded
    end
end

local function saveConfigToFile()
    if writefile then
        pcall(function()
            writefile(configFileName, HttpService:JSONEncode(currentConfigData))
        end)
    end
end

-- Main ScreenGui setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalMenuGui_Delta"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    screenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = coreGui
else
    screenGui.Parent = coreGui
end

----------------------------------------------------
-- NOTIFICATION SYSTEM
----------------------------------------------------
local function showNotification(message)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 220, 0, 40)
    notifFrame.Position = UDim2.new(1, -235, 1, -60)
    notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notifFrame.BackgroundTransparency = 0.2
    notifFrame.BorderSizePixel = 0
    notifFrame.ZIndex = 999
    notifFrame.Parent = screenGui

    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 8)
    nCorner.Parent = notifFrame

    local nStroke = Instance.new("UIStroke")
    nStroke.Color = Color3.fromRGB(150, 30, 50)
    nStroke.Thickness = 1
    nStroke.Parent = notifFrame

    local nText = Instance.new("TextLabel")
    nText.Size = UDim2.new(1, 0, 1, 0)
    nText.BackgroundTransparency = 1
    nText.Text = message
    nText.TextColor3 = Color3.fromRGB(255, 255, 255)
    nText.Font = Enum.Font.GothamBold
    nText.TextSize = 11
    nText.ZIndex = 1000
    nText.Parent = notifFrame

    task.delay(2, function()
        local tw = TweenService:Create(notifFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        tw:Play()
        TweenService:Create(nText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        tw.Completed:Connect(function()
            notifFrame:Destroy()
        end)
    end)
end

----------------------------------------------------
-- MAIN CONTAINER WINDOW
----------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 580, 0, 420)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false 
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

----------------------------------------------------
-- FLOATING TOGGLE IMAGE BUTTON
----------------------------------------------------
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "MenuToggleButton"
toggleButton.Size = UDim2.new(0, 55, 0, 55)
toggleButton.Position = UDim2.new(0, 20, 0.5, -27) 
toggleButton.BackgroundTransparency = 1
toggleButton.Image = "rbxassetid://139934599708171" 
toggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Active = true
toggleButton.Parent = screenGui

----------------------------------------------------
-- DRAGGING FEATURE
----------------------------------------------------
local userInputService = game:GetService("UserInputService")

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

makeDraggable(mainFrame)
makeDraggable(toggleButton)

----------------------------------------------------
-- TOGGLE LOGIC
----------------------------------------------------
local uiTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local isMenuOpen = false 
local isTweening = false 

local function minimizeToButton()
    if isTweening then return end
    isTweening = true
    
    local closeTween = TweenService:Create(mainFrame, uiTweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        mainFrame.Visible = false
        isMenuOpen = false
        isTweening = false
    end)
end

local function openMenu()
    if isTweening then return end
    isTweening = true
    
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 0, 0, 0) 
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local openTween = TweenService:Create(mainFrame, uiTweenInfo, {
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210)
    })
    openTween:Play()
    openTween.Completed:Connect(function()
        isMenuOpen = true
        isTweening = false
    end)
end

toggleButton.MouseButton1Click:Connect(function()
    if isMenuOpen then minimizeToButton() else openMenu() end
end)

----------------------------------------------------
-- TOP WINDOW CONTROL DOTS & TITLE
----------------------------------------------------
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "Controls"
controlsFrame.Size = UDim2.new(0, 60, 0, 20)
controlsFrame.Position = UDim2.new(1, -75, 0, 15)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

local colors = {Color3.fromRGB(255, 95, 87), Color3.fromRGB(254, 188, 46), Color3.fromRGB(40, 200, 64)}
for i, color in ipairs(colors) do
    local dot = Instance.new("TextButton")
    dot.Name = "ControlDot" .. i
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, (i - 1) * 20, 0, 4)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Text = ""
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    dot.Parent = controlsFrame
    dot.MouseButton1Click:Connect(minimizeToButton)
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "IOHUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 24, 0, 24)
logo.Position = UDim2.new(0, 15, 0, 12)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://10840244199" 
logo.ImageColor3 = Color3.fromRGB(255, 30, 30)
logo.Parent = mainFrame

----------------------------------------------------
-- NAVIGATION & PAGES SETUP
----------------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 160, 1, -60)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundTransparency = 1
sidebar.Parent = mainFrame

local uiListSide = Instance.new("UIListLayout")
uiListSide.Padding = UDim.new(0, 8)
uiListSide.SortOrder = Enum.SortOrder.LayoutOrder
uiListSide.Parent = sidebar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -195, 1, -55)
contentFrame.Position = UDim2.new(0, 180, 0, 40)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentFrame.BackgroundTransparency = 0.4
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = contentFrame

local tabs = {}
local pages = {}
local activeTab = nil

local function createPageContainer()
    local scrollPage = Instance.new("ScrollingFrame")
    scrollPage.Size = UDim2.new(1, -10, 1, -15)
    scrollPage.Position = UDim2.new(0, 5, 0, 10)
    scrollPage.BackgroundTransparency = 1
    scrollPage.BorderSizePixel = 0
    scrollPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollPage.ScrollBarThickness = 2
    scrollPage.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollPage.Visible = false
    scrollPage.Parent = contentFrame

    local uiListContent = Instance.new("UIListLayout")
    uiListContent.Padding = UDim.new(0, 10)
    uiListContent.SortOrder = Enum.SortOrder.LayoutOrder
    uiListContent.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListContent.Parent = scrollPage
    
    uiListContent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollPage.CanvasSize = UDim2.new(0, 0, 0, uiListContent.AbsoluteContentSize.Y + 20)
    end)

    return scrollPage
end

local function switchTab(tabName)
    for name, btnElements in pairs(tabs) do
        if name == tabName then
            btnElements.Button.BackgroundTransparency = 0.9
            btnElements.Icon.ImageColor3 = Color3.fromRGB(255, 100, 120)
            btnElements.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            if btnElements.Stroke then btnElements.Stroke.Enabled = true end
            pages[name].Visible = true
        else
            btnElements.Button.BackgroundTransparency = 1
            btnElements.Icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
            btnElements.Label.TextColor3 = Color3.fromRGB(180, 180, 180)
            if btnElements.Stroke then btnElements.Stroke.Enabled = false end
            pages[name].Visible = false
        end
    end
    activeTab = tabName
end

local function createSidebarTab(name, iconId, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundTransparency = 1
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.LayoutOrder = order
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 20, 40)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Enabled = false
    stroke.Parent = btn
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0, 12, 0.5, -8)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    icon.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.Parent = sidebar
    
    tabs[name] = {Button = btn, Icon = icon, Label = lbl, Stroke = stroke}
    pages[name] = createPageContainer()
end

----------------------------------------------------
-- MAIN DROPDOWN SECTION
----------------------------------------------------
local function createDropdownSection(pageName, sectionTitle)
    local targetPage = pages[pageName]
    if not targetPage then return end

    local isOpen = false 
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.92, 0, 0, 40)
    dropContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = targetPage

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 8)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 40)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -40, 1, 0)
    titleLbl.Position = UDim2.new(0, 15, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = sectionTitle
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 20
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 16, 0, 16)
    arrowIcon.Position = UDim2.new(1, -28, 0.5, -8)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    arrowIcon.Parent = headerBtn

    local itemsHolder = Instance.new("Frame")
    itemsHolder.Size = UDim2.new(1, 0, 0, 0)
    itemsHolder.Position = UDim2.new(0, 0, 0, 40)
    itemsHolder.BackgroundTransparency = 1
    itemsHolder.Parent = dropContainer

    local itemsList = Instance.new("UIListLayout")
    itemsList.Padding = UDim.new(0, 8)
    itemsList.SortOrder = Enum.SortOrder.LayoutOrder
    itemsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemsList.Parent = itemsHolder

    itemsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.92, 0, 0, itemsList.AbsoluteContentSize.Y + 50)
            itemsHolder.Size = UDim2.new(1, 0, 0, itemsList.AbsoluteContentSize.Y + 10)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.92, 0, 0, itemsList.AbsoluteContentSize.Y + 50)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.92, 0, 0, 40)}):Play()
        end
    end)

    return itemsHolder
end

----------------------------------------------------
-- NESTED DROPDOWN SECTION
----------------------------------------------------
local function createNestedDropdownSection(parentContainer, sectionTitle)
    local isOpen = false
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -35, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = sectionTitle
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local itemsHolder = Instance.new("Frame")
    itemsHolder.Size = UDim2.new(1, 0, 0, 0)
    itemsHolder.Position = UDim2.new(0, 0, 0, 36)
    itemsHolder.BackgroundTransparency = 1
    itemsHolder.Parent = dropContainer

    local itemsList = Instance.new("UIListLayout")
    itemsList.Padding = UDim.new(0, 6)
    itemsList.SortOrder = Enum.SortOrder.LayoutOrder
    itemsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemsList.Parent = itemsHolder

    itemsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.95, 0, 0, itemsList.AbsoluteContentSize.Y + 45)
            itemsHolder.Size = UDim2.new(1, 0, 0, itemsList.AbsoluteContentSize.Y + 10)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, itemsList.AbsoluteContentSize.Y + 45)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return itemsHolder
end

----------------------------------------------------
-- BUTTON CREATOR (Para sa Action Buttons tulad ng Save)
----------------------------------------------------
local function createButton(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 42)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 16)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0, 100, 0, 26)
    actionBtn.Position = UDim2.new(1, -100, 0.5, -13)
    actionBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 50)
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.Text = "Save"
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 11
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn
    
    actionBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    actionBtn.Parent = row
    row.Parent = parentContainer
end

----------------------------------------------------
-- MULTI-SELECT DROPDOWN SELECTOR (FIXED SEARCH)
----------------------------------------------------
local function createDropdownSelect(parentContainer, title, itemsListTable, callback)
    local isOpen = false
    
    if not currentConfigData.dropdowns[title] then
        currentConfigData.dropdowns[title] = {}
    end
    local selectedItems = currentConfigData.dropdowns[title]
    local allSelected = false
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.4, 0, 1, 0)
    selectedLbl.Position = UDim2.new(0.55, -20, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = "None selected"
    selectedLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    selectedLbl.Font = Enum.Font.Gotham
    selectedLbl.TextSize = 10
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, 0, 0, 0)
    contentHolder.Position = UDim2.new(0, 0, 0, 36)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = dropContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = contentHolder

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.92, 0, 0, 28)
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search 🔎"
    searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 11
    searchBox.ClearTextOnFocus = false
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 4)
    searchCorner.Parent = searchBox
    searchBox.Parent = contentHolder

    local scrollOptions = Instance.new("ScrollingFrame")
    scrollOptions.Size = UDim2.new(0.92, 0, 0, 90)
    scrollOptions.BackgroundTransparency = 1
    scrollOptions.BorderSizePixel = 0
    scrollOptions.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollOptions.ScrollBarThickness = 2
    scrollOptions.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollOptions.Parent = contentHolder

    local optList = Instance.new("UIListLayout")
    optList.Padding = UDim.new(0, 4)
    optList.SortOrder = Enum.SortOrder.LayoutOrder
    optList.Parent = scrollOptions

    local optionButtons = {}
    local allBtn = nil

    local function updateSelectedLabel()
        local count = 0
        local names = {}
        for item, isSel in pairs(selectedItems) do
            if isSel then
                count = count + 1
                table.insert(names, item)
            end
        end
        if count == 0 then
            selectedLbl.Text = "None selected"
        elseif count == #itemsListTable then
            selectedLbl.Text = "All selected"
        else
            selectedLbl.Text = table.concat(names, ", ")
        end
    end

    local function updateAllButtonState()
        if not allBtn then return end
        local allCurrentlySelected = true
        for _, itemText in ipairs(itemsListTable) do
            if not selectedItems[itemText] then
                allCurrentlySelected = false
                break
            end
        end
        allSelected = allCurrentlySelected
        
        allBtn.BackgroundColor3 = allSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
        allBtn.BackgroundTransparency = allSelected and 0.2 or 0.5
        allBtn.TextColor3 = allSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        allBtn.Font = allSelected and Enum.Font.GothamBold or Enum.Font.Gotham
    end

    local function populateOptions(filter)
        -- Linisin nang lubusan ang lumang buttons para hindi magpatong-patong
        for _, btn in pairs(optionButtons) do 
            if btn.Button then btn.Button:Destroy() end 
        end
        optionButtons = {}
        if allBtn then allBtn:Destroy() allBtn = nil end

        -- I-trim at gawing lowercase ang filter para sa malinis na paghahanap
        local cleanFilter = string.lower(string.gsub(filter or "", "^%s*(.-)%s*$", "%1"))

        -- Ilagay ang "All" button kung pasok sa filter
        if cleanFilter == "" or string.find(string.lower("All"), cleanFilter) then
            allBtn = Instance.new("TextButton")
            allBtn.Size = UDim2.new(1, 0, 0, 26)
            allBtn.BackgroundColor3 = allSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
            allBtn.BackgroundTransparency = allSelected and 0.2 or 0.5
            allBtn.Text = "  All"
            allBtn.TextColor3 = allSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            allBtn.Font = allSelected and Enum.Font.GothamBold or Enum.Font.Gotham
            allBtn.TextSize = 11
            allBtn.TextXAlignment = Enum.TextXAlignment.Left

            local allCorner = Instance.new("UICorner")
            allCorner.CornerRadius = UDim.new(0, 4)
            allCorner.Parent = allBtn

            allBtn.MouseButton1Click:Connect(function()
                allSelected = not allSelected
                for _, itemText in ipairs(itemsListTable) do
                    selectedItems[itemText] = allSelected
                end
                updateAllButtonState()
                for _, btnData in pairs(optionButtons) do
                    local isSel = selectedItems[btnData.ItemName] == true
                    btnData.Button.BackgroundColor3 = isSel and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                    btnData.Button.BackgroundTransparency = isSel and 0.2 or 0.5
                    btnData.Button.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    btnData.Button.Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham
                end
                updateSelectedLabel()
                if callback then callback(selectedItems) end
            end)

            allBtn.Parent = scrollOptions
        end

        -- I-loop at i-filter ang mga item batay sa tinype sa search box
        for _, itemText in ipairs(itemsListTable) do
            local lowerItemText = string.lower(itemText)
            if cleanFilter == "" or string.find(lowerItemText, cleanFilter) then
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                
                local isSelected = selectedItems[itemText] == true
                optBtn.BackgroundColor3 = isSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                optBtn.BackgroundTransparency = isSelected and 0.2 or 0.5
                optBtn.Text = "  " .. itemText
                optBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                optBtn.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.TextXAlignment = Enum.TextXAlignment.Left

                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 4)
                optCorner.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    selectedItems[itemText] = not selectedItems[itemText]
                    
                    local nowSelected = selectedItems[itemText]
                    optBtn.BackgroundColor3 = nowSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                    optBtn.BackgroundTransparency = nowSelected and 0.2 or 0.5
                    optBtn.TextColor3 = nowSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    optBtn.Font = nowSelected and Enum.Font.GothamBold or Enum.Font.Gotham

                    updateAllButtonState()
                    updateSelectedLabel()
                    if callback then callback(selectedItems) end
                end)

                optBtn.Parent = scrollOptions
                table.insert(optionButtons, {Button = optBtn, ItemName = itemText})
            end
        end

        updateAllButtonState()
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 10)
        
        if isOpen then
            local optionListHeight = optList.AbsoluteContentSize.Y + 15
            if optionListHeight > 90 then optionListHeight = 90 end
            scrollOptions.Size = UDim2.new(0.92, 0, 0, optionListHeight)
            
            local totalTargetHeight = optionListHeight + 36 + 28 + 20
            dropContainer.Size = UDim2.new(0.95, 0, 0, totalTargetHeight)
        end
    end

    populateOptions("")
    updateSelectedLabel()
    if callback then callback(selectedItems) end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        populateOptions(searchBox.Text)
    end)

    optList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 10)
    end)

    contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if isOpen then
            local optionListHeight = optList.AbsoluteContentSize.Y + 15
            if optionListHeight > 90 then optionListHeight = 90 end
            local totalHeight = optionListHeight + 36 + 28 + 20
            dropContainer.Size = UDim2.new(0.95, 0, 0, totalHeight)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            local optionListHeight = optList.AbsoluteContentSize.Y + 15
            if optionListHeight > 90 then optionListHeight = 90 end
            local totalHeight = optionListHeight + 36 + 28 + 20
            
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, totalHeight)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return dropContainer
end


----------------------------------------------------
-- SINGLE-SELECT DROPDOWN SELECTOR (Walang Search / Walang All)
----------------------------------------------------
local function createSingleDropdownSelect(parentContainer, title, itemsListTable, callback)
    local isOpen = false
    
    -- Gagamit tayo ng string value para sa single selection state
    if not currentConfigData.singleDropdowns then
        currentConfigData.singleDropdowns = {}
    end
    if not currentConfigData.singleDropdowns[title] then
        currentConfigData.singleDropdowns[title] = itemsListTable[1] or ""
    end
    
    local selectedValue = currentConfigData.singleDropdowns[title]
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.4, 0, 1, 0)
    selectedLbl.Position = UDim2.new(0.55, -20, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = selectedValue ~= "" and selectedValue or "Select..."
    selectedLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    selectedLbl.Font = Enum.Font.Gotham
    selectedLbl.TextSize = 10
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, 0, 0, 0)
    contentHolder.Position = UDim2.new(0, 0, 0, 36)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = dropContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = contentHolder

    local scrollOptions = Instance.new("ScrollingFrame")
    scrollOptions.Size = UDim2.new(0.92, 0, 0, #itemsListTable * 30 + 5)
    scrollOptions.BackgroundTransparency = 1
    scrollOptions.BorderSizePixel = 0
    scrollOptions.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollOptions.ScrollBarThickness = 2
    scrollOptions.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollOptions.Parent = contentHolder

    local optList = Instance.new("UIListLayout")
    optList.Padding = UDim.new(0, 4)
    optList.SortOrder = Enum.SortOrder.LayoutOrder
    optList.Parent = scrollOptions

    local optionButtons = {}

    local function populateOptions()
        for _, btn in pairs(optionButtons) do btn:Destroy() end
        optionButtons = {}

        for _, itemText in ipairs(itemsListTable) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            
            local isSelected = (selectedValue == itemText)
            optBtn.BackgroundColor3 = isSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
            optBtn.BackgroundTransparency = isSelected and 0.2 or 0.5
            
            optBtn.Text = "  " .. itemText
            optBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            optBtn.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
            optBtn.TextSize = 11
            optBtn.TextXAlignment = Enum.TextXAlignment.Left

            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 4)
            optCorner.Parent = optBtn

            optBtn.MouseButton1Click:Connect(function()
                selectedValue = itemText
                currentConfigData.singleDropdowns[title] = selectedValue
                selectedLbl.Text = selectedValue
                
                -- Isara ang dropdown pagkapili
                isOpen = false
                local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
                TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()

                populateOptions()
                if callback then callback(selectedValue) end
            end)

            optBtn.Parent = scrollOptions
            table.insert(optionButtons, optBtn)
        end
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 5)
    end

    populateOptions()
    if callback then callback(selectedValue) end

    contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.95, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local totalHeight = listLayout.AbsoluteContentSize.Y + 20
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, totalHeight)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return dropContainer
end

----------------------------------------------------
-- ENTER TEXT / INPUT BOX (Para sa Custom Weight Target)
----------------------------------------------------
local function createEnterText(parentContainer, title, placeholder, defaultVal, callback)
    if not currentConfigData.inputs then
        currentConfigData.inputs = {}
    end
    if currentConfigData.inputs[title] == nil then
        currentConfigData.inputs[title] = tostring(defaultVal or "")
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = parentContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = container

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 100, 0, 26)
    textBox.Position = UDim2.new(1, -108, 0.5, -13)
    textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    textBox.BackgroundTransparency = 0.4
    textBox.Text = currentConfigData.inputs[title]
    textBox.PlaceholderText = placeholder or "Enter..."
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 11
    textBox.ClearTextOnFocus = false
    textBox.Parent = container

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = textBox

    textBox.FocusLost:Connect(function(enterPressed)
        local val = textBox.Text
        currentConfigData.inputs[title] = val
        if callback then
            callback(val)
        end
    end)

    return container
end



----------------------------------------------------
-- TOGGLE CREATOR
----------------------------------------------------
local function createToggle(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 42)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 16)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 36, 0, 18)
    toggleBtn.Position = UDim2.new(1, -34, 0.5, -9)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(0, 3, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator
    indicator.Parent = toggleBtn
    
    local enabled = currentConfigData.toggles[title] == true
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    local function applyState(state, immediate)
        enabled = state
        currentConfigData.toggles[title] = enabled
        if immediate then
            if enabled then
                toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                indicator.Position = UDim2.new(1, -15, 0.5, -6)
                indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            else
                toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                indicator.Position = UDim2.new(0, 3, 0.5, -6)
                indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        else
            if enabled then
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            else
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end
        end
        if callback then callback(enabled) end
    end

    applyState(enabled, true)
    
    toggleBtn.MouseButton1Click:Connect(function()
        applyState(not enabled, false)
    end)
    
    toggleBtn.Parent = row
    row.Parent = parentContainer
end

local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

----------------------------------------------------
-- TOGGLE CREATOR (May On/Off switch)
----------------------------------------------------
local function createToggle(pageName, title, description, callback)
    local targetPage = pages[pageName]
    if not targetPage then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.92, 0, 0, 55)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 18)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 32)
    descLabel.Position = UDim2.new(0, 0, 0, 20)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -11)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(0, 3, 0.5, -8)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator
    indicator.Parent = toggleBtn
    
    local enabled = false
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        else
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
        if callback then callback(enabled) end
    end)
    
    toggleBtn.Parent = row
    row.Parent = targetPage
end

----------------------------------------------------
-- 2. UPDATED BUTTON CREATOR (Malaking Rectangle + Mouse Icon)
----------------------------------------------------
local function createButton(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 48) -- Swabe ang taas para sa dalawang linya ng text
    row.BackgroundTransparency = 1
    
    -- Ang buong row ay ginawang isang malaking clickable rectangle button
    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(1, 0, 1, 0)
    actionBtn.Position = UDim2.new(0, 0, 0, 0)
    actionBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 50) -- Kulay ng button mo
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.Text = "" -- Walang default text, gagamit tayo ng labels
    actionBtn.AutoButtonColor = true
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn
    
    -- Spacing sa loob para sa mga teksto
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = actionBtn
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.8, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = actionBtn
    
    -- Description Label
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.8, 0, 0, 18)
    descLabel.Position = UDim2.new(0, 0, 0, 24)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = actionBtn
    
    -- Mouse Clicker Icon sa kanang dulo
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(1, -24, 0.5, -12)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🖱️"
    iconLabel.TextSize = 14
    iconLabel.Parent = actionBtn
    
    -- Click trigger ng button
    actionBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    actionBtn.Parent = row
    row.Parent = parentContainer
end


----------------------------------------------------
-- BAGONG BUTTON CREATOR (Para lang sa mga Standalone Buttons na may Mouse Pointer)
----------------------------------------------------
local function createCustomButton(pageName, title, description, callback)
    local targetPage = pages[pageName]
    if not targetPage then return end

    -- Ang mismong malaking clickable rectangle button
    local actionBtn = Instance.new("TextButton")
    actionBtn.Name = title .. "_CustomRectangle"
    actionBtn.Size = UDim2.new(0.92, 0, 0, 55) -- Malaking rectangle
    actionBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40) -- Kulay na babagay sa background ng IOHUB mo
    actionBtn.BackgroundTransparency = 0.4
    actionBtn.Text = "" -- Alisin ang default button text
    actionBtn.AutoButtonColor = true

    -- Bilugan ang mga kanto ng rectangle
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn

    -- Spacing para hindi nakadikit ang mga letra sa gilid
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = actionBtn
    
    -- Title Label sa loob ng malaking button
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 18)
    titleLabel.Position = UDim2.new(0, 0, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = actionBtn
    
    -- Description Label sa loob ng malaking button
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 32)
    descLabel.Position = UDim2.new(0, 0, 0, 24)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = actionBtn
    
    -- Ang Mouse Click Cursor Asset sa kanang dulo ng rectangle
    local mouseIcon = Instance.new("ImageLabel")
    mouseIcon.Name = "MousePointerIcon"
    mouseIcon.Size = UDim2.new(0, 22, 0, 22)
    mouseIcon.Position = UDim2.new(1, -25, 0.5, -11)
    mouseIcon.BackgroundTransparency = 1
    mouseIcon.Image = "rbxassetid://10734896206" -- Mouse click cursor icon asset
    mouseIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    mouseIcon.Parent = actionBtn
    
    -- Click at Flash Effect para sa mouse pointer
    actionBtn.MouseButton1Click:Connect(function()
        mouseIcon.ImageColor3 = Color3.fromRGB(255, 100, 120)
        task.wait(0.1)
        mouseIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
        if callback then callback() end
    end)
    
    actionBtn.Parent = targetPage
end


-- ====================================================================
-- 3. SIDEBAR TABS & GROUPS DEFINITION
-- ====================================================================

createSidebarTab("Section 1", "rbxassetid://10723345479", 1)
createSidebarTab("Section 2", "rbxassetid://10723345479", 2)
createSidebarTab("Section 3", "rbxassetid://10734951111", 3)
createSidebarTab("Section 4", "rbxassetid://10734951111", 4)
createSidebarTab("Section 5", "rbxassetid://10734951111", 5)
createSidebarTab("Settings", "rbxassetid://10734951111", 6)


-- Kunin ang mga kailangang serbisyo
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- Function para sa gilid na notification
local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 2;
    })
end

-- I-wrap sa iyong custom button function
createCustomButton("Section 1", "Civilian Interact", "Teleport to Civilian and Interact", function()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Siguraduhing umiiral ang folder ng mga civilian bago mag-umpisa
    local deadCiviliansFolder = Workspace:FindFirstChild("Section1") 
        and Workspace.Section1:FindFirstChild("DeadCivilians")

    if not deadCiviliansFolder then
        notify("Error", "Hindi mahanap ang DeadCivilians folder!", 3)
        return
    end

    -- Ang iyong mga eksaktong ligtas na CFrame listahan
    local civiliansCFrame = {
        CFrame.new(82.2101974, 7.01562452, 229.03598, 0.999974549, 1.60358249e-09, -0.00713643711, -1.60001368e-09, 1, 5.05793407e-10, 0.00713643711, -4.94362107e-10, 0.999974549),
        CFrame.new(29.5840073, 7.05437136, -87.9759293, 0.999974549, 7.98299926e-10, -0.00713643711, -7.60655594e-10, 1, 5.27766053e-09, 0.00713643711, -5.27209787e-09, 0.999974549),
        CFrame.new(-182.772629, 7.01562452, 73.8156357, 0.0309865493, 1.37417135e-08, 0.999519825, -2.71963851e-09, 1, -1.36640024e-08, -0.999519825, -2.29493224e-09, 0.0309865493),
        CFrame.new(225.873566, 7.03801394, -84.7873001, 0.999954641, 6.97570335e-10, 0.00952569582, -9.66604463e-10, 1, 2.82383912e-08, -0.00952569582, -2.82463173e-08, 0.999954641),
        CFrame.new(-3.58142662, 7.01562452, -176.386215, -0.992575169, -1.97492529e-08, -0.121632636, -1.93827052e-08, 1, -4.19672697e-09, 0.121632636, -1.80799731e-09, -0.992575169),
        CFrame.new(80.6713104, 7.0411253, 149.687668, -0.997461557, 1.115201e-08, -0.0712069646, 1.04766196e-08, 1, 9.85837101e-09, 0.0712069646, 9.08733799e-09, -0.997461557)
    }

    -- Helper function para hanapin ang ProximityPrompt na pinakamalapit sa posisyon ng player
    local function getClosestPrompt()
        local closestPrompt = nil
        local shortestDistance = math.huge

        for _, civilian in ipairs(deadCiviliansFolder:GetChildren()) do
            local hrp = civilian:FindFirstChild("HumanoidRootPart")
            local prompt = hrp and hrp:FindFirstChildOfClass("ProximityPrompt")
            
            if prompt and hrp then
                local distance = (humanoidRootPart.Position - hrp.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPrompt = prompt
                end
            end
        end
        return closestPrompt
    end

    notify("Script Started", "Sisimulan na ang pag-teleport sa 6 na civilians...", 3)

    -- Loop sa iyong 6 na safe CFrames
    for i, targetCFrame in ipairs(civiliansCFrame) do
        -- 1. I-teleport ang player gamit ang iyong ligtas na coordinate
        humanoidRootPart.CFrame = targetCFrame
        task.wait(0.4) -- Delay para siguradong naka-load ang lapag at hindi mahulog

        -- 2. Hanapin ang pinakamalapit na ProximityPrompt sa posisyong ito
        local prompt = getClosestPrompt()

        if prompt then
            -- 3. I-bypass ang mga posibleng restriction ng prompt (para sa nakahigang civilian)
            local originalRequiresLineOfSight = prompt.RequiresLineOfSight
            local originalMaxDistance = prompt.MaxActivationDistance
            
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 50 -- Tinaasan para sigurado kahit may kaunting distansya
            task.wait(0.1)

            -- 4. Trigger ang Proximity Prompt at mag-notify sa gilid ng screen
            fireproximityprompt(prompt)
            notify("Interacting", "Civilian [" .. i .. "/" .. #civiliansCFrame .. "]", 1.5)

            -- 5. Ibalik sa dati ang properties ng prompt (iwas anti-cheat flag)
            prompt.RequiresLineOfSight = originalRequiresLineOfSight
            prompt.MaxActivationDistance = originalMaxDistance

            -- 6. Maghintay ng 2 segundo bago lumipat sa kasunod
            task.wait(2)
        else
            notify("Warning", "Walang nahanap na prompt malapit sa Spot #" .. i, 2)
            task.wait(1)
        end
    end

    notify("Success", "Tapos na ang pag-interact sa lahat gamit ang safe CFrame!", 4)
end)






    --auto ammo box
    --Workspace.Section1.Grunts.Ammo Box .ProximityPrompt
    
   -- gata npc
  --  Workspace.Section1.Grunts.Gata.HumanoidRootPart
 --   Workspace.Section1.Grunts.Gata2.HumanoidRootPart
    
    
-- ====================================================================
-- Naayos na Unang Button (Idinagdag ang tamang Player check)
-- ====================================================================
createCustomButton("Section 1", "Teleport to Mika", "Go to Mika and Watch Her", function()
    -- Kinuha ang local player para hindi mag-error
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-260.086, 7.016, -299.436)
    end
end)

-- ====================================================================
-- Ang Hideo Interact Button ay WALANG MALI (100% Malinis)
-- ====================================================================
createCustomButton("Section 1", "Hideo Interact", "Teleport to Hideo and Interact", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    notify("Teleporting", "Papunta na kay Hideo...", 1.5)
    humanoidRootPart.CFrame = CFrame.new(107.692, 7.064, 269.127)
    task.wait(0.5)

    local hideoScene = Workspace:FindFirstChild("Section1") and Workspace.Section1:FindFirstChild("HideoScene")
    local hideo2 = hideoScene and hideoScene:FindFirstChild("Hideo2")
    local hrp = hideo2 and hideo2:FindFirstChild("HumanoidRootPart")
    local prompt = hrp and hrp:FindFirstChildOfClass("ProximityPrompt")

    if prompt then
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50 
        task.wait(0.1)

        fireproximityprompt(prompt)
        notify("Success", "Naka-interact na kay Hideo!", 2)

        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
    else
        notify("Error", "Hindi mahanap ang ProximityPrompt ni Hideo!", 3)
    end
end)

-- ====================================================================
-- Ang Unlock Gate & School Door Button ay WALANG MALI (100% Malinis)
-- ====================================================================
createCustomButton("Section 1", "Unlock Gate & School Door", "Get Key and Unlock The Gate and School Door", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50 
        task.wait(0.1)
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    -- STAGE 1
    notify("Stage 1/3", "Papunta na sa BoltCutter...", 2)
    humanoidRootPart.CFrame = CFrame.new(202.509, 7.060, 109.554)
    task.wait(0.5)

    local boltPrompt = Workspace:FindFirstChild("Section1")
        and Workspace.Section1:FindFirstChild("SchoolGatePart")
        and Workspace.Section1.SchoolGatePart:FindFirstChild("Truck")
        and Workspace.Section1.SchoolGatePart.Truck:FindFirstChild("BoltCutter")
        and Workspace.Section1.SchoolGatePart.Truck.BoltCutter:FindFirstChild("Main")
        and Workspace.Section1.SchoolGatePart.Truck.BoltCutter.Main:FindFirstChild("ProximityPrompt")

    if boltPrompt then
        safeFirePrompt(boltPrompt)
        notify("Stage 1 Success", "Nakuha na ang BoltCutter!", 1.5)
    else
        notify("Stage 1 Failed", "Hindi nahanap ang BoltCutter prompt!", 3)
    end
    task.wait(1)

    -- STAGE 2
    notify("Stage 2/3", "Papunta na sa Gate...", 2)
    humanoidRootPart.CFrame = CFrame.new(124.809, 7.052, 273.595)
    task.wait(0.5)

    local gatePrompt = Workspace:FindFirstChild("Section1")
        and Workspace.Section1:FindFirstChild("SchoolGatePart")
        and Workspace.Section1.SchoolGatePart:FindFirstChild("Gate")
        and Workspace.Section1.SchoolGatePart.Gate:FindFirstChild("Chain")
        and Workspace.Section1.SchoolGatePart.Gate.Chain:FindFirstChild("PromptPart")
        and Workspace.Section1.SchoolGatePart.Gate.Chain.PromptPart:FindFirstChild("ProximityPrompt")

    if gatePrompt then
        for i = 1, 4 do
            notify("Unlocking Gate", "Firing chain prompt: (" .. i .. "/4)", 1)
            safeFirePrompt(gatePrompt)
            task.wait(0.3)
        end
        notify("Stage 2 Success", "Naka-unlock na ang Gate!", 1.5)
    else
        notify("Stage 2 Failed", "Hindi nahanap ang Gate prompt!", 3)
    end
    task.wait(1)

    -- STAGE 3
    notify("Stage 3/3", "Papunta na sa School Door...", 2)
    humanoidRootPart.CFrame = CFrame.new(174.551, 7.541, 329.988)
    task.wait(0.5)

    local doorPrompt = Workspace:FindFirstChild("Section2")
        and Workspace.Section2:FindFirstChild("School")
        and Workspace.Section2.School:FindFirstChild("Doors")
        and Workspace.Section2.School.Doors:FindFirstChild("MainDoors")
        and Workspace.Section2.School.Doors.MainDoors:FindFirstChild("EntireDoor")
        and Workspace.Section2.School.Doors.MainDoors.EntireDoor:FindFirstChild("Door")
        and Workspace.Section2.School.Doors.MainDoors.EntireDoor.Door:FindFirstChild("PROXPART")
        and Workspace.Section2.School.Doors.MainDoors.EntireDoor.Door.PROXPART:FindFirstChild("ProximityPrompt")

    if doorPrompt then
        safeFirePrompt(doorPrompt)
        notify("Stage 3 Success", "Main School Door is now open!", 2)
    else
        notify("Stage 3 Failed", "Hindi nahanap ang School Door prompt!", 3)
    end
    
    notify("Mission Complete", "Tapos na ang buong automation process!", 4)
end)


-- GET MEDKIT AND GO TO HIDEO

createCustomButton("Section 2", "Hideo Minigame Starter", "Get Medkit and Open Hideo Minigame", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Local function para sa malinis na notification sa gilid
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Helper function para sa ligtas na pag-fire ng ProximityPrompt (para sa Medkit at Hideo)
    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50 -- Tinaasan para abot kahit may kaunting harang
        task.wait(0.1)
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end


    notify("Step 1/2", "Teleporting sa Medkit...", 2)
    humanoidRootPart.CFrame = CFrame.new(212.713, 33.755, 342.602)
    task.wait(0.5) -- Sandaling wait para mag-sync ang posisyon sa lapag

    local medkitPrompt = Workspace:FindFirstChild("Section2")
        and Workspace.Section2:FindFirstChild("Items")
        and Workspace.Section2.Items:FindFirstChild("Bandage")
        and Workspace.Section2.Items.Bandage:FindFirstChild("Handle")
        and Workspace.Section2.Items.Bandage.Handle:FindFirstChild("ProximityPrompt")

    if medkitPrompt then
        safeFirePrompt(medkitPrompt)
        notify("Medkit Success", "You Got the Medkit!", 1.5)
    else
        notify("Medkit Warning", "Medkit Not Found but it's Counting", 2.5)
    end
    task.wait(1) -- Delay para pumasok sa inventory ang item bago lumipat

    -- =========================================================================
    -- STEP 2: Instant Teleport kay Hideo at Simulan ang Minigame Gamit ang Prompt
    -- =========================================================================
    notify("Step 2/2", "Teleporting kay Hideo...", 2)
    humanoidRootPart.CFrame = CFrame.new(165.188, 7.533, 336.290)
    task.wait(0.5) -- Sandaling wait para mag-load ang NPC model

    local hideoPrompt = Workspace:FindFirstChild("Section2")
        and Workspace.Section2:FindFirstChild("NPC")
        and Workspace.Section2.NPC:FindFirstChild("Hideo3")
        and Workspace.Section2.NPC.Hideo3:FindFirstChild("HumanoidRootPart")
        and Workspace.Section2.NPC.Hideo3.HumanoidRootPart:FindFirstChild("ProximityPrompt")

    if hideoPrompt then
        notify("Interacting", "Minigame Started", 3)
        safeFirePrompt(hideoPrompt)
    else
        notify("Error", "Prompt of Hideo Not Found!", 3)
    end
end)

-- LOCKER & DIARY

createCustomButton("Section 2", "Locker & Diary", "Teleport to Locker, open it, and read the Diary", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Local function para sa malinis na notification sa gilid
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Helper function para sa ligtas na pag-fire ng ProximityPrompt (Anti-Cheat & Distance Bypass)
    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50 -- Tinaasan para abot kahit may harang
        task.wait(0.1)
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    -- =========================================================================
    -- STAGE 1: Teleport sa Locker at Buksan Ito
    -- =========================================================================
    notify("Stage 1/2", "Papunta na sa Locker...", 2)
    humanoidRootPart.CFrame = CFrame.new(143.386, 20.483, 503.915)
    task.wait(0.5) -- Sandaling wait para mag-sync ang posisyon sa lapag

    local lockerPrompt = Workspace:FindFirstChild("Section2")
        and Workspace.Section2:FindFirstChild("MAINOBJECTIVE")
        and Workspace.Section2.MAINOBJECTIVE:FindFirstChild("Locker")
        and Workspace.Section2.MAINOBJECTIVE.Locker:FindFirstChild("LockerDoor")
        and Workspace.Section2.MAINOBJECTIVE.Locker.LockerDoor:FindFirstChild("ProximityPart")
        and Workspace.Section2.MAINOBJECTIVE.Locker.LockerDoor.ProximityPart:FindFirstChild("ProximityPrompt")

    if lockerPrompt then
        safeFirePrompt(lockerPrompt)
        notify("Locker Success", "Nabuksan na ang Locker!", 1.5)
    else
        notify("Locker Warning", "Hindi mahanap ang Locker prompt! Nagpatuloy pa rin...", 2.5)
    end
    task.wait(1) -- Delay para matapos ang open animation ng locker bago lumipat sa diary

    -- =========================================================================
    -- STAGE 2: I-fire ang Red Diary Prompt (Awtomatikong pagbasa)
    -- =========================================================================
    notify("Stage 2/2", "Binabasa na ang Red Diary...", 2)
    
    local diaryPrompt = Workspace:FindFirstChild("Section2")
        and Workspace.Section2:FindFirstChild("MAINOBJECTIVE")
        and Workspace.Section2.MAINOBJECTIVE:FindFirstChild("Diary")
        and Workspace.Section2.MAINOBJECTIVE.Diary:FindFirstChild("ProximityPrompt")

    if diaryPrompt then
        -- Tandaan: Dahil nasa tabi lang ng Locker ang Diary ayon sa layunin ng game design, 
        -- hindi mo na kailangang mag-teleport ulit. I-fi-fire na agad ito ng safeFirePrompt gamit ang distance buffer.
        safeFirePrompt(diaryPrompt)
        notify("Mission Success", "Nabasa na ang Red Diary!", 3)
    else
        notify("Error", "Hindi mahanap ang Red Diary ProximityPrompt!", 3)
    end
end)

-- ====================================================================
-- UNIFIED TOGGLE: AKARI & AKARI RAGE ESP + INTEGRATED SAFE ZONE RADAR
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local akariConnection = nil
_G.RadarThreadActive = false -- Variable para kontrolin ang buhay ng radar loop

createToggle("Section 2", "Akari Box & Name ESP", "Highlights Akari/Rage and enables the 25-stud SafeZone radar", function(state)
    -- Kumuha o gumawa ng lalagyan sa CoreGui para sa mga visual elements
    local espContainer = CoreGui:FindFirstChild("IOHUB_AkariUnifiedContainer")
    if not espContainer then
        espContainer = Instance.new("Folder")
        espContainer.Name = "IOHUB_AkariUnifiedContainer"
        espContainer.Parent = CoreGui
    end

    -- Function para gumawa ng lilitaw na pangalan (Name Tag) sa ibabaw ng ulo
    local function applyNameTag(part, isRage)
        if not part or not part:IsA("BasePart") then return end
        
        local existingTagName = "Tag_" .. part.Name
        if espContainer:FindFirstChild(existingTagName) then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = existingTagName
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true -- Tagos pader sa mobile
        billboard.ExtentsOffset = Vector3.new(0, 4.5, 0)
        billboard.Adornee = part
        billboard.Parent = espContainer
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = isRage and "Akari (RAGE)" or "Akari"
        label.TextColor3 = isRage and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 0, 100)
        label.TextSize = 20
        label.Font = Enum.Font.SourceSansBold
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.Parent = billboard
    end

    -- Function para sa 3D Box gamit ang SELECTIONBOX (Mobile Wall-Hack Fixed)
    local function apply3DBox(part, isRage)
        if not part or not part:IsA("BasePart") then return end
        
        local existingBoxName = "Box_" .. part.Name
        if espContainer:FindFirstChild(existingBoxName) then return end
        
        local sBox = Instance.new("SelectionBox")
        sBox.Name = existingBoxName
        sBox.Color3 = isRage and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 0, 100) -- Pula kapag rage, pink kapag normal
        sBox.LineThickness = 0.08 -- Makapal na neon wireframe para tagos sa pader ng mobile
        sBox.Adornee = part
        sBox.Parent = espContainer
        
        applyNameTag(part, isRage)
    end

    -- Function para mag-scan ng gumagalaw o nag-i-invisible na Akari parts
    local function scanAkariParts(object)
        if not object or not object.Parent then return end
        
        -- Normal Form Check
        if object.Parent.Name == "Akari" then
            if object.Name == "Hitbox" or object.Name == "HumanoidRootPart" then
                apply3DBox(object, false)
            end
        end

        -- Rage Form Check
        if object.Parent.Name == "AkariRage" then
            if object.Name == "Hitbox" or object.Name == "HumanoidRootPart" then
                apply3DBox(object, true)
            end
        end
    end

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- =========================================================================
    -- STATE EVALUATION (ON / OFF SWITCHES)
    -- =========================================================================
    if state then
        -- ===== [TOGGLE ON] =====
        -- 1. Agarang i-scan ang map kung naka-spawn na sila ngayon
        local normalFolder = Workspace:FindFirstChild("Section2") and Workspace.Section2:FindFirstChild("Monster") and Workspace.Section2.Monster:FindFirstChild("Akari")
        local rageFolder = Workspace:FindFirstChild("Section2") and Workspace.Section2:FindFirstChild("Rage") and Workspace.Section2.Rage:FindFirstChild("AkariRage")

        if normalFolder then
            local hitbox = normalFolder:FindFirstChild("Hitbox")
            local hrp = normalFolder:FindFirstChild("HumanoidRootPart")
            if hitbox then apply3DBox(hitbox, false) end
            if hrp then apply3DBox(hrp, false) end
        end

        if rageFolder then
            local hitbox = rageFolder:FindFirstChild("Hitbox")
            local hrp = rageFolder:FindFirstChild("HumanoidRootPart")
            if hitbox then apply3DBox(hitbox, true) end
            if hrp then apply3DBox(hrp, true) end
        end

        -- 2. Makinig sa buong Workspace para sa mga biglang sumusulpot o nag-e-evaporate na parts
        if not akariConnection then
            akariConnection = Workspace.DescendantAdded:Connect(function(descendant)
                pcall(function()
                    if descendant:IsA("BasePart") then
                        scanAkariParts(descendant)
                    end
                end)
            end)
        end

        -- 3. INTEGRATED RADAR ENGINE (Dito magsisimulang mag-patrol ang radar kasabay ng ESP)
        if not _G.RadarThreadActive then
            _G.RadarThreadActive = true
            task.spawn(function()
                local safeZoneCFrame = CFrame.new(174.887, 9.931, 368.043)
                local safetyDistanceThreshold = 25 -- Selyadong 25 studs batay sa iyong timpla

                while _G.RadarThreadActive do
                    task.wait(0.15) -- Mabilis na calculation rate
                    
                    local character = player.Character
                    local currentHRP = character and character:FindFirstChild("HumanoidRootPart")
                    
                    -- Hanapin kung alin ang buhay na bersyon ni Akari sa laro
                    local normalAkari = Workspace:FindFirstChild("Section2") and Workspace.Section2:FindFirstChild("Monster") and Workspace.Section2.Monster:FindFirstChild("Akari")
                    local rageAkari = Workspace:FindFirstChild("Section2") and Workspace.Section2:FindFirstChild("Rage") and Workspace.Section2.Rage:FindFirstChild("AkariRage")
                    
                    local threatModel = normalAkari or rageAkari
                    local threatPart = threatModel and (threatModel:FindFirstChild("HumanoidRootPart") or threatModel:FindFirstChild("Hitbox"))
                    
                    if threatPart and currentHRP then
                        local distance = (currentHRP.Position - threatPart.Position).Magnitude
                        
                        -- Emergency Teleport Trigger
                        if distance <= safetyDistanceThreshold then
                            local threatName = (threatModel.Name == "AkariRage") and "Akari (RAGE)" or "Akari"
                            notify("🚨 DANGER DETECTED", threatName .. " is within " .. math.floor(distance) .. " studs! Teleporting to SafeZone!", 3)
                            currentHRP.CFrame = safeZoneCFrame
                            task.wait(2.5) -- Cooldown buffer to prevent teleport loops
                        end
                    end
                end
            end)
        end

        notify("IOHUB ACTIVE", "📦 ESP and 25-Stud SafeZone Radar: ON", 3)
    else
        -- ===== [TOGGLE OFF] =====
        -- 1. Patayin ang background detector connection
        if akariConnection then
            akariConnection:Disconnect()
            akariConnection = nil
        end
        
        -- 2. Patayin ang SafeZone Radar loop
        _G.RadarThreadActive = false
        
        -- 3. Linisin ang screen at burahin ang lahat ng SelectionBox at Name Tags
        if espContainer then
            espContainer:ClearAllChildren()
        end
        
        notify("IOHUB STATUS", "⚪ ESP and SafeZone Radar: OFF", 2)
    end
end)


-- ====================================================================
-- 2. AKARI SPIDER CORE CONFIGURATIONS & VARIABLES (CLEAN VERSION)
-- ====================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- Global variable para sa tracking ng cycle index (Sisimula sa 1)
_G.SpiderCycleIndex = _G.SpiderCycleIndex or 1

-- Listahan ng iyong 18 na eksaktong CFrame locations
local spiderLocations = {
    CFrame.new(90.27, 36.24, 500.86),
    CFrame.new(44.95, 17.89, 376.92),
    CFrame.new(201.31, 24.09, 489.89),
    CFrame.new(37.52, 9.47, 492.32),
    CFrame.new(55.52, 18.05, 322.65),
    CFrame.new(83.93, 30.91, 318.30),
    CFrame.new(99.93, 30.95, 355.79),
    CFrame.new(117.026154, 20.4570236, 353.80899, -0.924176574, 1.90810834e-09, -0.381965518, 7.46504525e-10, 1, 3.18930971e-09, 0.381965518, 2.66234634e-09, -0.924176574),
    CFrame.new(117.259613, 16.3596249, 353.677277, -0.917000473, 0, -0.398886144, 0, 1, -0, 0.398886144, 0, -0.917000473),
    CFrame.new(138.11, 5.07, 497.84),
    CFrame.new(284.40, 40.92, 377.39),
    CFrame.new(203.82, 11.14, 488.19),
    CFrame.new(117.73, 30.94, 466.65),
    CFrame.new(48.05, 40.97, 321.90),
    CFrame.new(193.45, 28.02, 343.29),
    CFrame.new(264.93, 30.92, 495.04),
    CFrame.new(286.90, 17.95, 379.96),
    CFrame.new(312.11, 24.13, 468.15)
}

local safeZoneCFrame = CFrame.new(174.887, 9.931, 368.043)

local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 2;
    })
end

-- =========================================================================
-- BUTTONS REGISTRATION
-- =========================================================================

-- BUTTON 1: SPIDER CYCLE (Pure Instant Teleportation)
createCustomButton("Section 2", "Cycle Akari Spiders", "Teleports through spider spots 1-18 sequentially", function()
    local currentCharacter = player.Character or player.CharacterAdded:Wait()
    local currentHRP = currentCharacter:WaitForChild("HumanoidRootPart")
    local currentHumanoid = currentCharacter:WaitForChild("Humanoid")
    
    local targetCFrame = spiderLocations[_G.SpiderCycleIndex]
    
    if targetCFrame then
        notify("Teleporting", "Going to AkariSpider [" .. _G.SpiderCycleIndex .. "/18]", 1.5)
        
        -- Bypass standard collision locking before moving
        pcall(function()
            currentHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
        task.wait(0.02)
        
        currentHRP.CFrame = targetCFrame
        
        if _G.SpiderCycleIndex >= #spiderLocations then
            _G.SpiderCycleIndex = 1
            notify("Cycle Reset", "Natapos ang lahat ng spots! Babalik sa Spider #1.", 2)
        else
            _G.SpiderCycleIndex = _G.SpiderCycleIndex + 1
        end
    else
        notify("Error", "May problema sa pagkuha ng CFrame index!", 3)
    end
end)

-- BUTTON 2: EMERGENCY STOP & SAFEZONE
createCustomButton("Section 2", "Emergency SafeZone", "Teleport to SafeZone and Stop Farming", function()
    local currentCharacter = player.Character or player.CharacterAdded:Wait()
    local currentHRP = currentCharacter:WaitForChild("HumanoidRootPart")

    _G.SpiderCycleIndex = 1 
    currentHRP.CFrame = safeZoneCFrame
    
    notify("🛑 FARM STOPPED", "Naka-teleport na sa SafeZone at nare-reset ang Spider Cycle!", 3)
end)




-- CONTACT IJO


createCustomButton("Section 3", "Contact Ijo Quest", "Teleport to Ijo, wait 3s, and back to SafeZone", function()
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Local function para sa malinis na notification sa gilid
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Ang iyong mga eksaktong CFrame coordinates
    local ijoCFrame = CFrame.new(-3392.948, 8.000, 763.995)
    local section3SafeZone = CFrame.new(-3584.720, 8.000, 247.522)

    -- =========================================================================
    -- STAGE 1: Teleport kay Contact Ijo
    -- =========================================================================
    notify("Stage 1/2", "Papunta na kay Contact Ijo...", 2)
    
    -- Bypass collision/physics locking bago lumipat
    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    task.wait(0.02)
    
    humanoidRootPart.CFrame = ijoCFrame

    -- =========================================================================
    -- STAGE 2: Maghintay ng 3 Segundo (Interaction/Quest trigger window)
    -- =========================================================================
    for i = 3, 1, -1 do
        notify("Waiting...", "Nasa tapat ni Ijo. Babalik sa SafeZone sa loob ng " .. i .. "s...", 1)
        task.wait(1)
    end

    -- =========================================================================
    -- STAGE 3: Awtomatikong Pagbalik sa SafeZone
    -- =========================================================================
    notify("Stage 2/2", "Bumabalik na sa SafeZone...", 1.5)
    
    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    task.wait(0.02)
    
    humanoidRootPart.CFrame = section3SafeZone
    notify("Mission Complete", "Naka-secure na sa SafeZone!", 3)
end)



local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local section3Connection = nil
_G.Section3RadarActive = false 

createToggle("Section 3", "Mizuno Box & Name ESP", "Highlights Mizuno and enables the 25-stud escape radar", function(state)
    -- Lumikha ng hiwalay na container sa CoreGui para sa Section 3 assets
    local espContainer = CoreGui:FindFirstChild("IOHUB_Section3Container")
    if not espContainer then
        espContainer = Instance.new("Folder")
        espContainer.Name = "IOHUB_Section3Container"
        espContainer.Parent = CoreGui
    end

    -- Function para gumawa ng ISANG lilitaw na pangalan (Name Tag) sa ibabaw ng ulo ni Mizuno
    local function applyNameTag(part)
        if not part or not part:IsA("BasePart") then return end
        
        -- KANDADO CHECK: Kung may umiiral nang pangalan para kay Mizuno sa folder, huwag nang mag-duplicate
        if espContainer:FindFirstChild("Tag_Mizuno_Single") then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "Tag_Mizuno_Single" -- Permanenteng iisang pangalan framework
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true -- Tagos pader sa mobile screen
        billboard.ExtentsOffset = Vector3.new(0, 4.5, 0)
        billboard.Adornee = part
        billboard.Parent = espContainer
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "Mizuno"
        label.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon Cyan Outline
        label.TextSize = 20
        label.Font = Enum.Font.SourceSansBold
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.Parent = billboard
    end

    -- Function para sa 3D Box gamit ang SelectionBox (Mobile Wall-Hack Fixed)
    local function apply3DBox(part)
        if not part or not part:IsA("BasePart") then return end
        local existingBoxName = "Box_" .. part.Name
        if espContainer:FindFirstChild(existingBoxName) then return end
        
        local sBox = Instance.new("SelectionBox")
        sBox.Name = existingBoxName
        sBox.Color3 = Color3.fromRGB(0, 255, 255) -- Neon Cyan Outline
        sBox.LineThickness = 0.08
        sBox.Adornee = part
        sBox.Parent = espContainer
    end

    -- Function para i-scan ang mga gumagalaw o nag-i-invisible na parts ni Mizuno
    local function scanSection3Parts(object)
        if not object or not object.Parent then return end
        
        if object.Parent.Name == "Mizuno" then
            -- 1. Kabitan ng SelectionBox wireframe ang parehong parts para sa kapal ng outlines
            if object.Name == "Hitbox" or object.Name == "HumanoidRootPart" then
                apply3DBox(object)
            end
            
            -- 2. TANGING SA HUMANOIDROOTPART LANG IKAKABIT ANG PANGALAN (Anti-Duplicate Filter)
            if object.Name == "HumanoidRootPart" then
                applyNameTag(object)
            -- Fallback backup kung biglang walang RootPart sa instance cache
            elseif object.Name == "Hitbox" and not espContainer:FindFirstChild("Tag_Mizuno_Single") then
                applyNameTag(object)
            end
        end
    end

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- =========================================================================
    -- STATE CONTROL (ON / OFF SWITCHES)
    -- =========================================================================
    if state then
        -- ===== [TOGGLE ON] =====
        -- 1. I-scan agad ang Workspace kung naka-render na si Mizuno sa simula
        local mizunoFolder = Workspace:FindFirstChild("Section3") 
            and Workspace.Section3:FindFirstChild("Monster") 
            and Workspace.Section3.Monster:FindFirstChild("Mizuno")

        if mizunoFolder then
            local hitbox = mizunoFolder:FindFirstChild("Hitbox")
            local hrp = mizunoFolder:FindFirstChild("HumanoidRootPart")
            
            if hitbox then apply3DBox(hitbox) end
            if hrp then 
                apply3DBox(hrp)
                applyNameTag(hrp) -- Unahing kabitan ng pangalan ang RootPart
            elseif hitbox then
                applyNameTag(hitbox) -- Backup target
            end
        end

        -- 2. Makinig gamit ang DescendantAdded para sa live tracking (Bypass invisible mechanism)
        if not section3Connection then
            section3Connection = Workspace.DescendantAdded:Connect(function(descendant)
                pcall(function()
                    if descendant:IsA("BasePart") then
                        scanSection3Parts(descendant)
                    end
                end)
            end)
        end

        -- 3. INTEGRATED RADAR ENGINE FOR MIZUNO (25 Studs Range Threshold Check)
        if not _G.Section3RadarActive then
            _G.Section3RadarActive = true
            task.spawn(function()
                local section3SafeZone = CFrame.new(-3584.720, 8.000, 247.522)
                local safetyDistanceThreshold = 25 

                while _G.Section3RadarActive do
                    task.wait(0.15)
                    
                    local character = player.Character
                    local currentHRP = character and character:FindFirstChild("HumanoidRootPart")
                    
                    local liveMizuno = Workspace:FindFirstChild("Section3") 
                        and Workspace.Section3:FindFirstChild("Monster") 
                        and Workspace.Section3.Monster:FindFirstChild("Mizuno")
                        
                    local threatPart = liveMizuno and (liveMizuno:FindFirstChild("HumanoidRootPart") or liveMizuno:FindFirstChild("Hitbox"))
                    
                    if threatPart and currentHRP then
                        local distance = (currentHRP.Position - threatPart.Position).Magnitude
                        
                        if distance <= safetyDistanceThreshold then
                            notify("🚨 MIZUNO DETECTED", "Mizuno is within " .. math.floor(distance) .. " studs! Teleporting to SafeZone!", 3)
                            currentHRP.CFrame = section3SafeZone
                            task.wait(2.5) 
                        end
                    end
                end
            end)
        end

        notify("IOHUB ACTIVE", "📦 Mizuno ESP and Section 3 Radar: ON", 3)
    else
        -- ===== [TOGGLE OFF] =====
        if section3Connection then
            section3Connection:Disconnect()
            section3Connection = nil
        end
        
        _G.Section3RadarActive = false
        
        if espContainer then
            espContainer:ClearAllChildren()
        end
        
        notify("IOHUB STATUS", "⚪ Mizuno ESP and Radar: OFF", 2)
    end
end)




createCustomButton("Section 3", "Restore Power Max-Speed", "Max-speed farm with fast cinematic multi-tween chain", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Local function for clean English side notifications
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Helper function for safe ProximityPrompt triggering
    local function safeFirePrompt(prompt)
        if prompt then
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 50
            task.wait(0.05)
            fireproximityprompt(prompt)
        end
        return true
    end

    -- Helper function to perform fast tweens with target speed (e.g. 250)
    local function fastTweenTo(targetCFrame, speed)
        local distance = (humanoidRootPart.Position - targetCFrame.Position).Magnitude
        local duration = distance / (speed or 250)
        
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Wait()
        task.wait(0.1) -- Small stabilization delay
    end

    -- Verify that the Circuits folder exists in Section 3
    local circuitsFolder = Workspace:FindFirstChild("Section3")
        and Workspace.Section3:FindFirstChild("OBJECTIVE")
        and Workspace.Section3.OBJECTIVE:FindFirstChild("Circuits")

    if not circuitsFolder then
        notify("Error", "Circuits folder not found in Section 3!", 4)
        return
    end

    -- Get the exact Cobalt module network event path
    local CobaltEvent = ReplicatedStorage:FindFirstChild("modules")
        and ReplicatedStorage.modules:FindFirstChild("Packet")
        and ReplicatedStorage.modules.Packet:FindFirstChild("Reliable")

    if not CobaltEvent then
        notify("Critical Error", "Cobalt Packet Remote Event path not found!", 4)
        return
    end

    -- List of your 6 exact circuit CFrame coordinates
    local circuitPositions = {
        CFrame.new(-3230.88599, 8.51531696, 681.428955, 0.948552489, 0, 0.316619992, 0, 1, 0, -0.316619992, 0, 0.948552489),
        CFrame.new(-3594.27295, 8.64291477, 786.69104, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247),
        CFrame.new(-3513.80835, 8.46253777, 554.146118, -0.949462295, 0, 0.313881457, 0, 1, 0, -0.313881457, 0, -0.949462295),
        CFrame.new(-3153.30762, 8.55415249, 484.829102, 0, 0, 1, 0, 1, -0, -1, 0, 0),
        CFrame.new(-3388.81348, 8.52897835, 582.247437, -1.1920929e-07, 0, 1.00000012, 0, 1, 0, -1.00000012, 0, -1.1920929e-07),
        CFrame.new(-3699.98584, 8.54430199, 618.209167, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
    }

    -- Sorter to find the closest prompt and model after teleporting
    local function getClosestCircuitPrompt()
        local closestPrompt = nil
        local closestCircuitModel = nil
        local shortestDistance = math.huge

        for _, obj in ipairs(circuitsFolder:GetChildren()) do
            local promptPart = obj:FindFirstChild("PromptPart")
            local prompt = promptPart and promptPart:FindFirstChildOfClass("ProximityPrompt")
            
            if prompt and promptPart then
                local distance = (humanoidRootPart.Position - promptPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPrompt = prompt
                    closestCircuitModel = obj
                end
            end
        end
        return closestPrompt, closestCircuitModel
    end

    notify("Farm Started", "Executing fast Cobalt sequence for all 6 circuits...", 3)

    -- Loop through each of the 6 coordinates
    for index, targetCFrame in ipairs(circuitPositions) do
        notify("Progress", "Teleporting to Circuit [" .. index .. "/6]...", 1)
        
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
        task.wait(0.01)
        
        humanoidRootPart.CFrame = targetCFrame
        task.wait(0.4) 

        local prompt, circuitModel = getClosestCircuitPrompt()

        if prompt and circuitModel then
            safeFirePrompt(prompt)
            task.wait(0.2) 

            for round = 1, 3 do
                CobaltEvent:FireServer("Section3/CircuitRoundComplete", circuitModel)
                task.wait(0.1) 
            end
            
            task.wait(0.4) 
        else
            notify("Warning", "Circuit prompt not found at Spot #" .. index, 1)
        end
    end

    -- =========================================================================
    -- TWEEN CHAIN & SEQUENCE WITH SPEED 250
    -- =========================================================================
    
    -- 1. Fast Tween to the First Final Destination (Cinematic Trigger)
    notify("Farm Finished", "Restored! Fast-gliding to trigger cinematic...", 2)
    local firstDest = CFrame.new(-3389.176, 8.000, 807.249)
    fastTweenTo(firstDest, 250)

    -- 2. Wait at least 25 seconds for the scene to process
    for i = 25, 1, -1 do
        notify("Cinematic Window", "Waiting for scene: " .. i .. "s remaining...", 1)
        task.wait(1)
    end

    -- 3. Fast Tween to the Door Unlock Trigger (No prompt needed)
    notify("Door Sequence", "Fast-gliding to auto-trigger door open...", 2)
    local doorDest = CFrame.new(-3389.251, 8.000, 761.373)
    fastTweenTo(doorDest, 250)
    
    -- Wait 1 second as requested for the door sequence to register
    task.wait(1)

    -- 4. Final Fast Tween to the End Point
    notify("Moving to End", "Gliding to final target location...", 2)
    local endDest = CFrame.new(-3392.523, 7.675, 890.753)
    fastTweenTo(endDest, 250)

    notify("Success", "All sequences and tweens executed successfully!", 4)
end)



createCustomButton("Section 4", "Auto Password", "Turn on Computer & Submit Password", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Local function for clean English side notifications
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Helper function for safe ProximityPrompt triggering (Anti-Cheat & Distance Bypass)
    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50
        task.wait(0.1)
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    -- Grab the verified Cobalt Module Event from your logs
    local CobaltEvent = ReplicatedStorage:FindFirstChild("modules")
        and ReplicatedStorage.modules:FindFirstChild("Packet")
        and ReplicatedStorage.modules.Packet:FindFirstChild("Reliable")

    if not CobaltEvent then
        notify("Critical Error", "Cobalt Packet Route not found!", 4)
        return
    end

    notify("Lab Quest Started", "Starting Section 4 Lab automation...", 3)

    -- =========================================================================
    -- STEP 1: Get ID Card
    -- =========================================================================
    notify("Step 1/5", "Teleporting to ID Card...", 1.5)
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    task.wait(0.02)
    humanoidRootPart.CFrame = CFrame.new(-3375.321, -299.782, 4686.612)
    task.wait(0.5)

    local idPrompt = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("Floor1")
        and Workspace.Section4.Lab.Floor1:FindFirstChild("Entrance")
        and Workspace.Section4.Lab.Floor1.Entrance:FindFirstChild("IDCARD")
        and Workspace.Section4.Lab.Floor1.Entrance.IDCARD:FindFirstChild("ProximityPrompt")

    if idPrompt then
        safeFirePrompt(idPrompt)
        notify("Success", "ID Card picked up!", 1.5)
    else
        notify("Warning", "ID Card prompt not found! Proceeding...", 2)
    end
    task.wait(1)

    -- =========================================================================
    -- STEP 2: Open Lab Gate
    -- =========================================================================
    notify("Step 2/5", "Teleporting to Lab Gate...", 1.5)
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    task.wait(0.02)
    humanoidRootPart.CFrame = CFrame.new(-3378.124, -300.218, 4662.547)
    task.wait(0.5)

    local gatePrompt = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("Floor1")
        and Workspace.Section4.Lab.Floor1:FindFirstChild("Entrance")
        and Workspace.Section4.Lab.Floor1.Entrance:FindFirstChild("SFXPart")
        and Workspace.Section4.Lab.Floor1.Entrance.SFXPart:FindFirstChild("ProximityPrompt")

    if gatePrompt then
        safeFirePrompt(gatePrompt)
        notify("Success", "Lab Gate opened!", 1.5)
    else
        notify("Warning", "Gate prompt not found! Proceeding...", 2)
    end
    task.wait(1)

    -- =========================================================================
    -- STEP 3: Activate Computer
    -- =========================================================================
    notify("Step 3/5", "Teleporting to Computer...", 1.5)
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    task.wait(0.02)
    humanoidRootPart.CFrame = CFrame.new(-3366.847, -299.855, 4473.751)
    task.wait(0.5)

    local compPrompt = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("Floor1")
        and Workspace.Section4.Lab.Floor1:FindFirstChild("Objective")
        and Workspace.Section4.Lab.Floor1.Objective:FindFirstChild("Computer")
        and Workspace.Section4.Lab.Floor1.Objective.Computer:FindFirstChild("PromptPart")
        and Workspace.Section4.Lab.Floor1.Objective.Computer.PromptPart:FindFirstChild("ProximityPrompt")

    if compPrompt then
        safeFirePrompt(compPrompt)
        notify("Success", "Computer activated!", 1.5)
    else
        notify("Warning", "Computer prompt not found! Proceeding...", 2)
    end
    task.wait(1)

    -- =========================================================================
    -- STEP 4: Scanning Dynamic Sticky Note Password (Zero Fallback Loop)
    -- =========================================================================
    notify("Step 4/5", "Scanning Sticky Note password...", 2)

    local scannedPassword = ""
    local attempts = 0

    while (scannedPassword == "" or scannedPassword == "nil") and attempts < 50 do
        attempts = attempts + 1
        
        local targetLabel = Workspace:FindFirstChild("Section4")
            and Workspace.Section4:FindFirstChild("Lab")
            and Workspace.Section4.Lab:FindFirstChild("Floor1")
            and Workspace.Section4.Lab.Floor1:FindFirstChild("Objective")
            and Workspace.Section4.Lab.Floor1.Objective:FindFirstChild("StickyNote")
            and Workspace.Section4.Lab.Floor1.Objective.StickyNote:FindFirstChild("PASSWORD")
            and Workspace.Section4.Lab.Floor1.Objective.StickyNote.PASSWORD:FindFirstChild("SurfaceGui")
            and Workspace.Section4.Lab.Floor1.Objective.StickyNote.PASSWORD.SurfaceGui:FindFirstChild("RandomNumber")

        if targetLabel and targetLabel:IsA("TextLabel") and targetLabel.Text ~= "" then
            scannedPassword = tostring(targetLabel.Text)
        else
            pcall(function()
                local note = Workspace.Section4.Lab.Floor1.Objective.StickyNote.PASSWORD
                local label = note:FindFirstChildWhichIsA("TextLabel", true) or note.SurfaceGui.RandomNumber
                if label.Text ~= "" then
                    scannedPassword = tostring(label.Text)
                end
            end)
        end
        
        if scannedPassword == "" or scannedPassword == "nil" then
            task.wait(0.1) -- Quick cache poll refresh rate
        end
    end

    if scannedPassword == "" or scannedPassword == "nil" then
        notify("Scan Fatal Error", "Sticky Note text data is empty or missing! Aborting.", 4)
        return
    end

    notify("Password Scanned", "Locked Code: " .. scannedPassword, 2)
    task.wait(0.5)

    -- =========================================================================
    -- STEP 5: Teleport to Laptop and Submit Scanned Key
    -- =========================================================================
    notify("Step 5/5", "Teleporting to Laptop...", 1.5)
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    task.wait(0.02)
    humanoidRootPart.CFrame = CFrame.new(-3423.193, -299.855, 4317.950)
    task.wait(0.5)

    local laptopPrompt = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("Floor1")
        and Workspace.Section4.Lab.Floor1:FindFirstChild("Objective2")
        and Workspace.Section4.Lab.Floor1.Objective2:FindFirstChild("Laptop")
        and Workspace.Section4.Lab.Floor1.Objective2.Laptop:FindFirstChild("CameraB")
        and Workspace.Section4.Lab.Floor1.Objective2.Laptop.CameraB:FindFirstChild("ProximityPrompt")

    if laptopPrompt then
        safeFirePrompt(laptopPrompt)
        task.wait(0.3)
    end

    -- Fire Cobalt Network Event using exclusively the live parsed code
    pcall(function()
        CobaltEvent:FireServer("Section4/LaptopSubmit", scannedPassword)
    end)

    notify("Mission Completed", "Live Password [" .. scannedPassword .. "] submitted via Cobalt!", 4)
end)

createCustomButton("Section 4", "Auto C4 Bomb Part 1", "Tween to the Plant Bomb Location", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Anti-Push Engine: I-glue ang player sa mismong pwesto habang nagpa-plant
    local function safeFirePromptWithLock(prompt, targetCFrame)
        if not prompt then return false end
        
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50 
        task.wait(0.05)
        
        local positionLockActive = true
        local lockConnection
        lockConnection = RunService.Heartbeat:Connect(function()
            if positionLockActive and humanoidRootPart then
                humanoidRootPart.CFrame = targetCFrame 
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Kanselahin ang kahit anong push velocity
            end
        end)
        
        fireproximityprompt(prompt)
        task.wait(0.6) -- Sapat na delay para pumasok ang "planted" flag sa server
        
        positionLockActive = false
        if lockConnection then lockConnection:Disconnect() end
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    local c4Folder = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("Floor1")
        and Workspace.Section4.Lab.Floor1:FindFirstChild("Objective2")
        and Workspace.Section4.Lab.Floor1.Objective2:FindFirstChild("C4Explode")

    if not c4Folder then
        notify("Error", "Objective 2 C4Explode folder not found!", 4)
        return
    end

    local bombLocations = {
        CFrame.new(-3769.42114, 9.41719055, 1785.24841, -0.0638350248, -0.153550684, -0.986076951, 0.960995257, -0.275895119, -0.0192491412, -0.269097805, -0.948843837, 0.165172935),
        CFrame.new(-3762.92212, 7.75848389, 1785.24731, -0.0613048077, 0.156747758, -0.985734344, 0.922661841, -0.367791295, -0.11586678, -0.380706191, -0.916602492, -0.122077942),
        CFrame.new(-3755.59741, 9.30319214, 1786.6167, 0.0614267588, 0.341856152, -0.937742591, 0.965879083, -0.257192612, -0.030490309, -0.251603723, -0.903872967, -0.345990181)
    }

    local function getClosestBombPrompt()
        local closestPrompt = nil
        local shortestDistance = math.huge
        for _, child in ipairs(c4Folder:GetChildren()) do
            local prompt = child:FindFirstChild("ProximityPrompt") or child:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                local targetPart = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true)
                if targetPart then
                    local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPrompt = prompt
                    end
                end
            end
        end
        return closestPrompt
    end

    notify("C4 Farm Started", "Gliding to plant 3 C4 charges...", 3)

    for index, targetCFrame in ipairs(bombLocations) do
        notify("Progress", "Moving to C4 Bomb [" .. index .. "/3]...", 1)
        
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        task.wait(0.01)
        humanoidRootPart.CFrame = targetCFrame
        task.wait(0.4)

        local targetPrompt = getClosestBombPrompt()
        if targetPrompt then
            safeFirePromptWithLock(targetPrompt, targetCFrame)
            notify("Success", "C4 Bomb #" .. index .. " planted!", 1.5)
            task.wait(0.5)
        else
            notify("Warning", "Prompt not found at spot #" .. index, 1.5)
        end
    end
    notify("Complete", "Part 1 C4 sequence finished!", 4)
end)


-- AUTO BOMB 2
createCustomButton("Section 4", "NEW Auto C4 Bomb Part 2", "Tweens to trigger zone, then glides and plants all 6 C4 bombs", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Local function for clean English side notifications
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Helper function to perform fast linear tweens (Speed 250) [INDEX]
    local function fastTweenTo(targetCFrame, speed)
        local distance = (humanoidRootPart.Position - targetCFrame.Position).Magnitude
        local duration = distance / (speed or 250)
        
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Wait()
        task.wait(0.1) -- Small stabilization delay
    end

    -- Anti-Push Engine: Solid position locking while planting to override physics push [INDEX]
    local function safeFirePromptWithLock(prompt, targetCFrame)
        if not prompt then return false end
        
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50 
        task.wait(0.05)
        
        local positionLockActive = true
        local lockConnection
        lockConnection = RunService.Heartbeat:Connect(function()
            if positionLockActive and humanoidRootPart then
                humanoidRootPart.CFrame = targetCFrame
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Freezes any back-push momentum [INDEX]
            end
        end)
        
        fireproximityprompt(prompt)
        task.wait(0.6) -- Selyadong delay for server verification
        
        positionLockActive = false
        if lockConnection then lockConnection:Disconnect() end
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    -- Verify Objective3 folder structure
    local c4Folder = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("Floor1")
        and Workspace.Section4.Lab.Floor1:FindFirstChild("Objective3")
        and Workspace.Section4.Lab.Floor1.Objective3:FindFirstChild("C4Explode")

    if not c4Folder then
        notify("Error", "Objective 3 C4Explode folder not found!", 4)
        return
    end

    -- List of your 6 exact C4 coordinates for Part 2 [INDEX]
    local bombLocations = {
        CFrame.new(-4157.10254, 105.468506, 2558.55908, 0.471192718, -0.882030427, -4.47034836e-07, 0.520008624, 0.277795196, 0.807725906, -0.712438583, -0.380594939, 0.589558363),
        CFrame.new(-4134.31836, 105.906746, 2559.43018, -0.270455718, 0.957155347, 0.103478529, 0.962732673, 0.268886626, 0.0290866606, 1.64434314e-05, 0.107488781, -0.994206667),
        CFrame.new(-4138.57861, 105.989746, 2560.04761, 6.31809235e-06, -0.487994879, 0.872846544, 0.439326972, 0.784103155, 0.438376665, -0.898327291, 0.38346225, 0.214394271),
        CFrame.new(-4155.60352, 106.140533, 2560.84473, -1.74119596e-05, -0.497882396, 0.867244542, 0.862882018, 0.438302547, 0.251645476, -0.505405366, 0.74833411, 0.42960614),
        CFrame.new(-4155.63086, 106.16626, 2556.65723, -1.56164169e-05, -0.141795546, -0.989896059, 0.890161276, 0.451039791, -0.0646223128, 0.45564571, -0.881168008, 0.126213849),
        CFrame.new(-4136.11768, 105.973389, 2556.3894, 3.439188e-05, -0.0692999065, -0.997595787, 0.983783007, 0.178933501, -0.0123960674, 0.179362267, -0.981417537, 0.06818223)
    }

    local function getClosestBombPrompt()
        local closestPrompt = nil
        local shortestDistance = math.huge
        for _, child in ipairs(c4Folder:GetChildren()) do
            local prompt = child:FindFirstChild("ProximityPrompt") or child:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                local targetPart = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true)
                if targetPart then
                    local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPrompt = prompt
                    end
                end
            end
        end
        return closestPrompt
    end

    -- =========================================================================
    -- HAKBANG A: TWEEN MUNA SA INITIAL TRANSITION ZONE (SPEED 250) [INDEX]
    -- =========================================================================
    notify("Stage 1/2", "Gliding to initial cinematic/area trigger zone...", 2)
    local transitionZone = CFrame.new(-4146.615, 106.991, 2298.599)
    fastTweenTo(transitionZone, 250)
    task.wait(0.6) -- Sapat na wait buffer para siguradong loaded ang kwarto bago mag-plant [INDEX]

    -- =========================================================================
    -- HAKBANG B: TWEEN AND PLANT ALL 6 BOMBS SEQUENTIALLY
    -- =========================================================================
    notify("Stage 2/2", "Area triggered! Gliding to plant 6 C4 charges...", 3)

    for index, targetCFrame in ipairs(bombLocations) do
        notify("Progress", "Tweening to C4 Bomb [" .. index .. "/6]...", 1)
        fastTweenTo(targetCFrame, 250) [INDEX]
        task.wait(0.3) -- Sync cooldown

        local targetPrompt = getClosestBombPrompt()
        if targetPrompt then
            safeFirePromptWithLock(targetPrompt, targetCFrame) [INDEX]
            notify("Success", "C4 Bomb #" .. index .. " planted perfectly!", 1.5)
            task.wait(0.5)
        else
            notify("Warning", "Prompt not found at spot #" .. index, 1.5)
        end
    end

    notify("Complete", "Part 2 C4 sequence fully cleared!", 4)
end)



createCustomButton("Section 4", "Auto Valve & Terminal", "Automatically Fix Valve and Terminal", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Local function for clean English side notifications
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Helper function for safe ProximityPrompt triggering (Anti-Cheat & Distance Bypass)
    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50
        task.wait(0.05) -- Fast mobile registration window
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    -- Get Cobalt module event path from your logs
    local CobaltEvent = ReplicatedStorage:FindFirstChild("modules")
        and ReplicatedStorage.modules:FindFirstChild("Packet")
        and ReplicatedStorage.modules.Packet:FindFirstChild("Reliable")

    if not CobaltEvent then
        notify("Critical Error", "Cobalt Packet route not found!", 4)
        return
    end

    -- Core Objective Folder Path
    local cleanseFolder = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("CleanseRoomObjective")

    if not cleanseFolder then
        notify("Critical Error", "CleanseRoomObjective folder not found!", 4)
        return
    end

    -- =========================================================================
    -- PHASE 1: DYNAMIC VALVES SCANNING ENGINE (ALL TURNERS CAPTURED FIRST)
    -- =========================================================================
    notify("Phase 1/2", "Scanning all available Valve models directly...", 2)
    task.wait(0.2)

    local valvesFolder = cleanseFolder:FindFirstChild("Valves")
    if valvesFolder then
        -- Dynamic folder mapping system instead of text label reading
        local valveModelsList = valvesFolder:GetChildren()
        notify("Valves Scan", "Found " .. tostring(#valveModelsList) .. " Valve models to clear.", 2.5)

        for index, valveModel in ipairs(valveModelsList) do
            if valveModel:IsA("Model") then
                notify("Valve Farm", "Processing: " .. valveModel.Name, 1.5)
                
                pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                task.wait(0.01)
                
                -- Teleport directly to the current valve model's core pivot
                humanoidRootPart.CFrame = valveModel:GetPivot()
                task.wait(0.6) -- Mobile streaming positioning buffer

                -- Polling network loop to ensure absolutely ZERO active turners are left behind
                local allPromptsCleared = false
                while not allPromptsCleared do
                    local foundActivePrompt = false
                    
                    -- Dynamic broad descendant scan across the entire Valve structural hierarchy
                    for _, descendant in ipairs(valveModel:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                            foundActivePrompt = true
                            safeFirePrompt(descendant)
                            task.wait(0.15) -- High-frequency loop spam interval
                        end
                    end
                    
                    -- Abort loop only when the current specific model yields 0 active indicators
                    if not foundActivePrompt then
                        allPromptsCleared = true
                    end
                    task.wait(0.1)
                end
                
                notify("Valve Clear", valveModel.Name .. " is fully cleared!", 1.5)
                task.wait(0.4) -- Cool down breathing frame before next model migration
            end
        end
    end

    -- =========================================================================
    -- PHASE 2: DYNAMIC CONTROL TERMINALS SYSTEM (FOLDER BLOCK LOADER ENGINE)
    -- =========================================================================
    notify("Phase 2/2", "All valves cleared! Initializing Terminals scan...", 2)
    task.wait(0.2)

    local shapeTerminalsFolder = cleanseFolder:FindFirstChild("ShapeTerminals")
    if shapeTerminalsFolder then
        -- Dynamic indexing collector mapping out duplicates with same model name structures
        local terminalsList = shapeTerminalsFolder:GetChildren()
        notify("Terminals Scan", "Found " .. tostring(#terminalsList) .. " Terminal blocks to automate.", 2.5)
        
        for index, terminalModel in ipairs(terminalsList) do
            if terminalModel:IsA("Model") then
                local promptPart = terminalModel:FindFirstChild("PromptPart")
                local terminalPrompt = promptPart and promptPart:FindFirstChildOfClass("ProximityPrompt")

                if terminalPrompt then
                    notify("Terminal Farm", "Moving to Terminal spot #" .. index, 1.5)
                    
                    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                    task.wait(0.01)
                    
                    -- Pivot snapping directly into current index structure coordinates
                    humanoidRootPart.CFrame = terminalModel:GetPivot()
                    task.wait(0.6)

                    -- Trigger initial interaction state channel hook
                    safeFirePrompt(terminalPrompt)
                    task.wait(0.4)

                    -- Execute exact Cobalt 2-round puzzle bypass sequences
                    for round = 1, 2 do
                        notify("Bypassing", "Terminal #" .. index .. " - Puzzle Round (" .. round .. "/2)", 1)
                        CobaltEvent:FireServer("ShapeTerminal/RoundComplete", terminalModel)
                        task.wait(0.3) -- Stable processing buffer ticks
                    end
                    
                    notify("Terminal Clear", "Completed all puzzles on Terminal #" .. index, 1.5)
                    task.wait(0.5)
                end
            end
        end
    end

    notify("Quest Finished", "All Cleanse Room objectives have been successfully automated!", 4)
end)

-- ESP HOGO

local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local hogoConnection = nil
_G.HogoRadarActive = false -- Hiwalay na loop switch para sa radar ng Section 4

createToggle("Section 4", "HOGO Esp & Auto Safe Zone", "Show HOGO Location &, 25 Studs Safe Zone Detection", function(state)
    -- Kumuha o gumawa ng lalagyan sa CoreGui para sa mga visual elements
    local espContainer = CoreGui:FindFirstChild("IOHUB_HogoFixedContainer")
    if not espContainer then
        espContainer = Instance.new("Folder")
        espContainer.Name = "IOHUB_HogoFixedContainer"
        espContainer.Parent = CoreGui
    end

    -- Function para gumawa ng lilitaw na pangalan (Name Tag) sa ibabaw ng ulo
    local function applyHogoNameTag(part)
        if not part or not part:IsA("BasePart") then return end
        
        -- Anti-Duplicate Filter: Isang pangalan lamang ang lulutang
        local existingTagName = "Tag_" .. part.Name
        if espContainer:FindFirstChild(existingTagName) then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = existingTagName
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true -- Tagos pader sa mobile screen [INDEX]
        billboard.ExtentsOffset = Vector3.new(0, 4.5, 0) -- Lumulutang nang maayos sa ulunan
        billboard.Adornee = part -- Permanenteng nakakabit sa part ng monster [INDEX]
        billboard.Parent = espContainer
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "Hogo Guntai"
        label.TextColor3 = Color3.fromRGB(255, 140, 0) -- Warning Orange
        label.TextSize = 20
        label.Font = Enum.Font.SourceSansBold
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.Parent = billboard
    end

    -- Function para sa 3D Box gamit ang SELECTIONBOX (Mobile Screen-Sync Fixed)
    local function apply3DBox(part)
        if not part or not part:IsA("BasePart") then return end
        
        local existingBoxName = "Box_" .. part.Name
        if espContainer:FindFirstChild(existingBoxName) then return end
        
        local sBox = Instance.new("SelectionBox")
        sBox.Name = existingBoxName
        sBox.Color3 = Color3.fromRGB(255, 140, 0) -- Neon Warning Orange Outline [INDEX]
        sBox.LineThickness = 0.08 -- Makapal na guhit para sa mobile devices [INDEX]
        sBox.Adornee = part -- Nakakabit nang direkta para walang lag sa pagsunod [INDEX]
        sBox.Parent = espContainer
    end

    -- Function para i-scan ang mga gumagalaw o nag-i-invisible na parts ni HogoGuntai
    local function scanHogoParts(object)
        if not object or not object.Parent then return end
        
        if object.Parent.Name == "HogoGuntai" then
            -- Balutin ng neon lines ang Hitbox at RootPart para sa magandang outlines
            if object.Name == "Hitbox" or object.Name == "HumanoidRootPart" then
                apply3DBox(object)
            end
            
            -- Tanging sa HumanoidRootPart lang ikakabit ang name tag para hindi maiwan [INDEX]
            if object.Name == "HumanoidRootPart" then
                applyHogoNameTag(object)
            -- Backup check kung sakaling mag-load delay ang RootPart
            elseif object.Name == "Hitbox" and not espContainer:FindFirstChild("Tag_HumanoidRootPart") then
                applyHogoNameTag(object)
            end
        end
    end

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- =========================================================================
    -- STATE CONTROL (ON / OFF SWITCHES)
    -- =========================================================================
    if state then
        -- ===== [TOGGLE ON] =====
        -- 1. I-scan agad ang Workspace kung naka-render na si HogoGuntai sa simula
        local monsterFolder = Workspace:FindFirstChild("Section4")
            and Workspace.Section4:FindFirstChild("Monster")
            and Workspace.Section4.Monster:FindFirstChild("HogoGuntai")

        if monsterFolder then
            local hitbox = monsterFolder:FindFirstChild("Hitbox")
            local hrp = monsterFolder:FindFirstChild("HumanoidRootPart")
            
            if hitbox then apply3DBox(hitbox) end
            if hrp then 
                apply3DBox(hrp)
                applyHogoNameTag(hrp)
            elseif hitbox then
                applyNameTag(hitbox)
            end
        end

        -- 2. Makinig gamit ang DescendantAdded para sa live tracking (Bypass invisible mechanism) [INDEX]
        if not hogoConnection then
            hogoConnection = Workspace.DescendantAdded:Connect(function(descendant)
                pcall(function()
                    if descendant:IsA("BasePart") then
                        scanHogoParts(descendant)
                    end
                end)
            end)
        end

        -- 3. INTEGRATED DEFENSIVE RADAR ENGINE (25-Stud Radius Escape Window)
        if not _G.HogoRadarActive then
            _G.HogoRadarActive = true
            task.spawn(function()
                local safeZoneCFrame = CFrame.new(-3365.168, -299.581, 4519.279)
                local safetyDistanceThreshold = 25 -- Selyadong 25 studs range check [INDEX]

                while _G.HogoRadarActive do
                    task.wait(0.15) -- Mabilis na scan tick rate
                    
                    local character = player.Character
                    local currentHRP = character and character:FindFirstChild("HumanoidRootPart")
                    
                    local activeBoss = Workspace:FindFirstChild("Section4")
                        and Workspace.Section4:FindFirstChild("Monster")
                        and Workspace.Section4.Monster:FindFirstChild("HogoGuntai")
                        
                    local threatPart = activeBoss and (activeBoss:FindFirstChild("HumanoidRootPart") or activeBoss:FindFirstChild("Hitbox"))
                    
                    if threatPart and currentHRP then
                        local distance = (currentHRP.Position - threatPart.Position).Magnitude
                        
                        -- Emergency Escape Trigger Window
                        if distance <= safetyDistanceThreshold then
                            notify("🚨 MONSTER APPROACHING", "HogoGuntai is within " .. math.floor(distance) .. " studs! Relocating to SafeZone...", 3)
                            currentHRP.CFrame = safeZoneCFrame
                            task.wait(2.5) -- Loop freeze cool down protection
                        end
                    end
                end
            end)
        end

        notify("IOHUB ACTIVE", "👁️ HogoGuntai ESP and 25-Stud Radar: ON", 3)
    else
        -- ===== [TOGGLE OFF] =====
        -- 1. Putulin ang background descendant connection
        if hogoConnection then
            hogoConnection:Disconnect()
            hogoConnection = nil
        end
        
        -- 2. Patayin ang SafeZone Radar loop para sa Section 4
        _G.HogoRadarActive = false
        
        -- 3. Linisin ang screen at burahin ang lahat ng SelectionBox at Name Tags ni HogoGuntai
        if espContainer then
            espContainer:ClearAllChildren()
        end
        
        notify("IOHUB STATUS", "⚪ HogoGuntai ESP and Radar: OFF", 2)
    end
end)




createCustomButton("Settings", "DayTime/Morning", "Leave to the Darkness", function()
    local lighting = game:GetService("Lighting")
    
    pcall(function()
        -- 1. I-set ang oras sa tanghali
        lighting.ClockTime = 14
        lighting.Brightness = 3
        lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        lighting.Ambient = Color3.fromRGB(150, 150, 150)
        lighting.GlobalShadows = false
        
        -- 2. Tanggalin o i-neutralize ang Atmosphere (pula/maulap na epekto)
        for _, child in ipairs(lighting:GetChildren()) do
            if child:IsA("Atmosphere") then
                -- Gawing transparent o alisin ang density at kulay ng ulap
                child.Density = 0
                child.Haze = 0
                child.Color = Color3.fromRGB(255, 255, 255)
                child.Decay = Color3.fromRGB(255, 255, 255)
            elseif child:IsA("ColorCorrectionEffect") then
                -- Alisin ang tint o redness
                child.TintColor = Color3.fromRGB(255, 255, 255)
                child.Saturation = 0.1
                child.Contrast = 0.1
            elseif child:IsA("Sky") then
                -- Opsyonal: Pwedeng tanggalin o hayaan, pero mas maganda kung babaguhin ang lighting properties
                child.StarCount = 0
            elseif child:IsA("PointLight") or child:IsA("SpotLight") then
                child.Brightness = 5
                child.Range = 60
            end
        end
    end)
    
    notify("Settings Updated", "The DayTime Morning Activated", 2.5)
end)





switchTab("Section 1")

