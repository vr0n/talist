from os import fileExists
import db_sqlite, prompt, strutils, colorize, terminal

const home = "/home/vr0n/.config/talist/src/"
const alph = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P"]

let db_check = fileExists(home & "db/talist.db")

# create the file if it doesn't exist, and initialize it.
if not db_check:
  let db = open(home & "db/talist.db", "", "", "") 

  db.exec(sql"CREATE TABLE items ( id INTEGER PRIMARY KEY, name VARCHAR(500) NOT NULL , label VARCHAR(100) NOT NULL )")
  db.exec(sql"CREATE TABLE lists ( name VARCHAR(100) NOT NULL )")
  db.exec(sql"CREATE TABLE due_dates ( date real NOT NULL )")

  db.exec(sql"INSERT INTO lists (name) VALUES (?)", "To-Do")
  db.exec(sql"INSERT INTO lists (name) VALUES (?)", "To-Do Today")
  db.exec(sql"INSERT INTO lists (name) VALUES (?)", "Done")

  db.close()

# grab the file that should exist
let db = open(home & "db/talist.db", "", "", "")

# grab the "lists" from the db file
var lists = db.getAllRows(sql"SELECT name FROM lists")

# this shoud come in handy
var index = 0

# define isInt to validate integer
proc isInt(value: string): bool = 
  var val = true

  try:
    discard parseInt(value)
  except ValueError:
    val = false

  return val

# print out the thing we see
proc printBox(name: string) =
  var ind = 0
  var line = "-----------------------".fgYellow
  echo line
  echo name.bold.fgGreen
  echo line

  var items = db.getAllRows(sql"SELECT name FROM items WHERE label=(?)", lists[index][0])

  for i in items:
    echo line
    echo $ind & ". "  & i[0].bold.fgBlue
    ind = ind + 1

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

# Function to move an Item to a different Board
proc moveItem(prompt: Prompt) =
  var inc = 0
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

# Function to change the order of Boards
proc changeBoards(prompt: Prompt) = 
  var inc = 0
  echo "\nWhich Board would you like to move this Item to:"
  for i in lists:
    echo alph[inc] & ". " & i[0]
    inc(inc)

  var board = prompt.readLine()
  var val = find(alph, board)

# Function to define help menu
proc printHelp() = 
  discard os.execShellCmd("clear -x")
  echo "\ntalist - To-Accomplish List"
  echo "This program operates around Boards and Items;"
  echo "Boards are To-Do Lists that Hold Items"
  echo "\nh/l: Switch Board"
  echo "a: Add Item To Board"
  echo "d: Delete Item From Board"
  echo "m: Move Item To Different Board"
  echo "n: Create New Board"
  echo "x: Delete Current Board (requires confirmation)"
  echo "e: Edit Item On Board. You Can Bypass This Command By Just Entering The Corresponding Item Number"
  echo "Press any key to continue..."
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
