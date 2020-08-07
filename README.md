# TALIST - To-Accomplish List

I deeply appreciate the work that the team at Trello is doing, but I got tired of using a web app and decided to make a very simple CLI app to replace Trello.

### Version 1.0.0 Updates:
* Due Dates are now implemented. You can now add due dates to your items
and view all of our items (regardless of board) in due date order.

* Views are now implemented. There are currently only two views available:
Default and Due Date view. You can use `j`/`k` to switch between them.

* If an item does not have a due date, it will not be included in the list
of items that have due dates.

### TO-DO:
- Make DB network-based if at all possible

### Talist v1.0.0

To-Accomplish Lists Separated Into Boards.

To Install:
I haven't written the installer yet, so it is recommended that you run this from a new directory called ~/.talist (though, you can run it from wherever you want, as long as talist can find the database file). To install, just cd into the `talist` directory and run `nimble c src/talist.nim`

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
