-- [[ IOHUB AUTOMATIC PLACE ROUTER / BOOTSTRAPPER ]]
local player = game:GetService("Players").LocalPlayer
local starterGui = game:GetService("StarterGui")

-- Helper function para sa notif sa gilid para alam mong naglo-load ang script
local function sendBootNotif(title, text)
    pcall(function()
        starterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
end

-- Kunin ang kasalukuyang IDs ng server
local currentPlaceId = game.PlaceId
local currentGameId = game.GameId

print("🔍 Checking Game Identity...")
print("📍 Place ID: " .. tostring(currentPlaceId))
print("🆔 Game ID (Universe ID): " .. tostring(currentGameId))

-- [[ ROUTING / FILTERING LOGIC ]]

-- 1. HOME / LOBBY ROUTER
-- Gagana kapag ang Place ID ay tumugma sa 6243699076
if currentPlaceId == 6243699076 then
    sendBootNotif("IOHUB Loader", "🏡 Home/Lobby detected! Loading Main script...")
    task.wait(0.5)
    
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Moymoy21/IYONGOFFICIAL/refs/heads/main/TheMimicMain.lua"))()
    end)
    
    if not success then
        sendBootNotif("Loader Error", "❌ Failed to fetch Main script from GitHub!")
        print("❌ Loadstring Error: " .. tostring(err))
    end

-- 2. BOOK 2 CHAPTER 4 ROUTER
-- Tandaan: Dahil ang '96354063422506' ay masyadong mahaba, malamang ito ang GAME ID (Universe ID) 
-- kaya chineck natin ang parehong PlaceId at GameId para siguradong papasok ito.
elseif currentPlaceId == 96354063422506 or currentGameId == 96354063422506 then
    sendBootNotif("IOHUB Loader", "📖 Book 2 Chapter 4 detected! Loading B2C4 script...")
    task.wait(0.5)
    
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Moymoy21/IYONGOFFICIAL/refs/heads/main/B2C4.lua"))()
    end)
    
    if not success then
        sendBootNotif("Loader Error", "❌ Failed to fetch B2C4 script from GitHub!")
        print("❌ Loadstring Error: " .. tostring(err))
    end

-- 3. FALLBACK (KAPAG NASA IBANG MAPA KA)
else
    sendBootNotif("IOHUB Loader", "⚠️ Unsupported Map! Place ID: " .. tostring(currentPlaceId))
    print("⚠️ Warning: Walang naka-assign na script para sa Place ID na ito.")
end

