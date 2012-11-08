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
  - npm install node-inspector
  - npm install nib
  - npm install soda

2. cp config.js.sample config.js

3. Change the coffee variable in your config.js file. If in labs, replace USERNAME below, otherwise if at home set it to 'coffee'. Do the same for stylus and jasmine-node.

    module.exports.COFFEE = '/homes/USERNAME/node_modules/coffee-script/bin/coffee';

4. Type 'cake run', which will compile everything and run the server.

5. Open a browser and go to localhost:8080/

6. Add node-inspector to your alias / path. (you did this for cake, coffee, and stylus. Now do it for node-inspector)

7. Make sure you have an alias for selenium server "seleniumrc"
   e.g. alias seleniumrc "java -jar ~/selenium-server-standalone-2.25.0.jar"

For more info, type 'cake'. This will show you available commands.

New! Debugging
==============
1. Make sure you have all the requirements (see steps above). Cqhrome is required (or Safari). Note node-inspector must be in your path/aliases.

2. Open two terminal windows, navigate to the project directory.
  - On terminal window 1, type: 'cake debug'. This will compile everything and start the server for debugging.
  - On terminal window 2, type: 'node-inspector --web-port=8081'
    - This should show you a URL that you should go to in your browser
    - Point your browser to this URL now in a new tab/window.
    - You'll notice the file server.js is open and there's a breakpoint on the first line.

3. Now that you have an inspector open, navigate to localhost:8080, which is where our project is hosted. 

4. Done :) Everything works including the console (note that when you do stuff like 'console.log()', it logs ON THE SERVER and not the log area.)

Compile
=======

The project uses a cakefile to compile the coffeescript stuff.

Go to the project folder and type "cake" for more info. 

If cake isn't found, create an alias for it. It is most likely ~/node_modules/coffee-script/bin/cake.

Game Components
---------------

Game

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
      - make now challenges
      - make never challenges
    - Check solutions
      - Compiler
        - Scanner
        - Grammer
        - Parse table
        - LR parser
    - Draw on their working area
    - Scoring
    - Goal setting
    - Lobby
      - Creating a game
      - Joining a game
      - Starting a game when there are enough players
    - Turns system
      - wait for their turn
      - play their turn
      - moving stuff from mat to mat / user area
      - Timing out    
      - Challenges
        - make now challenges
        - make never challenges
        - Ability to play when someone challenge
    - Unit tests

Tristan's Group
---------------


Sublime Settings for indentation
--------------------------------
go to Preference -> Settings - Default. 

    // The number of spaces a tab is considered equal to


    "tab_size": 2,


    // Set to true to insert spaces when tab is pressed

    "translate_tabs_to_spaces": true,

