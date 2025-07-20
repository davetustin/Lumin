--!strict
-- GameService.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Manages the overall game state, rounds, and player lifecycle.
-- This service orchestrates the main game loop, transitioning between phases
-- like Lobby, Playing, and RoundEnd.

local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local BaseService = require(Core:WaitForChild("BaseService"))
local Logger = require(Core:WaitForChild("Logger"))
local GlobalRegistry = require(Core:WaitForChild("GlobalRegistry"))
local Constants = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Constants"))

-- Get Roblox services
local Players = game:GetService("Players")
-- local TeleportService = game:GetService("TeleportService") -- Not directly used for simple respawn, but good to keep in mind for future

-- Define game states (for GlobalRegistry)
local GAME_STATE = {
    LOBBY = "Lobby",
    PLAYING = "Playing",
    ROUND_END = "RoundEnd",
    INTERMISSION = "Intermission",
    SHUTDOWN = "Shutdown"
}

-- Create GameService class that inherits from BaseService
local GameService = {}
GameService.__index = GameService
setmetatable(GameService, {__index = BaseService})

-- Internal table to track players currently in the round (not eliminated)
local playersInRound = {}
local roundTimerConnection: thread? = nil -- To store the round timer connection

-- Constructor
function GameService.new()
    local self = BaseService.new("GameService")
    setmetatable(self, GameService)
    return self
end

-- Override Init method from BaseService
function GameService:Init(services: {[string]: any})
    -- Removed: self.Logger.Debug("GameService Init called with name: " .. tostring(self.Name), self.Name)
    BaseService.Init(self, services) -- Call the base class Init method first

    -- Removed: self.Logger.Info("GameService: Initializing game state and listeners.", self.Name) -- This was the redundant log

    -- Set initial game state in GlobalRegistry
    GlobalRegistry.Set("GameState", GAME_STATE.LOBBY)
    -- Removed: self.Logger.Debug("Initial GameState set to: " .. GlobalRegistry.Get("GameState"), self.Name)

    -- Connect player added/removing events
    Players.PlayerAdded:Connect(function(player) self:OnPlayerAdded(player) end)
    Players.PlayerRemoving:Connect(function(player) self:OnPlayerRemoving(player) end)

    -- Connect to CharacterAdded for existing players and future respawns
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player) -- Handle players already in game when server starts
    end

    self.Logger.Info("GameService initialized successfully.", self.Name) -- New INFO log for completion
end

-- Override Start method from BaseService
function GameService:Start()
    BaseService.Start(self) -- Call the base class Start method first

    self.Logger.Info("GameService: Starting game loop.", self.Name)

    -- Start the main game loop (e.g., transition to intermission or start first round)
    self:StartIntermission()
end

-- Override Shutdown method from BaseService
function GameService:Shutdown()
    BaseService.Shutdown(self)
    self.Logger.Info("GameService: Shutting down.", self.Name)
    GlobalRegistry.Set("GameState", GAME_STATE.SHUTDOWN)
    if roundTimerConnection then -- Disconnect any active round timer
        task.cancel(roundTimerConnection) -- Use task.cancel for task.delay
        roundTimerConnection = nil
    end
end

-- --- Game State Management ---

function GameService:SetGameState(newState: string)
    local currentState = GlobalRegistry.Get("GameState")
    if currentState == newState then
        self.Logger.Warn(string.format("Attempted to set GameState to '%s', but it's already that state.", newState), self.Name)
        return
    end

    -- Future: Add StateValidator here to check if transition is valid
    -- if not self.Services.StateValidator:CanTransition(currentState, newState) then
    --     self.Logger.Error(Constants.ERROR_INVALID_STATE_TRANSITION .. " From: " .. currentState .. " To: " .. newState, self.Name)
    --     return
    -- end

    GlobalRegistry.Set("GameState", newState)
    self.Logger.Info(string.format("GameState transitioned from '%s' to '%s'", currentState, newState), self.Name)
    -- Future: Fire a global event here for other services to react to state changes
end

function GameService:GetCurrentGameState(): string
    return GlobalRegistry.Get("GameState", GAME_STATE.LOBBY)
end

-- --- Round Management ---

function GameService:StartIntermission()
    self:SetGameState(GAME_STATE.INTERMISSION)
    self.Logger.Info("Intermission started. Waiting for players or timer.", self.Name)

    -- Clear players from previous round
    playersInRound = {}

    task.delay(10, function() -- Example delay
        if #Players:GetPlayers() >= 1 then -- Simple check for at least one player
            self:StartRound()
        else
            self.Logger.Info("Not enough players to start round, remaining in intermission.", self.Name)
            self:StartIntermission() -- Loop intermission until players
        end
    end)
end

