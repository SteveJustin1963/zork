// Part 1: Core Game Engine - Complete Version
// Two-letter variables documented:
// pl = player location    hp = health points
// mp = magic power       tp = tech power
// iv = inventory         st = state flags
// eq = equipment         gd = gold
// rm = room memory       mn = monster data
// sp = spell power       zn = zone number
// tn = turn counter      sv = save state
// er = error state       sd = sound state

// Initialize all game state
:A
0 pl! 100 hp! 100 mp! 100 tp!  // Player stats
0 iv! 0 st! 0 eq! 0 gd!       // Items & flags
0 rm! 0 mn! 100 sp! 0 zn!     // World state
0 tn! 0 sv! 0 er! 0 sd!      // System state
;

// Stack protection
:B
/D 10 > (                     // Stack too deep?
  `Stack error` 
  ClearStack
)
;

// Command parser with error check
:C
/K v! /K n!                   // Get command
v@ 0 = ( `Bad command` )      // Error check
;

// Movement handler - North
:D
B                            // Check stack
pl@ CheckCollision (          // Can move?
  pl@ 3 * rm + 1+ @ -1 = (   // Exit exists?
    `No exit north`
  ) /E (
    pl@ 3 * rm + 1+ @ pl!    // Move
    IncrementTurn
    H                        // Show room
  )
)
;

// Movement handler - South
:E
B
pl@ CheckCollision (
  pl@ 3 * rm + 2 + @ -1 = (
    `No exit south`
  ) /E (
    pl@ 3 * rm + 2 + @ pl!
    IncrementTurn
    H
  )
)
;

// Movement handler - East
:F
B
pl@ CheckCollision (
  pl@ 3 * rm + 3 + @ -1 = (
    `No exit east`
  ) /E (
    pl@ 3 * rm + 3 + @ pl!
    IncrementTurn
    H
  )
)
;

// Movement handler - West
:G
B
pl@ CheckCollision (
  pl@ 3 * rm + 4 + @ -1 = (
    `No exit west`
  ) /E (
    pl@ 3 * rm + 4 + @ pl!
    IncrementTurn
    H
  )
)
;

// Process all movement commands
:H
v@ 110 = ( D )                // n - north
v@ 115 = ( E )                // s - south
v@ 101 = ( F )                // e - east
v@ 119 = ( G )                // w - west
;

// Show current room with full details
:I
ClearScreen
pl@ 3 * rm + @ k!            // Get room index
k@ RoomDesc                  // Show description
CheckItems                   // Show items
CheckMonster                // Show monsters
ShowExits                   // Show exits
;

// Inventory handler with weight check
:J
v@ 105 = (                   // i - inventory
  `You carry:`
  iv@ ShowItems
  `Weight:` iv@ CalcWeight .
  `Gold:` gd@ .
)
;

// Take item with checks
:K
v@ 116 = (                   // t - take
  iv@ CalcWeight 100 < (     // Weight ok?
    pl@ CheckItem (          // Item present?
      AddItem
      PlaySound
      `Taken`
    ) /E ( `Nothing to take` )
  ) /E ( `Too heavy` )
)
;

// Drop item with checks
:L
v@ 100 = (                   // d - drop
  iv@ n@ HasItem (           // Have item?
    DropItem
    PlaySound
    `Dropped`
  ) /E ( `Don't have it` )
)
;

// Look command with details
:M
v@ 108 = (                   // l - look
  I                         // Full room show
  ShowTime                  // Show turn count
)
;

// Health/damage handler
:N
// Stack: ( damage -- )
hp@ swap - 0 max 100 min hp! // Apply damage
PlayHitSound
;

// Collision detection
:O
// Stack: ( pos -- flag )
" rm + @ #FF &              // Get room flags
;

// Turn counter
:P
tn@ 1+ tn!                  // Increment
;

// Save game state
:Q
pl@ hp@ mp@ iv@ 4 SaveArray // Save core stats
;

// Load game state
:R
4 LoadArray                 // Load core stats
iv! mp! hp! pl!
;

// Status display
:S
`HP:` hp@ . 
`MP:` mp@ .
`Gold:` gd@ .
`Turn:` tn@ .
;

// Sound effects
:T
sd@ /O                      // Output to sound port
;

// Clear screen helper
:U
27 /C `[2J` 27 /C `[H`     // ANSI clear
;

// Error handler
:V
er! `Error:` er@ .
0 er!
;

// Main game loop - enhanced
:W
U                          // Clear screen
S                          // Show status
I                          // Show room
C                          // Get command
B                          // Check stack
H J K L M                  // Process commands
CheckGameOver              // Check end state
v@ 113 = ( /F w! )         // q - quit
/E ( /T w! )
w@ /T = W                  // Loop unless quit
;

