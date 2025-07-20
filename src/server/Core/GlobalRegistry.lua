--!strict
-- GlobalRegistry.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: A centralized registry for global game state and data.
-- Allows different parts of the game to share and access common data
-- without creating direct dependencies between unrelated modules.
-- This can store things like game phase, player scores, current level, etc.

local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Logger = require(Core:WaitForChild("Logger"))

local GlobalRegistry = {}
local registry = {} -- Internal table to store global data
local events = {} -- Internal table to store event connections

-- Create a global OnValueChanged event for any value changes
local OnValueChanged = Instance.new("BindableEvent")

-- Creates or gets an event for a specific key
-- @param key: string - The key to create/get an event for
-- @return BindableEvent - The event for this key
function GlobalRegistry.GetEvent(key: string): BindableEvent
    if not events[key] then
        events[key] = Instance.new("BindableEvent")
    end
    return events[key]
end

-- Gets the Event property of a BindableEvent for a specific key
-- @param key: string - The key to get the event for
-- @return RBXScriptSignal - The event signal for this key
function GlobalRegistry.GetEventSignal(key: string): RBXScriptSignal
    if not events[key] then
        events[key] = Instance.new("BindableEvent")
    end
    return events[key].Event
end

-- Sets a value in the global registry.
-- @param key: string - The key to store the value under.
-- @param value: any - The value to store.
function GlobalRegistry.Set(key: string, value: any)
    local oldValue = registry[key]
    if oldValue ~= value then
        registry[key] = value
        Logger.Debug(string.format("GlobalRegistry: Set '%s' to '%s'", key, tostring(value)), "GlobalRegistry")
        
        -- Fire the event if it exists
        if events[key] then
            events[key]:Fire(value, oldValue)
        end
        
        -- Fire the global OnValueChanged event
        OnValueChanged:Fire(key, value, oldValue)
    end
end

-- Gets a value from the global registry.
-- @param key: string - The key of the value to retrieve.
-- @param defaultValue: any? - An optional default value to return if the key does not exist.
-- @return any - The stored value, or defaultValue if not found.
function GlobalRegistry.Get(key: string, defaultValue: any?): any
    local value = registry[key]
    if value == nil and defaultValue ~= nil then
        return defaultValue
    end
    return value
end

-- Checks if a key exists in the global registry.
-- @param key: string - The key to check.
-- @return boolean - True if the key exists, false otherwise.
function GlobalRegistry.Has(key: string): boolean
    return registry[key] ~= nil
end

-- Removes a key-value pair from the global registry.
-- @param key: string - The key to remove.
function GlobalRegistry.Remove(key: string)
    if registry[key] ~= nil then
        registry[key] = nil
        Logger.Debug(string.format("GlobalRegistry: Removed '%s'", key), "GlobalRegistry")
    else
        Logger.Warn(string.format("GlobalRegistry: Attempted to remove non-existent key '%s'", key), "GlobalRegistry")
    end
end

-- Clears all entries from the global registry.
function GlobalRegistry.Clear()
    registry = {}
    Logger.Info("GlobalRegistry: All entries cleared.", "GlobalRegistry")
end

-- Cleans up events for a specific key
-- @param key: string - The key to clean up events for
function GlobalRegistry.CleanupEvent(key: string)
    if events[key] then
        events[key]:Destroy()
        events[key] = nil
        Logger.Debug(string.format("GlobalRegistry: Cleaned up event for '%s'", key), "GlobalRegistry")
    end
end

-- Cleans up all events
function GlobalRegistry.CleanupAllEvents()
    for key, event in pairs(events) do
        event:Destroy()
    end
    events = {}
    OnValueChanged:Destroy()
    Logger.Info("GlobalRegistry: All events cleaned up.", "GlobalRegistry")
end

-- Expose the OnValueChanged event
GlobalRegistry.OnValueChanged = OnValueChanged.Event

return GlobalRegistry
