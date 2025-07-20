--!strict
-- LevelGenerator.lua
-- Author: Gemini
-- Date: July 20, 2025
-- Description: Service responsible for generating game levels using modular assets.
-- This service will orchestrate the placement of floor tiles, walls, lights, etc.

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ServerScriptService:WaitForChild("Core")
local Systems = ServerScriptService:WaitForChild("Systems")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local BaseService = require(Core:WaitForChild("BaseService"))
local Logger = require(Core:WaitForChild("Logger"))
local FloorBuilder = require(Shared:WaitForChild("FloorBuilder"))
local WallBuilder = require(Shared:WaitForChild("WallBuilder"))
local GratesBuilder = require(Shared:WaitForChild("GratesBuilder")) -- NEW: Require the GratesBuilder module

local LevelGenerator = {}
LevelGenerator.__index = LevelGenerator
setmetatable(LevelGenerator, {__index = BaseService})

-- Constructor
function LevelGenerator.new()
    local self = BaseService.new("LevelGenerator")
    return setmetatable(self, LevelGenerator)
end

-- Initialize the service
function LevelGenerator:Init(services)
    BaseService.Init(self, services) -- Pass the services table from ServiceRegistry
    self.Logger.Info("LevelGenerator initialized successfully.", self.Name)
end

-- Start the service
function LevelGenerator:Start()
    BaseService.Start(self)
    self.Logger.Info("LevelGenerator started successfully.", self.Name)
    
    -- Generate the base level structure when the service starts
    self:generateBaseLevel()
end

-- Function to generate the base level structure (e.g., floors, outer walls)
function LevelGenerator:generateBaseLevel()
    self.Logger.Info("LevelGenerator: Generating base level structure.", self.Name)

    -- Create a parent folder for all level elements for better organization
    local mapFolder = Instance.new("Folder")
    mapFolder.Name = "Map"
    mapFolder.Parent = workspace

    -- Define common floor properties
    local floorSize = Vector3.new(50, 1, 50)
    local baseColor = Color3.fromRGB(30, 30, 30) -- Dark grey
    local neonColor = Color3.fromRGB(0, 255, 255) -- Cyan neon
    local neonThickness = 0.2
    local neonInset = 2

    -- Example: Create a 3x3 grid of floor tiles
    local gridSize = 3
    local tileSpacing = floorSize.X -- Assuming square tiles for simple spacing
    local totalGridDimension = gridSize * tileSpacing

    for x = 0, gridSize - 1 do
        for z = 0, gridSize - 1 do
            local tilePositionX = (x - math.floor(gridSize / 2)) * tileSpacing
            local tilePositionZ = (z - math.floor(gridSize / 2)) * tileSpacing
            
            -- Adjust Y position so the top of the floor is at Y=0 (or slightly above if floorSize.Y is 1)
            local tileYPosition = -floorSize.Y / 2 

            local tile = FloorBuilder.createModularFloorTile(
                Vector3.new(tilePositionX, tileYPosition, tilePositionZ),
                floorSize,
                baseColor,
                neonColor,
                neonThickness,
                neonInset
            )
            tile.Parent = mapFolder -- Parent the tile model to the map folder
            tile.PrimaryPart = tile:FindFirstChild("FloorBase") -- Set a PrimaryPart for potential model CFrame manipulation later
        end
    end

    self.Logger.Info("LevelGenerator: Floor generation complete.", self.Name)

    -- Generate walls after floors
    self:generateWalls(mapFolder, totalGridDimension, baseColor, neonColor, neonThickness, neonInset)

    self.Logger.Info("LevelGenerator: Walls generation complete.", self.Name) -- Updated log

    -- NEW: Generate grates after walls
    self:generateGrates(mapFolder, totalGridDimension, baseColor, neonColor)

    self.Logger.Info("LevelGenerator: Base level generation complete.", self.Name)
end

