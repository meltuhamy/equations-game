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


Compile
=======

The project uses a cakefile to compile the coffeescript stuff.

Go to the project folder and type "cake" for more info. 

If cake isn't found, create an alias for it. It is most likely ~/node_modules/coffee-script/bin/cake.