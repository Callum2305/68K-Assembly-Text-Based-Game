# 68K-Assembly-Text-Based-Game
This was my first project using assembly. In this project, I created a text based adventure game using Motorola 68K assembly. 

This is a text based game, following the theme of Alternative Physics. As I have never made a game before, or play any, I did struggle to plan the game out, as I do not know how they are to be made.
However, as this was a project given in my Assembly and C module, I had to make come up with something. So to focus on the actual programming side, I chose to make a very simple story and just implement a game that would showcase different features of 68K Assembly.


Ive decided to make a game with a good and bad ending. The idea of Alternative physics here is that if you get too light, you float away. So I will have a mass counter. If you mass drops below 40, you float away into space, dooming yourself.
To increase mass, you must collect items/scrap to weigh you down. There will be enemy's that drop items, and if they hit you, they can steal items.

Opening message:
"15 years ago, the planet reached its limit. Years of extraction of resources from the planets crust have finally caught up. The gravity started to wain, and now it isn't strong enough to keep you held down. Most people have floated away into the sky above, never to return."
"You, and those others remaining, have survived by fastening heavy scrap into armor that can keep you weighed down enough, however resources are running out. Those left fight for scraps, anything they can take to hold themselves down."
"There are rumors of a band of survivors, iron-clad in scrap metal, who roam the wasteland and protect their own. Maybe if you can fashion a suit of armor like theirs, they will let you join them?"
"Or maybe, someone may come for your resources and leave you unable to keep yourself grounded."

To win, you must play a certain amount of turns, and end up with a mass above 40 mass. Less than 40 mass after any day is a fail state.

Killing an enemy will allow you to take their mass (15 mass), but deduct some health points.

The game will take place over 5 days. At the start of each day you will be presented with two options:

1: Scavenge for items: This allows you to leave base camp and search for scrap to weigh you down, however you may encounter enemy's.

2: Regenerate Health: If you choose to stay in base camp for the day, you can Regenerate health back to 100, avoiding enemies, but also wasting a day.



At the end of each day, if your mass is less than 40 mass, you will float away. If it is equal to or greater than 40 mass, you can survive another day. After 5 days, if you are at 75 mass or above, you will be rescued at the end of day 5, the good ending.
When fighting enemies, you may die if your health reaches 0. This is the only way to get ending 4, the player killed ending.


Ending 1, less than 40 mass at the end of any day:
"You have fought hard for your freedom, but it wasn't enough. What little scrap you could find to weld together into weighted boots wasn't enough. You can feel the weight leave your body as you slowly begin to float upwards. Maybe if you didn't go outside to watch the sunset tonight, you would have been lucky enough to hit the roof, but the sky above you now offers no net to catch you. You are are doomed to be forgotten in the toxic atmosphere above..."
"Game Over. Bad Ending."

Ending 2, equal to or greater than 40 mass, but less than 75 mass:
"You managed to gather what you could and fasten your boots to be heavy enough to weigh you down. You wont float away into an endless void, but now there is no one left but you. What is the point of this struggle if you cant share it with another soul? It seems you are doomed to live your life in this wasteland, barely held down to the ground."
"Game Over. Neutral Ending."

Ending 3, greater than 75 mass:
"You have done it, you have gathered enough scrap to fasten a suit heavy enough to keep you on the ground. You have heard stories in the wasteland of a group of people who walk in iron suits, a brotherhood of sorts. Now you can head out and search for them, perhaps they will take you in so that you may finally have safe company in this god forsaken reality. You should head out tomorrow morning, take what you can and start a new life with purpose."
"Game Over. Good Ending."

Ending 4, only if health reaches 0:
"You delved too deep, met someone stronger. It was kill or be killed, you understood that. Maybe your opponent was like you, struggling to survive. At least your gear may help them, until someone else comes along to take what is theirs, as they have done to you."
"Game Over. Died in combat"

Each stat, health and mass, will be considered as a decimal number, and displayed to the player as such.

How to win:
To check the good ending, follow these steps:

Day 1: Venture out
Day 2: Rest
Day 3: Venture out
Day 4: Venture out
Day 5: Rest

As each day you leave base camp, you will loose 10 vigor points. Each day you can encounter an enemy. The enemy will have different vigor stats each day. These are held in an array, and are of the following values:
ENEMY_HP_TABLE: DC.B 55,65,70,75,85

If you fight each day, your health will decrease each day by 10, leaving you with a health pool of:
                    100, 90, 80, 70, 60

If you rest on the first day, you will have less than 40 mass, as you start off with 30. This leads to the Float away ending/bad ending.


There is also a random event check done after day 3. There are 3 random events that can happen. Each event can only happen once per play through, as two events is denoted with a flag, that is checked to see if it is equal to 0.
If the event flag is set to 0, it means the event hasn't rand yet. Once the event runs, the flag gets set to 1. If the event checker sees that the event has a flag of 1, it will skip.
The third event only has a 1% chance of triggering, and is an instant game over.
Both percentage based events include: mass loss, mass and health increase.
