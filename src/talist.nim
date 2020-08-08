from os import fileExists, getHomeDir
import db_sqlite, prompt, strutils, colorize, terminal, times

const home = getHomeDir() & ".config/talist/src/"
const alph = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P"]

let db_check = fileExists(home & "db/talist.db")

# create the file if it doesn't exist, and initialize it.
if not db_check:
  let db = open(home & "db/talist.db", "", "", "") 

  db.exec(sql"""CREATE TABLE items (
    id INTEGER PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    label VARCHAR(100) NOT NULL,
    due_date CHECK (due_date IS NULL OR date(due_date) IS NOT NULL),
    start_time INTEGER,
    comp_time INTEGER
  )""")

  db.exec(sql"""CREATE TABLE lists (
    name VARCHAR(100) NOT NULL
  )""")

  db.exec(sql"INSERT INTO lists (name) VALUES (?)", "To-Do")
  db.exec(sql"INSERT INTO lists (name) VALUES (?)", "To-Do Today")
  db.exec(sql"INSERT INTO lists (name) VALUES (?)", "Done")

# grab the file that should exist
let db = open(home & "db/talist.db", "", "", "")

# grab the "lists" from the db file
var lists = db.getAllRows(sql"SELECT name FROM lists")

# views val
# 0 - default view
# 1 - due date view
# more to come...
var view = 0
let viewMax = 1

# this shoud come in handy
var index = 0
var inc = 0

# define isInt to validate integer
proc isInt(value: string): bool = 
  var val = true

  try:
    discard parseInt(value)
  except ValueError:
    val = false

  return val

# Convert seconds to hours and minutes
proc timeConv(secs: int): string = 
  var hours = secs / 3600
  var sec = secs %% 3600

  var mins = secs / 60
  sec = sec %% 60

  var output = $hours.int() & " hrs, " & $mins.int() & " mins, " & $sec.int() & " secs"
  return output

# print out the thing we see
proc printBox(name: string) =
  inc = 0
  var line = "-----------------------".fgYellow
  echo line
  echo name.bold.fgGreen
  echo line

  var items = db.getAllRows(sql"SELECT name FROM items WHERE label=(?)", lists[index][0])

  if view == 0:
    for i in items:
      echo line
      echo $inc & ". "  & i[0].bold.fgBlue
      inc(inc)
  elif view == 1:
    for i in items:
      var dates = db.getAllRows(sql"SELECT due_date FROM items WHERE label=(?)", lists[index][0])
      var start_times = db.getAllRows(sql"SELECT start_time FROM items WHERE label=(?)", lists[index][0])
      var comp_times = db.getAllRows(sql"SELECT comp_time FROM items WHERE label=(?)", lists[index][0])

      if start_times[inc][0] != "" and comp_times[inc][0] == "": 
        echo line
        echo $inc & ". " & dates[inc][0].bold.fgGreen & " -- " & i[0].bold.fgBlue & " -- " & "Timer Started".bold.fgRed
        inc(inc)
      elif comp_times[inc][0] != "":
        var total = timeConv(parseInt(comp_times[inc][0]))
        echo line
        echo $inc & ". " & dates[inc][0].bold.fgGreen & " -- " & i[0].bold.fgBlue & " -- " & total.bold.fgRed
        inc(inc)
      else:
        echo line
        echo $inc & ". " & dates[inc][0].bold.fgGreen & " -- " & i[0].bold.fgBlue
        inc(inc)

  echo line

# function for adding an item
proc addItem(prompt: Prompt) =
  echo "\nEnter the new item:"
  let input = prompt.readLine()
  db.exec(sql"INSERT INTO items (name, label) VALUES (?, ?)", input, lists[index][0])

# working on Edit Mode
# Currently, it only has the ability to *literally* edit the Item
proc editMode(prompt: Prompt, val: int) =
  var items = db.getAllRows(sql"SELECT name FROM items WHERE label=(?)", lists[index][0])
  var newVal = val
  var current = items[newVal][0]

  echo "\nEnter the updated Item or 'Enter' to cancel:"
  let new = prompt.readLine()

  if new == "":
    return

  db.exec(sql"UPDATE items SET name = ? WHERE name = ?", new, current) 

# Function to delete item
proc delItem(prompt: Prompt) =
  var items = db.getAllRows(sql"SELECT name FROM items WHERE label=(?)", lists[index][0])
  echo "\nEnter the number of the item you want to delete (or 'Enter' to cancel):"
  var input = prompt.readLine()
  if isInt(input):
    var regVal = parseInt(input)
    db.exec(sql"DELETE FROM items WHERE name = (?) AND label = (?)", items[int(regVal)][0], lists[index][0])
  elif input == "":
    return
  else:
    echo "\nValue must be an integer..."

