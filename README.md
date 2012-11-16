Equations Game Group Project
============================

This is an implementation to the game "Equations" found here: http://www.academicgames.org/games/equations/index.html
    
User Stories and requirements
=============================
This is done in trello.

1. Go to https://trello.com/equationsgroupproject
2. Create an account and tell me to add you.

(NEW!) Using iMacros to speed up testing
----------------------------------------
1. Make sure you're using Google Chrome
2. Install the iMacros chrome extension http://goo.gl/BR3KC
3. Right click on the iMacros icon (beside address bar). Click 'Options'
4. Change the "Macros directory path" to the path in your project folder (there is now an iMacros folder in the project directory. Use that.)
5. Click the iMacros icon and double click on a macro to run it. (OnePlusTwoStart expects a new window with 1 tab to work properly)

Steps to set up:
================

1. Install node (http://nodejs.org/)
2. npm install coffee-script
2.5 Udara, yes you. Remember to install selenium
3. Add aliases for cake and coffeescript. gedit ~/.cshrc

    alias coffee "~/node_modules/coffee-script/bin/coffee"
    
    alias cake "~/node_modules/coffee-script/bin/cake"

4. Restart terminal and execute the command: cake setup
5. **Follow instructions** after dependencies have finished installing.

Debugging
---------
1. Make sure you have all the requirements (see steps above). Chrome is required (or Safari). Note node-inspector must be in your path/aliases.

2. Open two terminal windows, navigate to the project directory.
  - On terminal window 1, type: 'cake debug'. This will compile everything and start the server for debugging.
  - On terminal window 2, type: 'node-inspector'
    - This should show you a URL that you should go to in your browser
    - Point your browser to this URL now in a new tab/window.
    - You'll notice the file server.js is open and there's a breakpoint on the first line.

3. Now that you have an inspector open, navigate to localhost:8080, which is where our project is hosted. 

4. Done :) There is a default break-point at line one.