Lumin: Development Stages
Building Lumin will be approached in distinct phases, ensuring a stable foundation before adding complexity. This modular approach aligns with your request for separate systems and maintainability.

Phase 1: Core Systems & Basic Gameplay Loop (MVP - Minimum Viable Product)
Goal: Establish the fundamental architecture, logging, constants, and a single, playable "avoid the light" loop in a basic environment.

1.1 Project Setup & Core Architecture:

Set up Roblox Studio project structure (Folders for Services, Managers, Modules, UI, Assets).

Implement Constants module (Lua script).

Implement Logger module (Lua script).

Implement BaseService module (Lua script).

Implement ServiceRegistry module (Lua script).

Implement GlobalRegistry module (Lua script).

Implement DataManager (basic local data saving/loading for settings).

Implement ObjectPool (for lights/effects).

Implement StateValidator (basic validation for game states).

Implement NetworkManager (basic client-server communication setup).

1.2 Basic Arena & Light System:

Create a simple, flat, dark arena (a single Part or MeshPart).

Implement a single "Security Drone" light source:

Basic model (e.g., a simple Part with a SpotLight attached).

Simple, fixed linear patrol path.

Detection logic: If player's hitbox enters light cone, trigger "caught" event.

Implement basic player character:

Standard Roblox character.

Movement controls.

Basic "Caught" mechanic: Player is eliminated (e.g., teleported back to spawn).

1.3 Game Flow (Single Player):

Start/Restart round logic.

Win/Loss condition (e.g., survive for X seconds, or get caught).

Basic UI for "Caught!" message.

Phase 2: Level Design & Asset Integration
Goal: Create the initial futuristic visual style and a more complex, puzzle-oriented level.

2.1 Visual Assets:

Design and import modular assets for the futuristic facility (walls, floors with glowing lines, grates, terminals).

Refine Security Drone models and light effects.

Create visual effects for "Caught!" (e.g., a digital dissolve).

2.2 Level 1 Construction:

Build the first full level using the modular assets.

Integrate multiple Security Drones with varied patrol patterns.

Add static hazards (e.g., simple laser grids that pulse on/off).

Place a simple objective (e.g., a single hackable terminal).

2.3 Environmental Interaction:

Implement basic interaction with the objective (e.g., 'E' to hack).

Add visual feedback for interaction (e.g., glowing terminal, progress bar UI).

Phase 3: Player Abilities & UI Refinements
Goal: Introduce player abilities and enhance the user interface for a more polished experience.

3.1 Ability System:

Implement the "Shadow Dash" ability (teleport a short distance).

Implement a basic cooldown/charge meter UI for abilities.

3.2 Core UI:

Main menu UI (Play, Settings, Shop).

In-game HUD (objective tracker, ability cooldowns).

End-of-round screen (Win/Loss, Lumin Credits earned).

3.3 Sound Design (Optional, but recommended for immersion):

Basic ambient futuristic sounds.

Sound effects for light detection, interaction, and abilities.

Phase 4: Polish, Progression & Monetization
Goal: Add depth, replayability, and the core monetization loop.

4.1 Progression System:

Implement Lumin Credits currency system.

Basic data saving/loading for player currency and unlocked items.

Shop UI for purchasing cosmetic items.

Implement cosmetic items (e.g., light trails, simple skins).

4.2 Additional Levels/Hazards:

Create 1-2 more levels with increasing difficulty.

Introduce new light types (e.g., Sentinel Cameras).

4.3 Leaderboards:

Implement basic in-game leaderboards (e.g., fastest completion times for each level).

Phase 5: Testing & Release
Goal: Ensure stability, performance, and a smooth player experience.

5.1 Extensive Playtesting:

Internal testing for bugs, exploits, and balance issues.

Gather feedback on gameplay, difficulty, and fun factor.

5.2 Performance Optimization:

Profile game performance (scripts, rendering, network).

Optimize code and assets to ensure smooth gameplay on various devices.

5.3 Bug Fixing & Iteration:

Address all identified bugs and refine mechanics based on feedback.

5.4 Release Preparation:

Set up game page, icon, and thumbnails.

Marketing and community engagement plan.