function GameService:StartRound()
    self:SetGameState(GAME_STATE.PLAYING)
    self.Logger.Info("Round started! Players should now avoid lights.", self.Name)

    -- Populate playersInRound with all current players
    for _, player in ipairs(Players:GetPlayers()) do
        playersInRound[player.UserId] = true
        -- Teleport player to a starting position (placeholder)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 3, 0) -- FIXED: Changed Y-position to 3
        -- else -- Removed explicit LoadCharacter here to avoid duplicate CharacterAdded calls
            -- player:LoadCharacter() -- Force character load if not present
        end
    end

    -- Store the connection to the round end timer
    roundTimerConnection = task.delay(60, function() -- Example round duration
        -- FIXED: Clear the roundTimerConnection *before* calling EndRound
        if roundTimerConnection then
            roundTimerConnection = nil
        end
        self:EndRound("Time's up!")
    end)
end

function GameService:EndRound(reason: string)
    -- Get current state to prevent re-processing if already ending
    local currentState = GlobalRegistry.Get("GameState")
    if currentState == GAME_STATE.ROUND_END then
        -- If the state is already RoundEnd, it means this call is likely redundant
        -- or the timer just fired. No need to re-process or attempt to cancel.
        self.Logger.Warn(string.format("EndRound called when GameState is already '%s'. Reason: %s", currentState, reason), self.Name)
        return
    end

    -- Disconnect the round timer if it's still active, to prevent duplicate calls
    -- This block will only run if EndRound was called by something *other* than the timer itself (e.g., player elimination)
    if roundTimerConnection then
        task.cancel(roundTimerConnection) -- Cancel the timer
        roundTimerConnection = nil -- Clear the reference
        self.Logger.Debug("Cancelled active round timer due to early round end.", self.Name)
    end

    self:SetGameState(GAME_STATE.ROUND_END)
    self.Logger.Info(string.format("Round ended. Reason: %s", reason), self.Name)

    -- Determine winner (if any) and award points (future)
    if #Players:GetPlayers() > 0 then
        local remainingPlayers = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if playersInRound[player.UserId] then
                table.insert(remainingPlayers, player.Name)
            end
        end
        if #remainingPlayers > 0 then
            self.Logger.Info("Players remaining: " .. table.concat(remainingPlayers, ", "), self.Name)
            -- Award points to remaining players (future)
        else
            self.Logger.Info("No players survived the round.", self.Name)
        end
    end

    task.delay(5, function()
        self:StartIntermission()
    end)
end

-- --- Player Management ---

function GameService:OnPlayerAdded(player: Player)
    self.Logger.Info(string.format("Player '%s' joined the game.", player.Name), self.Name)
    -- Connect CharacterAdded to handle respawns
    player.CharacterAdded:Connect(function(character) self:OnCharacterAdded(player, character) end)
    -- Removed: player:LoadCharacter() -- This causes duplicate CharacterAdded calls on initial join
end

function GameService:OnPlayerRemoving(player: Player)
    self.Logger.Info(string.format("Player '%s' left the game.", player.Name), self.Name)
    -- Remove player from active round tracking
    playersInRound[player.UserId] = nil
    -- Future: Save player data if not already saved, handle player's exit from current round
end

function GameService:OnCharacterAdded(player: Player, character: Model)
    self.Logger.Debug(string.format("Character for player '%s' loaded/respawned.", player.Name), self.Name)
    -- If the game is in a playing state, ensure the player is in the round
    if GlobalRegistry.Get("GameState") == GAME_STATE.PLAYING then
        playersInRound[player.UserId] = true
        -- Teleport to a safe spawn point if they just respawned during a round
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(0, 3, 0) -- FIXED: Changed Y-position to 3
        end
    end
end

-- Handles player elimination when caught by a light
-- @param player: Player - The player to eliminate.
-- @param reason: string - The reason for elimination (e.g., "Caught by light").
function GameService:EliminatePlayer(player: Player, reason: string)
    if not playersInRound[player.UserId] then
        self.Logger.Warn(string.format("Attempted to eliminate player '%s' who is not in the current round or already eliminated.", player.Name), self.Name)
        return
    end

    self.Logger.Info(string.format("Player '%s' eliminated. Reason: %s", player.Name, reason), self.Name)
    playersInRound[player.UserId] = nil -- Mark player as eliminated

    -- Respawn the player after a delay
    task.delay(Constants.PLAYER_RESPAWN_DELAY, function()
        if player then -- Check if player still exists
            player:LoadCharacter()
        end
    end)

    -- Check if all players are eliminated, if so, end the round early
    local remainingPlayersCount = 0
    for _, _ in pairs(playersInRound) do
        remainingPlayersCount += 1
    end

    if remainingPlayersCount == 0 and GlobalRegistry.Get("GameState") == GAME_STATE.PLAYING then
        self.Logger.Info("All players eliminated. Ending round early.", self.Name)
        self:EndRound("All players eliminated")
    end
end

return GameService
