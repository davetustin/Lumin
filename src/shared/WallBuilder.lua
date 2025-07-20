--!strict
-- WallBuilder.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Module for programmatically creating modular futuristic wall sections.
-- Includes functionality for a main wall surface and embedded glowing neon lines.

local WallBuilder = {}

-- Function to create a single modular wall section with glowing lines
-- @param cframe: CFrame - The CFrame (position and orientation) of the wall section.
-- @param size: Vector3 - The dimensions (X, Y, Z) of the wall section.
-- @param baseColor: Color3 - The color of the main wall surface.
-- @param neonColor: Color3 - The color of the glowing neon lines.
-- @param neonThickness: number - The thickness (depth) of the neon lines.
-- @param neonInset: number - How far from the edge the neon lines should be.
-- @return Model - A Roblox Model containing the wall base and neon lines.
function WallBuilder.createModularWallSection(
    cframe: CFrame,
    size: Vector3,
    baseColor: Color3,
    neonColor: Color3,
    neonThickness: number,
    neonInset: number
): Model
    local wallModel = Instance.new("Model")
    wallModel.Name = "ModularWallSection"
    wallModel.Parent = workspace -- Parent to workspace for visibility, can be changed later

    -- Create the main wall part
    local wallBase = Instance.new("Part")
    wallBase.Name = "WallBase"
    wallBase.Size = size
    wallBase.CFrame = cframe
    wallBase.BrickColor = BrickColor.new(baseColor)
    wallBase.Material = Enum.Material.SmoothPlastic -- Consistent with floor
    wallBase.Reflectance = 0.1 -- Slight reflectivity
    wallBase.Anchored = true
    wallBase.CanCollide = true
    wallBase.Parent = wallModel

    -- Calculate line dimensions and positions relative to the wall's local space
    -- Assuming lines run along the wall's longest dimension (X or Z) and vertically (Y)
    local horizontalLineLength = size.X - (neonInset * 2)
    local verticalLineLength = size.Y - (neonInset * 2)
    local lineOffsetFromEdgeX = size.X / 2 - neonInset
    local lineOffsetFromEdgeY = size.Y / 2 - neonInset
    local lineOffsetFromEdgeZ = size.Z / 2 - neonInset -- For depth of the line
    
    -- Ensure neonThickness is applied to the thinnest dimension of the line parts
    local lineThickness = neonThickness 

    -- Create glowing neon lines (example: border lines)
    -- Horizontal lines (top and bottom)
    local line1 = Instance.new("Part")
    line1.Name = "NeonLine_Top"
    line1.Size = Vector3.new(horizontalLineLength, lineThickness, lineThickness)
    line1.CFrame = cframe * CFrame.new(0, lineOffsetFromEdgeY, -lineOffsetFromEdgeZ) -- Top edge, front face
    line1.BrickColor = BrickColor.new(neonColor)
    line1.Material = Enum.Material.Neon
    line1.Anchored = true
    line1.CanCollide = false
    line1.Parent = wallModel

    local line2 = Instance.new("Part")
    line2.Name = "NeonLine_Bottom"
    line2.Size = Vector3.new(horizontalLineLength, lineThickness, lineThickness)
    line2.CFrame = cframe * CFrame.new(0, -lineOffsetFromEdgeY, -lineOffsetFromEdgeZ) -- Bottom edge, front face
    line2.BrickColor = BrickColor.new(neonColor)
    line2.Material = Enum.Material.Neon
    line2.Anchored = true
    line2.CanCollide = false
    line2.Parent = wallModel

    -- Vertical lines (left and right)
    local line3 = Instance.new("Part")
    line3.Name = "NeonLine_Left"
    line3.Size = Vector3.new(lineThickness, verticalLineLength, lineThickness)
    line3.CFrame = cframe * CFrame.new(-lineOffsetFromEdgeX, 0, -lineOffsetFromEdgeZ) -- Left edge, front face
    line3.BrickColor = BrickColor.new(neonColor)
    line3.Material = Enum.Material.Neon
    line3.Anchored = true
    line3.CanCollide = false
    line3.Parent = wallModel

    local line4 = Instance.new("Part")
    line4.Name = "NeonLine_Right"
    line4.Size = Vector3.new(lineThickness, verticalLineLength, lineThickness)
    line4.CFrame = cframe * CFrame.new(lineOffsetFromEdgeX, 0, -lineOffsetFromEdgeZ) -- Right edge, front face
    line4.BrickColor = BrickColor.new(neonColor)
    line4.Material = Enum.Material.Neon
    line4.Anchored = true
    line4.CanCollide = false
    line4.Parent = wallModel

    wallModel.PrimaryPart = wallBase -- Set PrimaryPart for the model
    return wallModel
end

return WallBuilder
