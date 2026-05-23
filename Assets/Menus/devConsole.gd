extends CanvasLayer

@onready var outputLines : RichTextLabel = $Output/Display
@onready var inputPrompt : LineEdit = $Input
@onready var inputHistoryDisplay : Label = $Input/historyDisplay

var inputHistory : Array[String] = []
var historyIndex : int = 0

func _ready() -> void:
	visible = false
	inputHistoryDisplay.visible = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggleConsole"):
		visible = !visible
		inputPrompt.release_focus()
	if Input.is_action_just_pressed("ui_up") && visible && inputPrompt.has_focus():
		historyIndex += 1
		if historyIndex > inputHistory.size() - 1:
			historyIndex = inputHistory.size() - 1
		inputHistoryDisplay.visible = true
		inputHistoryDisplay.text = "history index : " + str(historyIndex)
		if inputHistory.size() > 0 && historyIndex <= inputHistory.size() - 1:
			inputPrompt.text = inputHistory[historyIndex]
	if Input.is_action_just_pressed("ui_down") && visible && inputPrompt.has_focus():
		historyIndex -= 1
		if historyIndex == -1:
			inputPrompt.clear()
			inputHistoryDisplay.visible = false
		if historyIndex >= 0:
			if inputHistory.size() > 0 && historyIndex <= inputHistory.size() - 1:
				inputPrompt.text = inputHistory[historyIndex]
		else:
			historyIndex = -1
		inputHistoryDisplay.text = "history index : " + str(historyIndex)

func run_command(command : String, varValues : Array = []) -> void:
	var expression = Expression.new()
	var parseError = expression.parse(command, varValues)
	if parseError != OK:
		push_output_text(expression.get_error_text(), true)
		return
	var result = expression.execute(varValues, self)
	if !expression.has_execute_failed():
		inputHistory.push_front(command)
		historyIndex = -1
		push_output_text(str(result))
	else:
		push_output_text(expression.get_error_text(), true)

func push_output_text(text : String, asError : bool = false) -> void:
		inputPrompt.clear()
		outputLines.newline()
		if asError:
			outputLines.append_text("[color=red] ERROR: " + text + "[/color]")
		else:
			outputLines.append_text(text)
		outputLines.scroll_to_line(outputLines.get_line_count())

func clear() -> String:
	outputLines.clear()
	return ""

func methods() -> String:
	var list = get_script().get_script_method_list()
	var append : Array[String]
	var result : String
	var idx = 0
	for method in list:
		append.append(list[idx]["name"])
		append.append("()\n")
		idx += 1
	result = result.join(append)
	return "[color=gold]" + result + "[/color]"

func color_legend() -> String:
	var strGold : String = "[color=gold]Gold[/color] : Informational text.\n"
	var strRed : String = "[color=red]Red[/color] : Error when running function.\n"
	var strCyan : String = "[color=cyan]Cyan[/color] : Important notice, optional.\n"
	var strPurple : String = "[color=purple]Purple[/color] : Risky command executed - [color=red]Unreliable.[/color]\n"
	var strWhite : String = "White : Plain output."
	return strGold + strRed + strCyan + strPurple + strWhite

func reload(force : bool = false) -> String:
	var mngr : RoomManager = get_tree().current_scene.find_child("roomManager")
	if mngr && !mngr.genFinished:
		if force:
			mngr.free()
			get_tree().reload_current_scene()
			return "[color=purple]Forced reload successfully[/color]"
		return "[color=red]ERROR: Could not reload scene. Rooms are still generating! Reloading while generation is active may result in a crash. [/color]
		[color=cyan]Run this command and enter the parameter 'true' to force a reload."
	get_tree().reload_current_scene()
	return "Reloaded scene"

func heal(amount : float) -> String:
	var player : Player = get_tree().current_scene.find_child("Player")
	if player:
		player.health += amount
		return "Healed player " + str(amount)
	else:
		return "[color=red]ERROR: Could not heal; Player not found in scene [/color]"

func add_perk(perk) -> String:
	var player : Player = get_tree().current_scene.find_child("Player")
	if player:
		if DataStore.perkPaths.has(perk):
			player.add_perk(perk)
			return "Added perk " + str(DataStore.perkPaths[perk])
		else:
			return "[color=red]ERROR: Could not add perk; Perk nonexistent or invalid [/color]"
	else:
		return "[color=red]ERROR: Could not add perk; Player not found in scene [/color]"

func add_mod(mod) -> String:
	var manager = get_tree().current_scene
	if mod is String:
		if manager is StageManager:
			var result = manager.add_mod(mod)
			if DataStore.modScenes.has(mod):
				DataStore.saveData["runModifiers"].append(mod)
			return result
		else: return "[color=red]ERROR: Could not add mod; StageManager node not found in scene [/color]"
	else: return "[color=red]ERROR: Could not add mod; Input is not variant String[/color]"

func set_noclip(on : bool = true):
	var player : Player = get_tree().current_scene.find_child("Player")
	if player:
		player.NOCLIP = on
		if on:
			return "Noclip enabled"
		else:
			return "Noclip disabled"
	else:
		return "[color=red]ERROR: Could not set noclip; Player not found in scene [/color]"

func generate_rooms(amount : int = -1):
	var mngr : RoomManager = get_tree().current_scene.find_child("roomManager")
	if mngr:
		if amount < 1:
			amount = mngr.setGenAmount
		mngr.generate_rooms(amount)
		return "Generating " + str(amount) + " rooms"
	else:
		return "[color=red]ERROR: Could not generate rooms; RoomManager not found in scene [/color]"
