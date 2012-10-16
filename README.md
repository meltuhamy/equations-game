Equations Game Group Project
============================

This is an implementation to the game "Equations" found here: http://www.academicgames.org/games/equations/index.html


Steps to set up:
----------------

1. Install node and CoffeeScript
   node: http://nodejs.org/
   coffeescript: http://coffeescript.org/

2. Copy Cakefile.sample and call it Cakefile
   cp Cakefile.sample Cakefile

3. Change myCoffee variable in Cakefile to point to your coffee compiler file. If not sure, run the command 'whereis coffee'. If not found, you need to install coffeescript. If you did not install CoffeeScript globally (like in Lab Machines), then point to your local node_modules/coffee-script/bin/coffee file.

4. Run the build script. 
   cake build

5. Open test/index.html in the browser to run unit tests.


Compile
=======

The project uses a cakefile to compile the coffeescript stuff.

Go to the project folder and type "cake" for more info. 

If cake isn't found, create an alias for it. It is most likely ~/node_modules/coffee-script/bin/cake.

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


