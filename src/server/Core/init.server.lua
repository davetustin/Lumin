--!strict
-- init.server.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Main server-side entry point for the LUMIN game.
-- This script is responsible for initializing and starting all core server services.

local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Systems = ServerScriptService:WaitForChild("Systems")

local Logger = require(Core:WaitForChild("Logger"))
local ServiceRegistry = require(Core:WaitForChild("ServiceRegistry"))

-- Require and register all server-side services
local GameService = require(Systems:WaitForChild("GameService"))
local LightService = require(Systems:WaitForChild("LightService"))
-- local DataManager = require(script.Parent.DataManager) -- Future: Uncomment when DataManager is created
-- local NetworkManager = require(script.Parent.NetworkManager) -- Future: Uncomment when NetworkManager is created
-- local StateValidator = require(script.Parent.StateValidator) -- Future: Uncomment when StateValidator is created

-- Register services with the ServiceRegistry
ServiceRegistry.RegisterService("GameService", function() return GameService.new() end)
ServiceRegistry.RegisterService("LightService", function() return LightService.new() end)
-- ServiceRegistry.RegisterService("DataManager", function() return DataManager.new() end) -- Future
-- ServiceRegistry.RegisterService("NetworkManager", function() return NetworkManager.new() end) -- Future
-- ServiceRegistry.RegisterService("StateValidator", function() return StateValidator.new() end) -- Future


-- Initialize and Start all services
-- This should be done after all services are registered.
ServiceRegistry.InitServices()
ServiceRegistry.StartServices()

-- Removed: Redundant INFO log, as ServiceRegistry already logs "All services started."
-- Logger.Info("All server services initialized and started successfully.", "init.server.lua")

-- Optional: Add a shutdown hook to gracefully stop services when the server closes
game:BindToClose(function()
    Logger.Info("Server is shutting down. Initiating graceful service shutdown.", "init.server.lua")
    ServiceRegistry.ShutdownServices()
    -- Removed: Redundant INFO log, as ServiceRegistry already logs "All services shut down."
    -- Logger.Info("All server services shut down.", "init.server.lua")
end)
