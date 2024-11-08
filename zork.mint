// Core game state variables
// l=location, h=health, i=inventory bitmap, f=flags, s=score
// p=power level (tech zones), m=magic power (astral zones)
// z=current zone, t=temp variable
:A
0 l! 100 h! 0 i! 0 f! 0 s! 100 p! 100 m! 0 z! 0 t!
;

// Zone 0 (Start Area) rooms [desc exits[NSEW] items flags]
:B
[ 0 6 4 25 0 1 0 ] z0! // Start room
[ 1 2 3 4 0 2 0 ] z1! // Initial paths
;

// Zone 1 (Underground) rooms
:C
[ 37 2 1 38 43 2 0 ] u0!
[ 40 1 43 41 46 3 0 ] u1!
;

// Zone 2 (Frozen) rooms
:D
[ 9 10 8 12 7 3 0 ] f0!
[ 8 14 7 12 13 4 0 ] f1!
;

// Item definitions [id location type value weight]
:E
[ 1 0 1 10 5 ] i0! // Lamp
[ 2 13 2 50 2 ] i1! // Ice Key
[ 3 27 3 100 8 ] i2! // Magic Sword
;

// Room descriptions (byte arrays for memory efficiency)
:F
\[ 89 111 117 32 97 114 101 32 105 110 32 116 104 101 32 83 116 97 114 116 32 82 111 111 109 ] d0!
;

// Parse input - store command in c, object in o
:G
/K c!
/K o!
;

// Movement handler
:H
c@ 110 = ( // 'n' north
  l@ z@ + 1+ @ -1 = (
    `No exit that way`
  ) /E (
    l@ z@ + 1+ @ l!
    R // Print room
  )
) c@ 115 = ( // 's' south
  l@ z@ + 2+ @ -1 = (
    `No exit that way`
  ) /E (
    l@ z@ + 2+ @ l!
    R
  )
) c@ 101 = ( // 'e' east
  l@ z@ + 3 + @ -1 = (
    `No exit that way`
  ) /E (
    l@ z@ + 3 + @ l!
    R
  )
) c@ 119 = ( // 'w' west
  l@ z@ + 4 + @ -1 = (
    `No exit that way`
  ) /E (
    l@ z@ + 4 + @ l!
    R
  )
)
;

// Inventory management
:I
c@ 105 = ( // 'i' inventory
  `You carry:` /N
  i@ 1 & ( `Lamp` /N )
  i@ 2 & ( `Ice Key` /N )
  i@ 4 & ( `Magic Sword` /N )
)
;

// Take item
:J
c@ 116 = ( // 't' take
  o@ 108 = ( // 'l' lamp
    l@ 0 = ( // In start room
      i@ 1 | i!
      `Taken`
    ) /E ( `No lamp here` )
  )
)
;

// Drop item
:K
c@ 100 = ( // 'd' drop
  o@ 108 = ( // 'l' lamp
    i@ 1 & (
      i@ 1 ~ & i!
      `Dropped`
    ) /E ( `Don't have it` )
  )
)
;

// Look at room/item
:L
c@ 108 = ( // 'l' look
  R // Print room description
  l@ z@ + 5 + @ ( // Check for items
    `You see:`
    l@ z@ + 5 + @ T // Print items
  )
)
;

// Combat system
:M
c@ 97 = ( // 'a' attack
  l@ e@ ( // Enemy present
    h@ 10 - h! // Take damage
    `You fight!`
  ) /E ( `Nothing to attack` )
)
;

// Power/tech handling
:N
c@ 112 = ( // 'p' power
  l@ 72 = ( // In power core
    p@ 20 + p!
    `Power increased`
  )
)
;

// Magic system
:O
c@ 109 = ( // 'm' magic
  m@ 10 > (
    m@ 10 - m!
    `Magic cast`
  ) /E ( `Low magic` )
)
;

// Print room description
:R
l@ \[ d0 d1 d2 ] @ /S ( /C ) /N
;

// Room state handler
:S
l@ 56 = ( // Star Chamber
  f@ 1 | f! // Set astral flag
)
;

// Item lister
:T
t@ i@ & (
  t@ 1 = ( `Lamp` )
  t@ 2 = ( `Key` )
  t@ 4 = ( `Sword` )
)
;

// Environmental effects
:U
l@ 19 = ( // Eagle Nest
  h@ 2 / h!
  `Thin air hurts`
)
l@ 39 = ( // Swamp Heart
  h@ 10 + 100 < ( h@ 10 + h! )
  `Feel restored`
)
;

// Main command router
:V
G // Get input
H I J K L M N O // Route command
S U // Check states
;

// Main game loop
:W
l@ R // Show room
`Command?`
V
c@ 113 = ( // 'q' quit
  /F w!
) /E (
  /T w!
)
w@ /T = W
;

// Game start
:X
`Welcome to the Complex Realm`
/N
`Commands: n,s,e,w=move l=look`
/N
`i=inventory t=take d=drop`
/N
`a=attack m=magic p=power`
/N
`q=quit`
/N
A // Initialize
W // Start game
;

// Interrupt handler (required by MINT)
:Z
`Game Paused`
;
