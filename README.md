Equations Game Group Project
============================

This is an implementation to the game "Equations" found here: http://www.academicgames.org/games/equations/index.html


Steps to set up:
----------------

1. Install node and CoffeeScript
   node: http://nodejs.org/
   coffeescript: http://coffeescript.org/

2. Copy build.sh.sample and call it build.sh
   cp build.sh.sample build.sh

3. Change COFFEE variable in build.sh to point to your coffee compiler file. If not sure, run the command 'whereis coffee'. If not found, you need to install coffeescript. If you did not install CoffeeScript globally (like in Lab Machines), then point to your local node_modules/coffee-script/bin/coffee file.

4. Run the build script. 
   sh build.sh

5. Open test/index.html in the browser to run unit tests.

Game Components
---------------

Game
 - Compiler
 	- Scanner
 	- Grammer
 	- Parse table
 	- LR parser
 	- Unit tests
 - Rest of game
 	- Networking
 		- System architecture design
 		- Synchronisations
 		
 	- UI
 		- Draggin & dropping
 		- Graphics (html,css,etc)
 			- Dice
 			- Mats
 			- Challenge buttons
 			- Timer
 			- Profile picture layouts
 			- Tips (tutorial mode)
 		- Equations box
 		- Drawing pad
 		- Timer
 		- Profile pics
 	- Game logic
 		- Challenges
 		- Equation equality
 		- Scoring
 		- Goal setting
 		- Turns system
 		- Unit tests



