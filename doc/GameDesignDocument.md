Lumin: Game Design Document
1. Game Title
Lumin (Derived from "Luminance," emphasizing light and stealth)

2. Core Concept
Lumin is a stealth-puzzle game where players navigate a high-tech facility, completing objectives while meticulously avoiding detection by ever-present, patrolling light sources. The game emphasizes precision movement, environmental awareness, and strategic timing.

3. Game Loop
The core loop of Lumin is designed to be engaging, challenging, and highly replayable:

Objective Briefing: At the start of a round/level, players are given a clear objective (e.g., "Hack Terminal A," "Retrieve Data Chip," "Activate Power Conduit").

Environmental Scan: Players observe the map, identifying light patrol patterns, safe zones, and the optimal path to their objective.

Stealth & Evasion: Players move through the environment, utilizing shadows, cover, and precise timing to avoid being caught by moving light sources (security drones, laser grids, sentinel cameras).

Task Execution: Players reach their objective and perform the required action (e.g., interact with a terminal, pick up an item). These tasks might require them to be exposed for a short duration, adding tension.

Escape/Progression: Once the objective is complete, players must reach an exit point or the next section of the facility.

Round Completion/Elimination:

Success: If the objective is completed and the player escapes, they earn rewards and progress.

Failure: If caught by a light, the player is immediately eliminated and must restart the round (or respawn with a penalty in a multi-round scenario).

4. Key Mechanics
Light Avoidance:

Security Drones: Patrolling entities with visible, often conical, light beams. Their patterns can be fixed or semi-random.

Laser Grids: Static or moving laser barriers that pulse on/off, requiring precise timing to pass through.

Sentinel Cameras: Fixed cameras with sweeping light cones, acting as stationary hazards.

Environmental Lighting: The general ambient light of the map is low, creating clear distinctions between illuminated and shadowed areas. Glowing lines on the floor (like circuitry) provide visual cues and navigation aids without offering cover.

Interaction & Tasks:

Players interact with terminals, buttons, or objects by simply walking up to them and pressing a designated "interact" key (e.g., 'E').

Tasks are designed to be simple but require strategic timing (e.g., standing still for 3 seconds to hack, which makes them vulnerable).

Player Abilities (Optional, for later development):

EMP Pulse: Temporarily disables nearby light sources or slows them down.

Shadow Cloak: Briefly makes the player invisible to light.

Distraction Device: Throws a small object that emits a sound or light burst, drawing a light source's attention away.

Elimination: If a player's hitbox enters a light source's detection zone for a set duration (e.g., 0.5 seconds), they are "caught" and eliminated from the round. A clear visual and audio cue (e.g., a "Caught!" overlay, a siren sound) indicates elimination.

5. Level Design Philosophy
Futuristic Aesthetic: Inspired by Tron, the environment features dark, polished surfaces, glowing neon lines (circuits, pathways), and minimalist structures. This allows the light sources to stand out dramatically.

Modular Design: Levels will be constructed using reusable modules (corridors, rooms, junctions, vents). This significantly reduces development time and allows for easy creation of new levels or variations.

Strategic Layout: Each level is a puzzle. It will feature:

Safe Zones: Areas consistently in shadow or behind solid cover.

Chokepoints: Narrow passages with intense light patrols, requiring precise timing.

Alternative Paths: Vents, hidden passages, or elevated platforms that offer different routes to objectives.

Interactive Elements: Terminals, doors, and objects that are part of the objective.

Visual Cues: The grid on the floor, glowing wall panels, and distinct light cone visuals provide all necessary information to the player without relying on sound.

6. Player Progression & Monetization
In-Game Currency: "Lumin Credits" are earned by successfully completing levels, performing tasks, and surviving rounds.

Cosmetics: The primary monetization strategy will be cosmetic items purchased with Lumin Credits or Robux. These include:

Player Skins: Different futuristic outfits or character models.

Light Trails: Unique particle effects that follow the player.

Interaction Effects: Special visual effects when interacting with terminals.

Emotes: Custom animations.

Leaderboards: Track fastest completion times, most successful escapes, or highest Lumin Credits earned, encouraging replayability and competition.

7. Target Audience
Kids and teens (ages 8-16) who enjoy puzzle games, stealth mechanics, and competitive challenges. The simple controls and clear objectives make it accessible, while the increasing difficulty provides a long-term challenge.

8. Why it's Fun
High Tension: The constant threat of light creates a thrilling, cat-and-mouse dynamic.

Satisfying Evasion: Successfully navigating a complex light pattern feels incredibly rewarding.

Visual Appeal: The Tron-like aesthetic is inherently cool and engaging for the target audience.

Clear Goals: Players always know what they need to do, reducing frustration.

Replayability: Modular levels and potential for randomized light patterns keep the game fresh.

Competitive Edge: Leaderboards and the desire for unique cosmetics drive engagement.

Lumin/
├── doc/
│   ├── DevelopmentStages.md
│   └── GameDesignDocument.md
├── src/
│   ├── client/
│   │   └── init.client.lua
│   ├── server/
│   │   ├── BaseService.lua
│   │   ├── GlobalRegistry.lua
│   │   ├── init.server.lua
│   │   ├── Logger.lua
│   │   └── ServiceRegistry.lua
│   └── shared/
│       └── Constants.lua
├── .gitignore
└── default.project.json