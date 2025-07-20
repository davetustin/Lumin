--!strict
-- Constants.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Centralized script for all game constants and configurable values.
-- This allows for easy tuning and modification of game parameters in one place,
-- improving maintainability and performance by pre-defining values.

local Constants = {}

-- Game Information
Constants.GAME_NAME = "BlindSpot"
Constants.GAME_VERSION = "0.1.0 Alpha"
Constants.DEVELOPER_NAME = "AI Assistant"

-- Logging Configuration
-- Log levels: "DEBUG", "INFO", "WARN", "ERROR", "FATAL"
Constants.LOG_LEVEL = "DEBUG" -- Set to "INFO" or higher for release builds
Constants.LOG_TO_OUTPUT = true -- Whether to print logs to Roblox Studio Output
Constants.LOG_TO_DATASTORE = false -- Whether to save critical logs to a Datastore (for future analytics)

-- Game Mechanics
Constants.LIGHT_DETECTION_DURATION = 0.5 -- Seconds a player must be in light to be eliminated
Constants.PLAYER_ELIMINATION_ANIMATION_DURATION = 1.5 -- Seconds for the "caught" animation (future use)
Constants.PLAYER_RESPAWN_DELAY = 2 -- Seconds before a player respawns after elimination (NEW)
Constants.INTERACT_KEY = Enum.KeyCode.E -- Key to press for interaction

-- Player Abilities (Shadow Dash Example)
Constants.SHADOW_DASH_COOLDOWN = 5 -- Seconds cooldown for Shadow Dash
Constants.SHADOW_DASH_DISTANCE = 20 -- Studs the player teleports
Constants.SHADOW_DASH_DURATION = 0.2 -- Seconds the dash takes

-- Light Source Properties (Example for Security Drone)
Constants.DRONE_SPEED = 5 -- Studs per second
Constants.DRONE_LIGHT_RANGE = 30 -- Studs for the spotlight range
Constants.DRONE_LIGHT_ANGLE = 60 -- Degrees for the spotlight angle

-- UI Configuration
Constants.UI_FADE_DURATION = 0.3 -- Seconds for UI elements to fade in/out

-- DataStore Configuration (for future DataManager)
Constants.DATASTORE_NAME = "LUMIN_PLAYER_DATA"
Constants.DATASTORE_VERSION = 1

-- Networking Configuration
Constants.NETWORK_TIMEOUT = 10 -- Seconds before a network request times out

-- Object Pool Configuration (for future ObjectPool)
Constants.POOL_INITIAL_SIZE = 5 -- Initial number of objects in a pool
Constants.POOL_MAX_SIZE = 20 -- Maximum number of objects in a pool

-- Error Messages (for StateValidator and general error handling)
Constants.ERROR_INVALID_STATE_TRANSITION = "Invalid state transition requested."
Constants.ERROR_SERVICE_NOT_FOUND = "Service not found in registry."
Constants.ERROR_MISSING_DEPENDENCY = "Missing required dependency for service initialization."
Constants.ERROR_DATA_SAVE_FAILED = "Failed to save player data."
Constants.ERROR_NETWORK_REQUEST_FAILED = "Network request failed."

return Constants
