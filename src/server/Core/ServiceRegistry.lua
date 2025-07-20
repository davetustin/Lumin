--!strict
-- ServiceRegistry.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Manages the registration, initialization, and starting of game services.
-- Ensures dependencies are met and services are started in the correct order.

local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Logger = require(Core:WaitForChild("Logger"))
local BaseService = require(Core:WaitForChild("BaseService"))

local ServiceRegistry = {}
local registeredServices = {} -- Stores service constructors
local initializedServices = {} -- Stores initialized service instances
local serviceOrder = {} -- Stores the order in which services should be initialized/started

-- Registers a service with the registry.
-- @param name: string - The unique name of the service.
-- @param serviceConstructor: function - The constructor function for the service (e.g., function() return MyService.new() end).
function ServiceRegistry.RegisterService(name: string, serviceConstructor: () -> BaseService)
    if registeredServices[name] then
        Logger.Warn("Service '" .. name .. "' already registered. Overwriting.", "ServiceRegistry")
    end
    registeredServices[name] = serviceConstructor
    table.insert(serviceOrder, name) -- Add to order for sequential processing
    Logger.Debug("Service '" .. name .. "' registered.", "ServiceRegistry")
end

-- Initializes all registered services.
-- This phase checks dependencies and calls the Init method on each service.
function ServiceRegistry.InitServices()
    Logger.Info("Initializing all services...", "ServiceRegistry")

    -- First pass: Create instances and store them
    for _, name in ipairs(serviceOrder) do
        local serviceConstructor = registeredServices[name]
        if serviceConstructor then
            local serviceInstance = serviceConstructor()
            if not (typeof(serviceInstance) == "table" and serviceInstance.IsInitialized ~= nil) then
                Logger.Fatal("Service '" .. name .. "' constructor did not return a valid BaseService instance.", "ServiceRegistry")
                error("Invalid service instance for " .. name)
            end
            initializedServices[name] = serviceInstance
            Logger.Debug("Created instance for service: " .. name, "ServiceRegistry")
        else
            Logger.Error("No constructor found for service: " .. name, "ServiceRegistry")
        end
    end

    -- Second pass: Call Init on all services, passing all initialized services for dependency injection
    for _, name in ipairs(serviceOrder) do
        local serviceInstance = initializedServices[name]
        if serviceInstance then
            serviceInstance:Init(initializedServices) -- Pass the table of all initialized services
        end
    end

    Logger.Info("All services initialized.", "ServiceRegistry")
end

-- Starts all initialized services.
-- This phase calls the Start method on each service.
function ServiceRegistry.StartServices()
    Logger.Info("Starting all services...", "ServiceRegistry")
    for _, name in ipairs(serviceOrder) do
        local serviceInstance = initializedServices[name]
        if serviceInstance then
            serviceInstance:Start()
        end
    end
    Logger.Info("All services started.", "ServiceRegistry")
end

-- Shuts down all started services.
function ServiceRegistry.ShutdownServices()
    Logger.Info("Shutting down all services...", "ServiceRegistry")
    -- Shut down in reverse order of startup if dependencies need to be handled carefully
    for i = #serviceOrder, 1, -1 do
        local name = serviceOrder[i]
        local serviceInstance = initializedServices[name]
        if serviceInstance then
            serviceInstance:Shutdown()
        end
    end
    Logger.Info("All services shut down.", "ServiceRegistry")
end

-- Retrieves an initialized service instance.
-- @param name: string - The name of the service to retrieve.
-- @return BaseService | nil - The service instance, or nil if not found/initialized.
function ServiceRegistry.GetService(name: string): BaseService?
    return initializedServices[name]
end

return ServiceRegistry
