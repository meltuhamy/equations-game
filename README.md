Equations Game Group Project
============================

This is an implementation to the game "Equations" found here: http://www.academicgames.org/games/equations/index.html
    

Steps to set up:
----------------

1. Install node (http://nodejs.org/) and these things (add -g if not in labs): 
  - npm install coffee-script
  - npm install express
  - npm install socket.io
  - npm install now
  - npm install stylus
  - npm install jasmine-node

2. cp config.js.sample config.js

3. Change the coffee variable in your config.js file. If in labs, replace USERNAME below, otherwise if at home set it to 'coffee'. Do the same for stylus and jasmine-node.

    module.exports.COFFEE = '/homes/USERNAME/node_modules/coffee-script/bin/coffee';

4. Type 'cake run', which will compile everything and run the server.

5. Open a browser and go to localhost:8080/


For more info, type 'cake'. This will show you available commands.

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

Sublime Settings for indentation
--------------------------------
go to Preference -> Settings - Default. 

    // The number of spaces a tab is considered equal to


    "tab_size": 2,


    // Set to true to insert spaces when tab is pressed

    "translate_tabs_to_spaces": true,

