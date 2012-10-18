Equations Game Group Project
============================

This is an implementation to the game "Equations" found here: http://www.academicgames.org/games/equations/index.html

Sublime Settings for indentation
--------------------------------
go to Preference -> Settings - Default. 

    // The number of spaces a tab is considered equal to


    "tab_size": 2,


    // Set to true to insert spaces when tab is pressed

    "translate_tabs_to_spaces": true,

    

Steps to set up:
----------------

1. Install node (http://nodejs.org/) and these things (add -g if not in labs): 
  - npm install coffee-script
  - npm install express
  - npm install socket.io
  - npm install now
  - npm install node.js

2. cp config.js.sample config.js

3. Change the coffee variable in your config.js file. If in labs, replace USERNAME below, otherwise if at home set it to 'coffee'
    module.exports.COFFEE = '/homes/USERNAME/node_modules/coffee-script/bin/coffee';

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


