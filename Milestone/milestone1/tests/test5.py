player_health = 100
player_gold = 0
game_over = False

def encounter_dragon():
    global player_health
    global player_gold
    global game_over
    print("You have encountered a dragon!")
    print("What would you like to do?")
    print("1. Fight")
    print("2. Run")
    choice = 1 #Given test input 
    if choice == 1:
        player_health -= 50
        print("You fought the dragon and lost 50 health")
    elif choice == 2:
        player_gold -= 50
        print("You ran and lost 50 gold")
    if player_health <= 0 or player_gold <= 0:
        game_over = True
        print("Game over")

def find_treasure():
    global player_gold
    print("You found a treasure chest!")
    player_gold += 50
    print("You now have", player_gold, "gold")

def rest():
    global player_health
    print("You find a place to rest")
    player_health += 20
    print("You feel refreshed, now you have", player_health, "health")

def main():
    global game_over
    while not game_over:

        print("What would you like to do?")
        print("1. Explore the forest")
        print("2. Rest")
        print("3. quit")
        action = 1
        if action == 1:
            encounter = 'dragon' #Given test input
            if encounter == 'dragon':
                encounter_dragon()
            else:
                find_treasure()
        elif action == 2:
            rest()
        elif action == 3:
            game_over = True
            print("Game over! You quit the game")
        else: 
            print("Invalid input")

if __name__=="__main__":
    print(" Welcome to the game")
    main()