# Function to add or remove boards
proc editBoards(prompt: Prompt, entry: char) =
  if entry == 'n':
    echo "\nEnter the name of the new board:"
    let input = prompt.readLine()

    if input == "":
      return

    db.exec(sql"INSERT INTO lists (name) VALUES (?)", input)
    lists = db.getAllRows(sql"SELECT name FROM lists")
  else:
    echo "\nAre you sure you want to delete this board? (y/n):"
    let input = prompt.readLine()

    if input == "y":
      db.exec(sql"DELETE FROM lists WHERE name = (?)", lists[index][0])
      if index == len(lists) - 1:
        index = index - 1
      lists = db.getAllRows(sql"SELECT name FROM lists")

# Function to add or remove boards
proc dateMode(prompt: Prompt, entry: char) =
  var items = db.getAllRows(sql"SELECT name FROM items WHERE label=(?)", lists[index][0])

  if entry == 'W':
    discard os.execShellCmd("clear -x")
    echo "Items Due:\n"

    var due = db.getAllRows(sql"SELECT * FROM items WHERE due_date != (?) AND label != ? ORDER BY due_date ASC", "", "Done")

    for i in due:
      echo "DUE: ".bold.fgBlue & i[3].bold.fgGreen & " -- ".fgYellow & i[1].bold.fgBlue

    var input = getch()
    
    return
  else:
    echo "\nEnter the number of the item you want to add a due date to (or 'Enter' to cancel):"
    var input = prompt.readLine()
    if isInt(input):
      var regVal = parseInt(input)

      echo "\nEnter the date this item is due in YYYY-MM-DD format:"

      var dueDate = prompt.readLine()

      if dueDate != "":
        try:
          discard parse(dueDate, "yyyy-MM-dd")
        except:
          echo "\nDate format incorrect!"
          discard os.execShellCmd("sleep 1")
          return

      db.exec(sql"UPDATE items SET due_date = ? WHERE name = ?", dueDate, items[regVal][0]) 

      return
    elif input == "":
      return
    else:
      echo "\nValue must be an integer..."

# Function to move an Item to a different Board
proc moveItem(prompt: Prompt) =
  inc = 0
  var items = db.getAllRows(sql"SELECT name FROM items WHERE label=(?)", lists[index][0])
  echo "\nEnter the number of the item you want to move (or 'Enter' to cancel):"

  var input = prompt.readLine()

  if isInt(input):
    var intVal =  parseInt(input)
    echo "\nWhich Board would you like to move this Item to:"
    for i in lists:
      echo alph[inc] & ". " & i[0]
      inc(inc)

    var board = prompt.readLine()
    var val = find(alph, board)

    if val != -1:
      db.exec(sql"UPDATE items SET label = ? WHERE name = ?", lists[val][0], items[intVal][0])
    lists = db.getAllRows(sql"SELECT name FROM lists")
  elif input == "":
    return
  else:
    echo "\nValue must be an integer...".fgRed

# Function to print current boards
proc boardView() = 
  discard os.execShellCmd("clear -x")

  echo "Board View: Press any key to exit"

  var line = "-----------------------".fgYellow
  inc = 0
  var lists = db.getAllRows(sql"SELECT * FROM lists")

  echo line
  echo "Boards".bold.fgGreen
  echo line

  for i in lists:
    echo line
    echo alph[inc] & ". " & i[0].bold.fgBlue
    inc(inc)

  echo line
  var cont = getch()

  return

# Function to change the order of Boards
proc changeBoards(prompt: Prompt) = 
  discard os.execShellCmd("clear -x")
  lists = db.getAllRows(sql"SELECT * FROM lists")
  inc = 0

  var line = "-----------------------".fgYellow

  echo line
  echo "Boards".bold.fgGreen
  echo line

  for i in lists:
    echo line
    echo alph[inc] & ". " & i[0].bold.fgBlue
    inc(inc)

  echo line

  echo "\nWhich is the first Board you would like to switch?"

  var board = prompt.readLine()

  if board == "":
    return

  var val1 = int(find(alph, board)) + 1

  echo "\nWhich is the second Board you would like to switch?"
  board = prompt.readLine()

  if board == "":
    return

  var val2 = int(find(alph, board)) + 1

  if val1 == val2:
    return

  db.exec(sql"UPDATE lists SET rowid = 0 WHERE rowid = ?", val1)
  db.exec(sql"UPDATE lists SET rowid = ? WHERE rowid = ?", val1, val2)
  db.exec(sql"UPDATE lists SET rowid = ? WHERE rowid = 0", val2)

  lists = db.getAllRows(sql"SELECT name FROM lists")

  return

