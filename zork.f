 
\ Define constants for room properties
VARIABLE room-description
VARIABLE room-exits
VARIABLE room-items
VARIABLE room-visited
VARIABLE room-custom-field

\ Number of inventory slots
16 CONSTANT max-inventory-slots

\ The inventory is just a list of item IDs
CREATE inventory max-inventory-slots CELLS ALLOT

\ Initialize inventory with zeroes
: init-inventory ( -- )
  max-inventory-slots 0 DO
    0 inventory I CELLS + !
  LOOP ;

\ Add an item to the inventory
: add-to-inventory ( n -- flag )
  max-inventory-slots 0 DO
    inventory I CELLS + @ 0= IF
      inventory I CELLS + !
      TRUE EXIT
    THEN
  LOOP
  FALSE ;

\ Show the inventory
: show-inventory ( -- )
  ." Inventory:" CR
  max-inventory-slots 0 DO
    inventory I CELLS + @ ?DUP IF
      . ." " \ Print the item number and a space
    THEN
  LOOP ;

\ Game loop
: game-loop ( -- )
  BEGIN
    CR ." Welcome to Zork!"
    CR ." You are in a dark room."
    CR ." What would you like to do? (Q to quit, I for inventory)"
    KEY DUP EMIT CR

    CASE
      'Q' OF
        CR ." Goodbye!" EXIT
      ENDOF
      
      'I' OF
        show-inventory
      ENDOF
      \ ... more commands here ...
    ENDCASE
  AGAIN ;

\ Initialize the game
: init-game ( -- )
  init-inventory ;

\ Start the game
init-game game-loop
 
