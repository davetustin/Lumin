--!strict
-- LightService.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Manages the spawning, movement, and detection logic for all light sources in the game.
-- This service integrates with the GameService to activate/deactivate lights based on game state.

local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local BaseService = require(Core:WaitForChild("BaseService"))
local Logger = require(Core:WaitForChild("Logger"))
local GlobalRegistry = require(Core:WaitForChild("GlobalRegistry"))
local Constants = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Constants"))

-- Get Roblox services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris") -- Useful for cleaning up temporary objects

-- Define game states (mirroring GameService for consistent comparison)
-- Ideally, these would be in Constants.lua for true shared access.
local GAME_STATE = {
    LOBBY = "Lobby",
    PLAYING = "Playing",
    ROUND_END = "RoundEnd",
    INTERMISSION = "Intermission",
    SHUTDOWN = "Shutdown"
}

-- Create LightService class that inherits from BaseService
local LightService = {}
LightService.__index = LightService
setmetatable(LightService, {__index = BaseService})

-- Internal table to keep track of active light sources
local activeLights = {}
local lightUpdateConnection = nil
local detectedPlayers = {} -- Table to track players currently detected by light for duration check

-- Constructor
function LightService.new()
    local self = BaseService.new("LightService")
    setmetatable(self, LightService)
    return self
end

-- --- Helper Functions for Light Management ---

