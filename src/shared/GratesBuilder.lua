--!strict
-- GratesBuilder.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Module for programmatically creating modular futuristic grates.

local GratesBuilder = {}

-- Function to create a single modular grate part.
-- This version creates a single part with a ForceField material.
-- @param cframe: CFrame - The CFrame (position and orientation) of the grate.
-- @param size: Vector3 - The dimensions (X, Y, Z) of the grate.
-- @param color: Color3 - The color of the grate (will affect ForceField tint).
-- @param transparency: number - The transparency of the grate (0 = opaque, 1 = invisible).
-- @param canCollide: boolean - Whether players can collide with the grate.
-- @return Part - A Roblox Part representing the grate.
function GratesBuilder.createModularGrate(
    cframe: CFrame,
    size: Vector3,
    color: Color3,
    transparency: number,
    canCollide: boolean
): Part
    local gratePart = Instance.new("Part")
    gratePart.Name = "Grate"
    gratePart.Size = size
    gratePart.CFrame = cframe
    gratePart.BrickColor = BrickColor.new(color)
    gratePart.Material = Enum.Material.ForceField -- Gives it a semi-transparent, futuristic look
    gratePart.Transparency = transparency
    gratePart.Anchored = true -- Grates should typically be stationary
    gratePart.CanCollide = canCollide
    gratePart.Parent = workspace -- Parent to workspace for visibility, can be changed later

    return gratePart
end

-- Future: Function to create a more complex grate using multiple parts (e.g., a grid pattern)
-- function GratesBuilder.createComplexGrate(
--     cframe: CFrame,
--     size: Vector3,
--     baseColor: Color3,
--     neonColor: Color3,
--     barThickness: number
-- ): Model
--     local grateModel = Instance.new("Model")
--     grateModel.Name = "ComplexGrate"
--     grateModel.Parent = workspace
--
--     -- Create a frame
--     -- Create individual bars
--     -- Combine into a model
--
--     return grateModel
-- end

return GratesBuilder