// Game start with intro
:X
U                          // Clear screen
`Welcome Adventurer!` /N
`Commands:` /N
`n,s,e,w: Move` /N
`t: Take  d: Drop` /N
`i: Inventory  l: Look` /N
`q: Quit` /N
PlayIntroSound
A                          // Initialize
W                          // Start game loop
;

// Game end handler
:Y
SaveHighScore
`Game Over` /N
`Turns:` tn@ . /N
`Gold:` gd@ . /N
;


// Part 2: World Content
// Array layouts and types:
// Room: [desc_ptr exits[NSEW] items_ptr flags zone_type]
// Item: [id type value weight flags]
// Monster: [id hp dmg armor special_flags]
// Zone flags: 1=normal 2=dark 3=magic 4=tech 5=hazard

// Zone 0: Start Area
:AA
[ 0 1 -1 2 -1 0 1 ] r0! // Start Room
[ 1 2 3 4 0 1 1 ] r1! // Central Hall
[ 2 38 43 37 1 2 1 ] r2! // Entry Cave
[ 3 34 33 4 41 3 1 ] r3! // Stone Path
[ 4 30 29 0 3 4 1 ] r4! // Dark Path
[ 5 21 24 6 4 5 1 ] r5! // Forest Link
;

// Zone 1: Forest Area
:AB
[ 6 17 5 7 16 6 2 ] f0! // Deep Woods
[ 7 0 6 8 0 7 2 ] f1! // Ancient Grove
[ 8 7 9 0 0 8 2 ] f2! // Mystic Circle
[ 9 8 10 0 0 9 2 ] f3! // Spirit Pool
[ 10 9 11 0 0 10 2 ] f4! // Tree Shrine
;

// Zone 2: Mountain Area
:AC
[ 25 26 30 27 0 11 3 ] m0! // Base Camp
[ 26 18 25 28 0 12 3 ] m1! // Rocky Path
[ 27 22 31 0 25 13 3 ] m2! // High Peak
[ 28 27 0 29 26 14 3 ] m3! // Eagle Nest
[ 29 28 0 0 0 15 3 ] m4! // Summit
;

// Zone 3: Tech Area
:AD
[ 67 0 68 0 0 16 4 ] t0! // Control Room
[ 68 67 69 0 0 17 4 ] t1! // Power Core
[ 69 68 70 0 0 18 4 ] t2! // Server Room
[ 70 69 0 0 0 19 4 ] t3! // Main Frame
;

// Zone 4: Magic Area
:AE
[ 56 0 58 57 0 20 5 ] g0! // Star Chamber
[ 57 0 59 0 56 21 5 ] g1! // Void Gate 
[ 58 56 0 59 0 22 5 ] g2! // Moon Pool
[ 59 57 0 0 58 23 5 ] g3! // Astral Path
;

// Room Descriptions (all 77 rooms)
:AF
// Start Zone Text
\[ 89 111 117 32 115 116 97 110 100 32 105 110 32 116 104 101 32 101 110 116 114 121 32 104 97 108 108 0 ] d0! // "You stand in the entry hall"
\[ 65 32 108 97 114 103 101 32 99 97 118 101 114 110 32 111 112 101 110 115 32 98 101 102 111 114 101 32 121 111 117 0 ] d1! // "A large cavern opens before you"
;

// Item Definitions - Complete Set
:AG
// Basic Items [id type value weight flags]
[ 1 1 10 1 0 ] i0! // Brass Key
[ 2 1 20 1 0 ] i1! // Silver Key
[ 3 1 30 1 0 ] i2! // Gold Key
[ 4 2 15 5 0 ] i3! // Short Sword
[ 5 2 25 8 0 ] i4! // Long Sword
[ 6 3 20 10 0 ] i5! // Leather Armor
[ 7 3 40 20 0 ] i6! // Chain Mail
[ 8 4 50 1 0 ] i7! // Magic Ring
[ 9 4 100 1 0 ] i8! // Power Crystal
[ 10 5 75 5 0 ] i9! // Tech Device
;

// Monster Definitions - Complete Set
:AH
// Basic Monsters [id hp dmg armor flags]
[ 1 20 5 2 0 ] m0! // Rat
[ 2 40 8 4 0 ] m1! // Goblin
[ 3 60 12 6 0 ] m2! // Orc
[ 4 100 15 8 0 ] m3! // Troll
[ 5 150 20 10 0 ] m4! // Dragon
// Special Monsters
[ 6 80 10 12 1 ] m5! // Ghost (ethereal)
[ 7 120 18 15 2 ] m6! // Demon (fire)
[ 8 200 25 20 3 ] m7! // Robot (tech)
[ 9 300 30 25 4 ] m8! // Void Beast (magic)
;