-- Creates a basic Security Drone model (placeholder)
-- Now accepts a CFrame to position the drone relative to it
local function createSecurityDrone(relativeCFrame: CFrame): Part
    local drone = Instance.new("Part")
    drone.Name = "SecurityDrone"
    drone.Shape = Enum.PartType.Ball
    drone.Size = Vector3.new(2, 2, 2)
    
    -- Position the drone relative to the provided CFrame (e.g., player's CFrame)
    -- 5 studs up, 15 studs in front of the relativeCFrame's look vector
    drone.CFrame = relativeCFrame * CFrame.new(0, 5, -15) 
    
    drone.Anchored = true -- Set to true so it floats and is moved purely by script
    drone.CanCollide = false -- Set to false so players pass through it
    drone.Transparency = 0.5
    drone.BrickColor = BrickColor.new("Really black")
    drone.Parent = workspace -- Or a dedicated 'Lights' folder in workspace

    local spotlight = Instance.new("SpotLight")
    spotlight.Name = "DroneSpotlight"
    spotlight.Brightness = 5
    spotlight.Color = Color3.new(1, 1, 0) -- Yellow light
    spotlight.Range = Constants.DRONE_LIGHT_RANGE
    spotlight.Face = Enum.NormalId.Front
    spotlight.Angle = Constants.DRONE_LIGHT_ANGLE
    spotlight.Parent = drone

    -- Attach a ProximityPrompt for future interaction (e.g., hacking)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Hack"
    prompt.ObjectText = "Security Drone"
    prompt.Parent = drone

    return drone
end

-- Placeholder for light movement logic (e.g., linear path)
local function moveLight(lightPart: Part, deltaTime: number)
    -- Simple linear movement back and forth along the X-axis for demonstration
    -- This uses attributes to store direction, allowing the part to persist state
    local minX = -50
    local maxX = 50
    local currentDir = lightPart:GetAttribute("Direction") or 1 -- 1 for positive, -1 for negative

    local currentCFrame = lightPart.CFrame
    local newXPosition

    if currentDir == 1 then
        newXPosition = currentCFrame.X + Constants.DRONE_SPEED * deltaTime
        if newXPosition >= maxX then
            newXPosition = maxX -- Cap at max
            lightPart:SetAttribute("Direction", -1)
        end
    else
        newXPosition = currentCFrame.X - Constants.DRONE_SPEED * deltaTime
        if newXPosition <= minX then
            newXPosition = minX -- Cap at min
            lightPart:SetAttribute("Direction", 1)
        end
    end
    -- Update CFrame to maintain its height and orientation
    lightPart.CFrame = CFrame.new(newXPosition, currentCFrame.Y, currentCFrame.Z) * currentCFrame.Rotation
end

-- Checks if a player is within a light's detection cone
local function isPlayerInLight(player: Player, lightPart: Part, lightSource: SpotLight): boolean
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local playerRoot = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not playerRoot then
        return false
    end

    local lightCFrame = lightPart.CFrame
    local lightPosition = lightCFrame.Position
    local lightDirection = lightCFrame.LookVector

    local toPlayer = playerRoot.Position - lightPosition
    local distance = toPlayer.Magnitude

    if distance > lightSource.Range then
        return false -- Player is too far
    end

    local angle = math.deg(math.acos(toPlayer.Unit:Dot(lightDirection)))
    if angle > lightSource.Angle / 2 then
        return false -- Player is outside the light cone angle
    end

    -- Raycast from player's root part towards the light source
    local rayOrigin = playerRoot.Position
    local rayDirection = lightPosition - rayOrigin -- Direction from player to light
    local rayLength = rayDirection.Magnitude
    rayDirection = rayDirection.Unit -- Normalize direction

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    -- Exclude the player's character from the raycast, but allow it to hit the lightPart
    rayParams.FilterDescendantsInstances = {character} 
    
    local rayResult = workspace:Raycast(rayOrigin, rayDirection * rayLength, rayParams)

    -- If the ray hits something, check if it hit the lightPart
    if rayResult and rayResult.Instance then
        -- Check if the hit part is the drone itself
        if rayResult.Instance == lightPart or rayResult.Instance.Parent == lightPart then
            return true -- Player has line of sight to the light
        end
    end

    return false -- Player is either not in cone, or an obstruction was found
end

-- --- Service Methods ---

-- Override Init method from BaseService
function LightService:Init(services: {[string]: any})
    BaseService.Init(self, services)
    -- Removed the redundant "LightService: Initializing." DEBUG log here, as BaseService already logs "initializing..."

    -- Store GameService reference for elimination calls
    self.Services = services -- Store all services for dependency access
    if not self.Services.GameService then
        self.Logger.Fatal("LightService requires GameService but it was not provided.", self.Name)
        error("Missing GameService dependency")
    end

    -- Corrected: Listen for GameState changes via GlobalRegistry.OnValueChanged
    GlobalRegistry.OnValueChanged:Connect(function(key: string, value: any, oldValue: any?)
        if key == "GameState" then
            self:OnGameStateChanged(value) -- Pass the new state (value)
        end
    end)

    self.Logger.Info("LightService initialized successfully.", self.Name) -- New INFO log for completion
end

-- Override Start method from BaseService
function LightService:Start()
    BaseService.Start(self)
    -- Removed: self.Logger.Info("LightService: Starting.", self.Name) -- Removed duplicate INFO log
    -- Removed: Initial check for game state in case LightService starts after GameService has already set a state
    -- self:OnGameStateChanged(GlobalRegistry.Get("GameState", GAME_STATE.LOBBY)) -- This call caused the duplicate
end

-- Override Shutdown method from BaseService
function LightService:Shutdown()
    BaseService.Shutdown(self)
    self.Logger.Info("LightService: Shutting down.", self.Name)
    self:StopLightUpdates()
    self:ClearAllLights()
    detectedPlayers = {} -- Clear detected players on shutdown
end

-- Spawns initial lights for a round
function LightService:SpawnLights()
    self.Logger.Info("Spawning lights for the round.", self.Name)
    -- Clear any existing lights first to prevent duplicates
    self:ClearAllLights()

    -- Get the first player's CFrame to position the drone relative to them
    local playerCFrame = CFrame.new(0, 5, 0) -- Default if no player found
    local playersInGame = Players:GetPlayers()
    if #playersInGame > 0 and playersInGame[1].Character and playersInGame[1].Character:FindFirstChild("HumanoidRootPart") then
        playerCFrame = playersInGame[1].Character.HumanoidRootPart.CFrame
    end

    -- Example: Spawn a single security drone relative to the player
    local drone = createSecurityDrone(playerCFrame)
    table.insert(activeLights, drone)
    
    -- Debug log to check the drone's actual spawn height
    self.Logger.Debug(string.format("Drone spawned at Y: %.2f (relative to player Y: %.2f)", drone.CFrame.Y, playerCFrame.Y), self.Name)

    -- Future: Read light configurations from level data
end

-- Clears all active lights from the workspace
function LightService:ClearAllLights()
    self.Logger.Info("Clearing all active lights.", self.Name)
    for _, lightPart in ipairs(activeLights) do
        if lightPart and lightPart.Parent then
            Debris:AddItem(lightPart, 0.1) -- Add to debris for clean removal
        end
    end
    activeLights = {}
    detectedPlayers = {} -- Clear detected players when lights are cleared
end

-- Starts the heartbeat for light movement and detection
function LightService:StartLightUpdates()
    if lightUpdateConnection then
        self.Logger.Warn("Light updates already running.", self.Name)
        return
    end
    self.Logger.Info("Starting light updates (movement and detection).", self.Name)
    lightUpdateConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
        -- Move all active lights
        for _, lightPart in ipairs(activeLights) do
            moveLight(lightPart, deltaTime)
        end

        -- Check for players in light after moving lights
        for _, player in ipairs(Players:GetPlayers()) do
            local isCurrentlyInLight = false
            for _, lightPart in ipairs(activeLights) do
                local spotlight = lightPart:FindFirstChildOfClass("SpotLight")
                if spotlight and isPlayerInLight(player, lightPart, spotlight) then
                    isCurrentlyInLight = true
                    break -- Player is in at least one light
                end
            end

            if isCurrentlyInLight then
                -- Player is in light, start/continue detection timer
                detectedPlayers[player.UserId] = (detectedPlayers[player.UserId] or 0) + deltaTime
                if detectedPlayers[player.UserId] >= Constants.LIGHT_DETECTION_DURATION then
                    -- Removed overly verbose debug log: self.Logger.Debug(string.format("Player '%s' detected by light for %.2f seconds! Triggering elimination.", player.Name, detectedPlayers[player.UserId]), self.Name)
                    -- Trigger player elimination logic
                    self.Services.GameService:EliminatePlayer(player, "Caught by light")
                    detectedPlayers[player.UserId] = nil -- Reset timer after elimination
                end
            else
                -- Player is not in light, reset their detection timer
                if detectedPlayers[player.UserId] then
                    -- Removed overly verbose debug log: self.Logger.Debug(string.format("Player '%s' left light. Resetting detection timer.", player.Name), self.Name)
                    detectedPlayers[player.UserId] = nil
                end
            end
        end
    end)
end

-- Stops the heartbeat for light movement and detection
function LightService:StopLightUpdates()
    if lightUpdateConnection then
        self.Logger.Info("Stopping light updates.", self.Name)
        lightUpdateConnection:Disconnect()
        lightUpdateConnection = nil
        detectedPlayers = {} -- Clear detected players when updates stop
    end
end

-- Handles game state changes
function LightService:OnGameStateChanged(newState: string)
    self.Logger.Info(string.format("LightService reacting to GameState change: %s", newState), self.Name)
    if newState == GAME_STATE.PLAYING then
        self:SpawnLights()
        self:StartLightUpdates()
    elseif newState == GAME_STATE.ROUND_END or newState == GAME_STATE.INTERMISSION then
        self:StopLightUpdates()
        self:ClearAllLights()
    end
end

return LightService