-- Function to generate walls around the perimeter of the level
-- @param parentFolder: Instance - The folder to parent the walls to.
-- @param gridDimension: number - The total length/width of the square grid (e.g., 150 for 3x3 of 50x50 tiles).
-- @param baseColor: Color3 - The color of the main wall surface.
-- @param neonColor: Color3 - The color of the glowing neon lines.
-- @param neonThickness: number - The thickness (depth) of the neon lines.
-- @param neonInset: number - How far from the edge the neon lines should be.
function LevelGenerator:generateWalls(
    parentFolder: Instance,
    gridDimension: number,
    baseColor: Color3,
    neonColor: Color3,
    neonThickness: number,
    neonInset: number
)
    self.Logger.Info("LevelGenerator: Generating walls.", self.Name)

    local wallHeight = 50 -- Standard wall height
    local wallThickness = 2 -- Standard wall thickness (depth into the playable area)
    local wallLength = gridDimension + (wallThickness * 2) -- Walls span the full grid + their own thickness
    
    -- Calculate half dimensions for positioning
    local halfGrid = gridDimension / 2
    local halfWallThickness = wallThickness / 2
    local halfWallHeight = wallHeight / 2

    -- Walls will be positioned such that their outer face aligns with the grid edge
    -- and their center is at the halfWallThickness offset from the edge.
    -- Since WallBuilder now places lines on local +Z, we want local +Z to face inwards.

    -- Front Wall (along Z-axis, negative Z side of grid)
    -- Local +Z should face World +Z (inwards). This means no rotation.
    local frontWallCFrame = CFrame.new(
        0, -- Centered on X
        halfWallHeight, -- Half height to sit on Y=0
        -halfGrid - halfWallThickness -- Position just outside the grid
    ) 
    local frontWall = WallBuilder.createModularWallSection(
        frontWallCFrame,
        Vector3.new(wallLength, wallHeight, wallThickness),
        baseColor,
        neonColor,
        neonThickness,
        neonInset
    )
    frontWall.Parent = parentFolder
    frontWall.Name = "Wall_Front"

    -- Back Wall (along Z-axis, positive Z side of grid)
    -- Local +Z should face World -Z (inwards). This means a 180-degree rotation.
    local backWallCFrame = CFrame.new(
        0, -- Centered on X
        halfWallHeight, -- Half height to sit on Y=0
        halfGrid + halfWallThickness -- Position just outside the grid
    ) * CFrame.Angles(0, math.rad(180), 0) 
    local backWall = WallBuilder.createModularWallSection(
        backWallCFrame,
        Vector3.new(wallLength, wallHeight, wallThickness),
        baseColor,
        neonColor,
        neonThickness,
        neonInset
    )
    backWall.Parent = parentFolder
    backWall.Name = "Wall_Back"

    -- Left Wall (along X-axis, negative X side of grid)
    -- Local +Z should face World +X (inwards). This means a 90-degree rotation.
    local leftWallCFrame = CFrame.new(
        -halfGrid - halfWallThickness, -- Position just outside the grid
        halfWallHeight, -- Half height to sit on Y=0
        0 -- Centered on Z
    ) * CFrame.Angles(0, math.rad(90), 0) 
    local leftWall = WallBuilder.createModularWallSection(
        leftWallCFrame,
        Vector3.new(wallLength, wallHeight, wallThickness),
        baseColor,
        neonColor,
        neonThickness,
        neonInset
    )
    leftWall.Parent = parentFolder
    leftWall.Name = "Wall_Left"

    -- Right Wall (along X-axis, positive X side of grid)
    -- Local +Z should face World -X (inwards). This means a -90-degree rotation.
    local rightWallCFrame = CFrame.new(
        halfGrid + halfWallThickness, -- Position just outside the grid
        halfWallHeight, -- Half height to sit on Y=0
        0 -- Centered on Z
    ) * CFrame.Angles(0, math.rad(-90), 0) 
    local rightWall = WallBuilder.createModularWallSection(
        rightWallCFrame,
        Vector3.new(wallLength, wallHeight, wallThickness),
        baseColor,
        neonColor,
        neonThickness,
        neonInset
    ) 
    rightWall.Parent = parentFolder
    rightWall.Name = "Wall_Right"

    self.Logger.Info("LevelGenerator: Wall generation complete.", self.Name)
end

-- NEW: Function to generate grates within the level
-- @param parentFolder: Instance - The folder to parent the grates to.
-- @param gridDimension: number - The total length/width of the square grid.
-- @param baseColor: Color3 - The base color for grates.
-- @param neonColor: Color3 - The neon color for grates.
function LevelGenerator:generateGrates(
    parentFolder: Instance,
    gridDimension: number,
    baseColor: Color3,
    neonColor: Color3
)
    self.Logger.Info("LevelGenerator: Generating grates.", self.Name)

    local grateHeight = 0.5 -- Thickness of the grate itself
    local grateYPosition = 0.5 -- Position on top of the floor (floor is at Y=0)
    local grateColor = neonColor -- Use neon color for the ForceField effect
    local grateTransparency = 0.7
    local grateCanCollide = false -- Players can walk over/through decorative grates

    -- Example: Place a few grates in the center area
    local halfGrid = gridDimension / 2
    local grateSize = Vector3.new(10, grateHeight, 10)

    -- Grate 1: Center
    local grate1 = GratesBuilder.createModularGrate(
        CFrame.new(0, grateYPosition, 0),
        grateSize,
        grateColor,
        grateTransparency,
        grateCanCollide
    )
    grate1.Parent = parentFolder
    grate1.Name = "Grate_Center"

    -- Grate 2: Offset X
    local grate2 = GratesBuilder.createModularGrate(
        CFrame.new(halfGrid / 2, grateYPosition, 0),
        grateSize,
        grateColor,
        grateTransparency,
        grateCanCollide
    )
    grate2.Parent = parentFolder
    grate2.Name = "Grate_OffsetX"

    -- Grate 3: Offset Z
    local grate3 = GratesBuilder.createModularGrate(
        CFrame.new(0, grateYPosition, -halfGrid / 2),
        grateSize,
        grateColor,
        grateTransparency,
        grateCanCollide
    )
    grate3.Parent = parentFolder
    grate3.Name = "Grate_OffsetZ"

    self.Logger.Info("LevelGenerator: Grate generation complete.", self.Name)
end


-- Future: Function to place specific level elements (objectives, spawn points)
-- function LevelGenerator:placeLevelElements()
--     self.Logger:Info("LevelGenerator: Placing level elements.", self.Name)
--     -- Placement logic here
-- end

return LevelGenerator