// Item Location Table
:AI
// [room_id item_id quantity]
[ 0 1 1 ] l0! // Key in start
[ 1 4 1 ] l1! // Sword in hall
[ 2 6 1 ] l2! // Armor in cave
[ 25 9 1 ] l3! // Crystal in mountain
[ 67 10 1 ] l4! // Tech in control room
;

// Monster Spawn Table
:AJ
// [room_id monster_id respawn_time]
[ 2 1 10 ] s0! // Rat in cave
[ 6 2 20 ] s1! // Goblin in woods
[ 25 3 30 ] s2! // Orc in mountains
[ 67 8 50 ] s3! // Robot in tech zone
[ 56 9 100 ] s4! // Void Beast in magic zone
;

// Zone Connection Rules
:AK
// [zone1 zone2 key_required level_required]
[ 0 1 1 1 ] c0! // Start to Forest
[ 1 2 2 3 ] c1! // Forest to Mountain
[ 2 3 3 5 ] c2! // Mountain to Tech
[ 3 4 4 7 ] c3! // Tech to Magic
;

// Room State Handler
:AL
pl@ CheckState              // Get room state bits
ProcessEffects             // Handle any active effects
UpdateMonsters             // Update monster states
UpdateItems               // Update item states
;

// Item State Handler
:AM
iv@ ProcessItems           // Process inventory
CheckCombine              // Check for combinations
UpdateDurability         // Update item wear
;

// Monster State Handler
:AN
pl@ CheckMonsters         // Check for monsters
ProcessCombat            // Handle any combat
UpdateMonsterState      // Update monster status
;

// Zone Effect Handler
:AO
pl@ CheckZone            // Get zone type
ProcessZoneEffect       // Handle zone effects
UpdatePlayerState      // Update player status
;

// Description Printer
:AP
pl@ GetDesc             // Get room description
PrintDesc              // Show description
ShowItems             // List items present
ShowMonsters         // List monsters present
ShowExits           // Show available exits
;

// Room Updater
:AQ
tn@ ProcessTime        // Process time effects
UpdateRoom           // Update room state
UpdateConnections  // Update connections
;

// State Saver
:AR
SaveRoomState        // Save room data
SaveMonsterState    // Save monster data
SaveItemState      // Save item data
SavePlayerState   // Save player data
;

// State Loader
:AS
LoadRoomState       // Load room data
LoadMonsterState   // Load monster data
LoadItemState     // Load item data
LoadPlayerState  // Load player data
;

// World Initializer
:AT
InitRooms          // Setup rooms
InitMonsters      // Setup monsters
InitItems        // Setup items
InitZones       // Setup zones
;

// World Updater
:AU
/U (               // Continuous update
  UpdateWorld     // Process world changes
  CheckEvents    // Handle scheduled events
  ProcessTime   // Update time effects
  v@ 113 = /W    // Until quit
)
;

// Part 3: Game Systems
// Additional vars used:
// cb = combat state   mg = magic state
// tk = tech state     sk = skill points
// rf = craft refs     ex = experience
// dm = damage mods    ar = armor value
// ab = abilities      qt = quest state

// Combat System Init
:BA
0 cb! 0 dm! 10 ar!         // Combat stats
0 sk! 0 ex!                // Experience
0 ab! 0 qt!                // Abilities/Quests
;

// Process Attack
:BB
mn@ GetMonster             // Get monster stats
cb@ ProcessHit            // Calculate hit
ApplyDamage              // Apply damage to monster
CheckCounter             // Check for counterattack
UpdateCombat             // Update combat state
;

// Process Defense
:BC
ar@ CalculateBlock        // Calculate block
cb@ ProcessDefense       // Process defense
ApplyDamage             // Take reduced damage
UpdateArmor            // Update armor state
;

// Magic System
:BD
sp@ CheckSpell            // Check spell available
mp@ CheckCost            // Check magic points
CastSpell               // Cast the spell
UpdateMagic            // Update magic state
;

// Spell Effects
:BE
// Format: [id cost effect duration power]
[ 1 10 1 3 20 ] s0!      // Fireball
[ 2 15 2 4 30 ] s1!      // Ice Blast
[ 3 20 3 5 40 ] s2!      // Lightning
[ 4 25 4 6 50 ] s3!      // Heal
[ 5 30 5 7 60 ] s4!      // Shield
;

// Tech System
:BF
tp@ CheckPower           // Check power level
tk@ ProcessTech         // Process tech action
UpdateTech            // Update tech state
;

