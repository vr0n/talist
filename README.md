(I haven't felt like formatting this README yet)

TALIST - To-Accomplish List

I deeply appreciate the work that the team at Trello is doing, but I got tired of using a web app and decided to make a very simple CLI app to replace Trello.

NOTES:
There is a problem I can't solve with Nim/sqlite3 not being able to call
a database file without an absolute path or a "relative path" where the
path starts from the root directory of app. To solve this, a variable
called `home` has been added to talist.nim which you should edit to match
your path to the app root directory. Once you've done this, you can just
alias `talist` to the full path of the compiled binary to avoid the db
error. I am open to any suggestions on how to solve this.

Version 1.0.0 Updates:
Due Dates are now implemented. You can now add due dates to your items
and view all of our items (regardless of board) in due date order.

If an item does not have a due date, it will not be included in the list
of items that have due dates.

TO-DO:
- Make DB network-based if at all possible
- Either print out known Boards or print all Boards at once

Talist v1.0.0

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
your most basic commands lie -- `a` to add an item, `d` to delete, `h`/`l` to cycle.

You can also edit/delete Boards with `n` for "new" or `x` to delete.

You can move Items from one board to another with `m` for "move". And, you can seek
further help by typing `?`.

Requirements:
Currently, this only works with shown nimble requirements and on Linux. This is 
because I manually call `os.execShellCmd` which needs a Linux terminal emulator
with basic GNU tools to operate. 
