#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>

#define MAX_INVENTORY_SLOTS 16

// Inventory is an array of item IDs (represented as integers)
int inventory[MAX_INVENTORY_SLOTS];

// Room state and context
bool has_explored = false;
bool has_key = false;
bool has_found_exit = false;

// Initialize the inventory with zeroes
void init_inventory() {
    for (int i = 0; i < MAX_INVENTORY_SLOTS; i++) {
        inventory[i] = 0; // 0 means no item in the slot
    }
}

// Add an item to the inventory
bool add_to_inventory(int item_id) {
    for (int i = 0; i < MAX_INVENTORY_SLOTS; i++) {
        if (inventory[i] == 0) { // Find an empty slot
            inventory[i] = item_id; // Add the item to the empty slot
            return true; // Success
        }
    }
    return false; // Inventory full
}

// Show the inventory
void show_inventory() {
    printf("Inventory:\n");
    bool empty = true;
    for (int i = 0; i < MAX_INVENTORY_SLOTS; i++) {
        if (inventory[i] != 0) {
            printf("Item ID: %d\n", inventory[i]); // Print the item ID
            empty = false;
        }
    }
    if (empty) {
        printf("Inventory is empty.\n");
    }
}

// Drop an item from the inventory
bool drop_from_inventory(int item_id) {
    for (int i = 0; i < MAX_INVENTORY_SLOTS; i++) {
        if (inventory[i] == item_id) { // Find the item in the inventory
            inventory[i] = 0; // Remove it (set to 0)
            return true; // Success
        }
    }
    return false; // Item not found
}

// Randomized room descriptions based on exploration
void describe_room() {
    int event = rand() % 3; // Random event for variety
    printf("You are in a dark room with a single flickering light.\n");
    if (!has_explored) {
        printf("There is an old door to the north.\n");
        has_explored = true;
    } else if (event == 0) {
        printf("A faint noise echoes from the distance...\n");
    } else if (event == 1) {
        printf("You feel a cold breeze, and the light flickers more.\n");
    } else if (event == 2) {
        printf("Suddenly, you hear footsteps, but no one is around.\n");
    }
}

// Context-based command list
void list_commands() {
    printf("\nAvailable commands:\n");
    printf("Q - Quit\n");
    printf("I - Show Inventory\n");
    
    if (!has_found_exit) {
        printf("A - Add an Item to Inventory\n");
        printf("D - Drop an Item from Inventory\n");
    }
    
    printf("E - Examine the Room\n");

    if (has_key) {
        printf("U - Use the Key to Unlock the Door\n");
    }

    if (has_found_exit) {
        printf("X - Exit the Room\n");
    }
}

// Examine the room, with possible random events or items
void examine_room() {
    int find_event = rand() % 3; // Random outcome

    describe_room();

    if (find_event == 0 && !has_key) {
        printf("You find a rusty key hidden under some rubble.\n");
        has_key = true;
        add_to_inventory(1); // Add key to inventory
    } else if (find_event == 1) {
        printf("The walls seem to be closing in... but it's just your imagination.\n");
    } else if (find_event == 2 && !has_found_exit) {
        printf("You discover a hidden exit behind the door!\n");
        has_found_exit = true;
    }
}

// Use the key if the player has it
void use_key() {
    if (has_key) {
        printf("You use the rusty key to unlock the door. It creaks open slowly...\n");
        has_found_exit = true;
    } else {
        printf("You don't have the key!\n");
    }
}

// Exit the room if the player has unlocked the door
void exit_room() {
    if (has_found_exit) {
        printf("You exit the room and step into the unknown...\n");
        printf("Congratulations, you've completed this part of the game!\n");
        exit(0); // End the game
    } else {
        printf("The door is still locked. You need to unlock it first!\n");
    }
}

// Game loop
void game_loop() {
    char input;
    int item_id;

    while (1) {
        list_commands();
        printf("\nWhat would you like to do? ");
        
        input = getchar(); // Get user input
        getchar(); // Capture newline
        
        switch (input) {
            case 'Q':
            case 'q':
                printf("Goodbye!\n");
                return; // Exit the game loop

            case 'I':
            case 'i':
                show_inventory();
                break;

            case 'A':
            case 'a':
                if (!has_found_exit) {
                    printf("Enter the item ID to add: ");
                    scanf("%d", &item_id);
                    getchar(); // Capture newline after number input
                    if (add_to_inventory(item_id)) {
                        printf("Item %d added to inventory.\n", item_id);
                    } else {
                        printf("Inventory full! Couldn't add item %d.\n", item_id);
                    }
                } else {
                    printf("You can't add items now, focus on escaping!\n");
                }
                break;

            case 'D':
            case 'd':
                if (!has_found_exit) {
                    printf("Enter the item ID to drop: ");
                    scanf("%d", &item_id);
                    getchar(); // Capture newline after number input
                    if (drop_from_inventory(item_id)) {
                        printf("Item %d removed from inventory.\n", item_id);
                    } else {
                        printf("Item %d not found in inventory.\n", item_id);
                    }
                } else {
                    printf("You can't drop items now, focus on escaping!\n");
                }
                break;

            case 'E':
            case 'e':
                examine_room();
                break;

            case 'U':
            case 'u':
                use_key();
                break;

            case 'X':
            case 'x':
                exit_room();
                break;

            default:
                printf("Unknown command. Try again.\n");
        }
    }
}

// Initialize the game
void init_game() {
    srand(time(0)); // Seed for random events
    init_inventory();
}

// Start the game
int main() {
    init_game();
    game_loop();
    return 0;
}
