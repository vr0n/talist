(I haven't felt like formatting this README yet)

TALIST - To-Accomplish List

I deeply appreciate the work that the team at Trello is doing, but I got tired of using a web app and decided to make a very simple CLI app to replace Trello.

TO-DO:
- Make DB network-based if at all possible
- Either print out known Boards or print all Boards at once

Talist v0.1.0

To-Accomplish Lists Separated Into Boards.

To Install:
You will have to set the `home` variable in `src/talist.nim` before installing.
Once this is done, just cd into the `talist` directory and run `nimble c src/talist.nim`

Features:
This program focuses around the ideas of Items and Boards. Boards hold Items and Items
make up our "To-Do" list. Boards are basically the categories you put your Items in.

One of my issues with Trello was a lack of keyboard support for basic features and
an inability to discover basic features (such as delete). 

Everything should be straightforward here: the middle keyboard row is where all of
your most basic commands lie -- 'a' to add an item, 'd' to delete, 'h'/'l' to cycle.

You can also edit/delete Boards with 'n' for "new" or 'x' to delete.

You can move Items from one board to another with 'm' for "move". And, you can seek
further help by typing "?".

Requirements:
Currently, this only works with shown nimble requirements and on Linux. This is 
because I manually call `os.execShellCmd` which needs a linux terminal emulator
which basic GNU tools to operate. 