# Function to add timer to Items
proc timer(prompt: Prompt) = 
  echo "\nEnter the number you would like to start/stop timing (or 'Enter' to cancel):"
  var input = prompt.readLine()

  if input == "":
    return

  var items = db.getAllRows(sql"SELECT name FROM items WHERE label=(?)", lists[index][0])
  
  if isInt(input):
    var regVal = parseInt(input)

    var now = epochTime().int()

    var time = db.getAllRows(sql"SELECT start_time FROM items WHERE name = ?", items[regVal][0]) 

    var comp = db.getAllRows(sql"SELECT comp_time FROM items WHERE name = ?", items[regVal][0]) 

    if time[0][0] == "":
      db.exec(sql"UPDATE items SET start_time = ? WHERE name = ?", now, items[regVal][0])
    elif comp[0][0] == "":
      var curTime = parseInt(time[0][0])
      now = epochTime().int()
      var sec = now - curTime
      db.exec(sql"UPDATE items SET comp_time = ? WHERE name = ?", sec, items[regVal][0])
    else:
      echo "\nThis Item has already been timed..."
      echo "Would you like to [r]eset the timer or [e]rase the current time ['r'/'e']?"

      input = prompt.readLine()

      if input == "r":
        now = epochTime().int()

        db.exec(sql"UPDATE items SET start_time = ? WHERE name = ?", now, items[regVal][0])
        db.exec(sql"UPDATE items SET comp_time = ? WHERE name = ?", "", items[regVal][0])
      elif input == "e":
        db.exec(sql"UPDATE items SET start_time = ? WHERE name = ?", "", items[regVal][0])
        db.exec(sql"UPDATE items SET comp_time = ? WHERE name = ?", "", items[regVal][0])

      return

# Function to define help menu
proc printHelp() = 
  discard os.execShellCmd("clear -x")
  echo "\ntalist - To-Accomplish List"
  echo "This program operates around the idea of Boards and Items;"
  echo "Boards are To-Do Lists that hold Items"
  echo "\nh/l: Switch Board"
  echo "j/k: Switch view"
  echo "a: Add Item To Board"
  echo "d: Delete Item From Board"
  echo "m: Move Item To Different Board"
  echo "n: Create New Board"
  echo "x: Delete Current Board (requires confirmation)"
  echo "e: Edit Item On Board. You Can Bypass This Command By Just Entering The Corresponding Item Number"
  echo "w: Add a Due Date to an Item (must be in YYYY-MM-DD format)"
  echo "W: View your Items by Due Date"
  echo "b: Board view -- prints all boards in their current order"
  echo "c: Change Board order"
  echo "s: start/stop to time items. If the timer is not started, 's' starts it. If it has been started, 's' stops it."
  echo "?: Print this very menu..."
  echo "\nPress any key to continue..."
  let exitVal = getch()

proc readEntry(prompt: Prompt, entry: char): int = 
  if entry == 'h':
    if index != 0:
      index = index - 1
    return 0
  elif entry == 'l':
    if index != len(lists) - 1:
      index = index + 1
    return 0
  elif entry == 'k':
    if view != viewMax:
      inc(view)
    else:
      view = view
  elif entry == 'j':
    if view != 0:
      view = view - 1
    else:
      view = view
  elif entry == 'a':
    addItem(prompt)
    return 0
  elif entry == 'd':
    delItem(prompt)
    return 0
  elif entry == 'm':
    moveItem(prompt)
    return 0
  elif entry == 'n' or entry == 'x':
    editBoards(prompt, entry)
    return 0
  elif entry == 'w' or entry == 'W':
    dateMode(prompt, entry)
    return 0
  elif entry == 's':
    timer(prompt)
    return 0
  elif entry == 'q' or entry == 'Q':
    if entry == 'q':
      echo "\nAre you Sure? (y/n):"
      let qut = prompt.readLine()

      if qut == "y":
        db.close()
        quit(1)
    else:
      db.close()
      quit(1)
  elif isInt($entry):
    editMode(prompt, parseInt($entry))
    return 0
  elif entry == 'e':
    echo "\nEnter the number of the item you want to edit:"
    let i = prompt.readLine()
    if isInt(i):
      editMode(prompt, parseInt(i))
    return 0 
  elif entry == 'c':
    changeBoards(prompt)
  elif entry == 'b':
    boardView()
  elif entry == '?':
    printHelp()
    return 0
  else:
    return 0

proc main() = 
  var prompt = Prompt.init(promptIndicator = ">> ")

  prompt.showPrompt()

  while true:
    discard os.execShellCmd("clear -x")
    echo "\nhelp: h/l-Switch Board; a-Add To Board; d-Delete From Board; q/Q-Quit; ?-Help\n"
    printBox(lists[index][0])

    let input = getch()
    discard readEntry(prompt, input)
  
main()
