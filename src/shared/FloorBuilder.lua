--!strict
-- FloorBuilder.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Module for programmatically creating modular futuristic floor tiles.
-- Includes functionality for a main floor surface and embedded glowing neon lines.

local FloorBuilder = {}

-- Function to create a single modular floor tile with glowing lines
-- @param position: Vector3 - The center position of the floor tile.
-- @param size: Vector3 - The dimensions (X, Y, Z) of the floor tile.
-- @param baseColor: Color3 - The color of the main floor surface.
-- @param neonColor: Color3 - The color of the glowing neon lines.
-- @param neonThickness: number - The thickness (Y-dimension) of the neon lines.
-- @param neonInset: number - How far from the edge the neon lines should be.
-- @return Model - A Roblox Model containing the floor base and neon lines.
function FloorBuilder.createModularFloorTile(
    position: Vector3,
    size: Vector3,
    baseColor: Color3,
    neonColor: Color3,
    neonThickness: number,
    neonInset: number
): Model
    local floorModel = Instance.new("Model")
    floorModel.Name = "ModularFloorTile"
    floorModel.Parent = workspace -- Parent to workspace for visibility, can be changed later

    -- Create the main floor part
    local floorBase = Instance.new("Part")
    floorBase.Name = "FloorBase"
    floorBase.Size = size
    floorBase.Position = Vector3.new(position.X, position.Y + 0.01, position.Z) -- Raise floor base to prevent z-fighting
    floorBase.BrickColor = BrickColor.new(baseColor)
    floorBase.Material = Enum.Material.SmoothPlastic -- Or Metal, Basalt, etc. for futuristic feel
    floorBase.Reflectance = 0.1 -- Slight reflectivity
    floorBase.Anchored = true
    floorBase.CanCollide = true
    floorBase.Parent = floorModel

    -- Create glowing neon lines (example: border lines)
    local lineLength = size.X - (neonInset * 2)
    local lineWidth = size.Z - (neonInset * 2)
    local lineOffsetFromCenter = size.X / 2 - neonInset
    local lineYPosition = position.Y + (size.Y / 2) + (neonThickness / 2) + 0.01

    -- Front/Back Lines (along X-axis)
    local line1 = Instance.new("Part")
    line1.Name = "NeonLine_Front"
    line1.Size = Vector3.new(lineLength, neonThickness, neonThickness)
    line1.CFrame = CFrame.new(position.X, lineYPosition, position.Z - lineOffsetFromCenter)
    line1.BrickColor = BrickColor.new(neonColor)
    line1.Material = Enum.Material.Neon
    line1.Anchored = true
    line1.CanCollide = false
    line1.Parent = floorModel

    local line2 = Instance.new("Part")
    line2.Name = "NeonLine_Back"
    line2.Size = Vector3.new(lineLength, neonThickness, neonThickness)
    line2.CFrame = CFrame.new(position.X, lineYPosition, position.Z + lineOffsetFromCenter)
    line2.BrickColor = BrickColor.new(neonColor)
    line2.Material = Enum.Material.Neon
    line2.Anchored = true
    line2.CanCollide = false
    line2.Parent = floorModel

    -- Left/Right Lines (along Z-axis)
    local line3 = Instance.new("Part")
    line3.Name = "NeonLine_Left"
    line3.Size = Vector3.new(neonThickness, neonThickness, lineWidth)
    line3.CFrame = CFrame.new(position.X - lineOffsetFromCenter, lineYPosition, position.Z)
    line3.BrickColor = BrickColor.new(neonColor)
    line3.Material = Enum.Material.Neon
    line3.Anchored = true
    line3.CanCollide = false
    line3.Parent = floorModel

    local line4 = Instance.new("Part")
    line4.Name = "NeonLine_Right"
    line4.Size = Vector3.new(neonThickness, neonThickness, lineWidth)
    line4.CFrame = CFrame.new(position.X + lineOffsetFromCenter, lineYPosition, position.Z)
    line4.BrickColor = BrickColor.new(neonColor)
    line4.Material = Enum.Material.Neon
    line4.Anchored = true
    line4.CanCollide = false
    line4.Parent = floorModel

    return floorModel
end

return FloorBuilder
