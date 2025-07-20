--!strict
-- Logger.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: A robust logging system for the game.
-- Supports different log levels (DEBUG, INFO, WARN, ERROR, FATAL) and
-- can be configured to print to output or potentially save to a datastore.

-- Load Constants from ReplicatedStorage (more robust approach)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))

local Logger = {}

-- Define log levels and their numerical priority
local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5
}

-- Get the configured minimum log level from Constants
local MIN_LOG_LEVEL_NUM = LOG_LEVELS[Constants.LOG_LEVEL] or LOG_LEVELS.INFO

-- Helper function to format log messages
local function formatMessage(level: string, message: string, context: string?)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local prefix = string.format("[%s] [%s]", timestamp, level)
    if context then
        prefix = string.format("%s [%s]", prefix, context)
    end
    return string.format("%s: %s", prefix, message)
end

-- Generic log function
local function log(level: string, message: string, context: string?)
    local levelNum = LOG_LEVELS[level]
    if not levelNum or levelNum < MIN_LOG_LEVEL_NUM then
        return -- Skip logging if current level is below configured minimum
    end

    local formattedMsg = formatMessage(level, message, context)

    if Constants.LOG_TO_OUTPUT then
        -- Use different print functions for better visibility in output
        if level == "ERROR" or level == "FATAL" then
            warn(formattedMsg) -- warn prints in yellow
        elseif level == "WARN" then
            warn(formattedMsg)
        else
            print(formattedMsg)
        end
    end

    -- Future: If Constants.LOG_TO_DATASTORE is true, save FATAL/ERROR logs to a Datastore
    -- This would involve the DataManager and a separate system for uploading logs.
end

-- Public logging methods
function Logger.Debug(message: string, context: string?)
    log("DEBUG", message, context)
end

function Logger.Info(message: string, context: string?)
    log("INFO", message, context)
end

function Logger.Warn(message: string, context: string?)
    log("WARN", message, context)
end

function Logger.Error(message: string, context: string?)
    log("ERROR", message, context)
end

function Logger.Fatal(message: string, context: string?)
    log("FATAL", message, context)
    -- Potentially trigger a crash or critical error handling here
end

return Logger
