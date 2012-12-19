*Note:* now.js on Windows doesn't work. This is guide is therefore useless.
=========================================================================
Buy a mac.

Cloning the git repo in Windows
-------------------------------
1. Download and install git for windows http://git-scm.com/download/win (I chose default settings)
2. Open git bash
3. Type ssh-keygen
4. Leave everything blank (i.e. repeatedly press enter until it gives a fingerprint)
5. Open the .ssh folder which is in your home folder. C:\Users\YOU\.ssh
6. Open id_rsa.pub, and copy all of its contents (Ctrl+A, Ctrl+C)
7. Go to your git account settings and press the "Add SSH key" button
8. Give it a title of "windows dev" or something
9. Paste the public key you copied (6)
10. Add the key and type your github password
11. Now in the git bash, type: git clone git@github.com:meltuhamy/equations-game.git 
12. Confirm any ssh requests by typing yes when needed

Getting project dependencies
----------------------------
0. Python is *required*. Download and install it http://www.python.org/download/releases/3.3.0/
   also, make sure you have the windows c++ runtime library http://www.microsoft.com/download/en/details.aspx?id=5555
1. Download and install node js. http://nodejs.org/
2. Verify node is installed by closing and opening a new git bash and typing: node -v
3. Install coffeescript globally. Type: npm install -g coffee-script
4. cd into the project directory
5. Type: cp config.js.sample config.js
6. Edit config.js and use the following configuration:
        module.exports.COFFEE = 'coffee';
        module.exports.CAKE = 'cake';
        module.exports.STYLUS = 'stylus';
        module.exports.JASMINE = 'jasmine-node';
        module.exports.SELENIUM = '';
7. In git bash, make sure you're in your HOME folder (type: cd )
8. Type:
    npm install -g stylus
    npm install -g jasmine-node
    npm install socket.io //(note: no -g)
9. cd into your project folder (type cd equations-game)
10. Type: cake setup
11. You need to install the *windows version* of now.js
    1. Download the windows zip file https://github.com/Flotype/now/zipball/windows
    2. Extract the zip file to the node_modules folder in your home directory C:\Users\YOU\node_modules
    3. Rename the folder you just extracted to 'now'.