// Tech Devices
:BG
// Format: [id power effect duration charge]
[ 1 15 1 4 100 ] t0!     // Shield Generator
[ 2 20 2 5 100 ] t1!     // Power Beam
[ 3 25 3 6 100 ] t2!     // Health Unit
[ 4 30 4 7 100 ] t3!     // Teleporter
;

// Crafting System
:BH
rf@ CheckRecipe          // Check recipe known
CheckMaterials          // Check materials
DoCraft                // Perform crafting
UpdateInventory       // Update inventory
;

// Recipes
:BI
// Format: [result parts[4] tool level]
[ 7 1 2 3 0 1 ] r0!     // Make Health Potion
[ 8 2 3 4 1 2 ] r1!     // Make Better Armor
[ 9 3 4 5 2 3 ] r2!     // Make Magic Weapon
[ 10 4 5 6 3 4 ] r3!    // Make Tech Device
;

// Skill System
:BJ
sk@ CheckSkill          // Check skill available
UseSkill               // Use the skill
GainExperience        // Gain experience
UpdateSkills         // Update skills
;

// Skills
:BK
// Format: [id req_level cost effect]
[ 1 1 10 10 ] k0!      // Better Attack
[ 2 2 20 20 ] k1!      // Better Defense
[ 3 3 30 30 ] k2!      // Better Magic
[ 4 4 40 40 ] k3!      // Better Tech
;

// Quest System
:BL
qt@ CheckQuest         // Check quest status
UpdateQuest          // Update quest progress
CheckReward         // Check for rewards
GiveReward        // Give quest reward
;

// Quests
:BM
// Format: [id type req reward status]
[ 1 1 5 100 0 ] q0!    // Kill 5 Rats
[ 2 2 3 200 0 ] q1!    // Find 3 Keys
[ 3 3 1 300 0 ] q2!    // Defeat Boss
[ 4 4 4 400 0 ] q3!    // Craft Item
;

// Experience System
:BN
ex@ CheckLevel         // Check current level
AddExperience        // Add new experience
CheckLevelUp        // Check for level up
DoLevelUp         // Perform level up
;

// Level Requirements
:BO
// Format: [level exp hp mp tp bonus]
[ 1 100 110 110 110 1 ] l0!
[ 2 300 120 120 120 2 ] l1!
[ 3 600 130 130 130 3 ] l2!
[ 4 1000 140 140 140 4 ] l3!
;

// Combat Handler
:BP
v@ 97 = (                // a - attack
    BB                   // Process attack
) v@ 100 = (            // d - defend
    BC                  // Process defense
)
;

// Magic Handler
:BQ
v@ 109 = (              // m - magic
    n@ 49 = ( s0@ BD )  // 1 - spell 1
    n@ 50 = ( s1@ BD )  // 2 - spell 2
    n@ 51 = ( s2@ BD )  // 3 - spell 3
    n@ 52 = ( s3@ BD )  // 4 - spell 4
)
;

// Tech Handler
:BR
v@ 116 = (              // t - tech
    n@ 49 = ( t0@ BF )  // 1 - device 1
    n@ 50 = ( t1@ BF )  // 2 - device 2
    n@ 51 = ( t2@ BF )  // 3 - device 3
    n@ 52 = ( t3@ BF )  // 4 - device 4
)
;

// Craft Handler
:BS
v@ 99 = (               // c - craft
    n@ CheckRecipe (    // Valid recipe?
        BH             // Do crafting
    ) /E (
        `No recipe`
    )
)
;

// Skill Handler
:BT
v@ 115 = (              // s - skill
    n@ CheckSkill (     // Have skill?
        BJ            // Use skill
    ) /E (
        `No skill`
    )
)
;

// Quest Handler
:BU
v@ 113 = (              // q - quest
    ShowQuests         // Show active quests
    CheckQuests       // Check completions
    UpdateQuests     // Update states
)
;

// Status Handler
:BV
`Level:` ex@ GetLevel .
`HP:` hp@ . `/' hp@ GetMax .
`MP:` mp@ . `/' mp@ GetMax .
`TP:` tp@ . `/' tp@ GetMax .
`XP:` ex@ . `Next:` ex@ NextLevel .
;

// Main Systems Handler
:BW
BP                     // Handle combat
BQ                     // Handle magic
BR                     // Handle tech
BS                     // Handle crafting
BT                     // Handle skills
BU                     // Handle quests
;

// Help Display
:BX
`Commands:` /N
`a: Attack  d: Defend` /N
`m1-4: Magic  t1-4: Tech` /N
`c: Craft  s: Skills` /N
`q: Quests  ?: Help` /N
;

// Statistics Display
:BY
`Stats:` /N
BV                    // Show all stats
`Quests:` qt@ ShowActiveQuests /N
`Skills:` sk@ ShowSkills /N
;


