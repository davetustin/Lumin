--!strict
-- BaseService.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Base class for all game services.
-- Provides a standardized structure for service initialization, dependencies,
-- and common methods like 'Init' and 'Start'. All services should inherit from this.

local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Logger = require(Core:WaitForChild("Logger"))

-- Type definitions for better type handling
type BaseServiceType = {
    Name: string,
    IsInitialized: boolean,
    IsStarted: boolean,
    Dependencies: {string},
    Logger: typeof(Logger)
}

local BaseService = {}
BaseService.__index = BaseService

-- Constructor for BaseService
function BaseService.new(serviceName: string): BaseServiceType
    local self: BaseServiceType = setmetatable({}, BaseService)
    self.Name = serviceName or "UnnamedService"
    self.IsInitialized = false
    self.IsStarted = false
    self.Dependencies = {} -- Table to store required service names
    self.Logger = Logger -- Each service gets its own logger instance
    return self
end

-- Method to define service dependencies
-- @param dependencies: table<string> - A list of service names this service depends on.
function BaseService:SetDependencies(dependencies: {string})
    self.Dependencies = dependencies
end

-- Virtual method for service initialization logic.
-- This should be overridden by inheriting services.
-- @param services: table<string, any> - A table of initialized services for dependency injection.
function BaseService:Init(services: {[string]: any})
    if self.IsInitialized then
        self.Logger.Warn(self.Name .. " already initialized.", self.Name)
        return
    end

    -- Check if all dependencies are met
    for _, depName in ipairs(self.Dependencies) do
        if not services[depName] then
            self.Logger.Fatal(self.Name .. " missing required dependency: " .. depName, self.Name)
            error("Missing dependency: " .. depName) -- Critical error, stop execution
        end
    end

    self.Logger.Debug(self.Name .. " initializing...", self.Name)
    self.IsInitialized = true
end

-- Virtual method for service startup logic.
-- This should be overridden by inheriting services.
-- Called after all services are initialized.
function BaseService:Start()
    if not self.IsInitialized then
        self.Logger.Fatal(self.Name .. " cannot start before initialization.", self.Name)
        error("Service not initialized: " .. self.Name)
    end
    if self.IsStarted then
        self.Logger.Warn(self.Name .. " already started.", self.Name)
        return
    end

    self.Logger.Debug(self.Name .. " starting...", self.Name)
    self.IsStarted = true
end

-- Virtual method for service shutdown logic (e.g., disconnecting events, saving data).
-- This should be overridden by inheriting services.
function BaseService:Shutdown()
    if not self.IsStarted then
        self.Logger.Warn(self.Name .. " not started, no need to shut down.", self.Name)
        return
    end
    self.Logger.Debug(self.Name .. " shutting down...", self.Name)
    self.IsStarted = false
    self.IsInitialized = false
end

return BaseService
