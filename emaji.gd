@tool
extends Node2D
class_name Emaji
@onready var label: Label = %Label
var held: bool = false
@onready var display: Node2D = %Display

@export var emaji_data: EmajiData:
	set(new_value):
		emaji_data = new_value
		if %Label:
			print("Updating label text to: ", new_value.emaji)
			%Label.text = new_value.emaji
		# label.text = new_value.emaji

var _emaji_to_merge: Emaji = null

func _process(delta):
	if held:
		var mouse_pos = get_global_mouse_position()
		global_position = mouse_pos


func _on_area_2d_input_event(viewport:Node, event:InputEvent, shape_idx:int):
	if !(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if event.pressed and GameGlobal.held_emaji == null:
		GameGlobal.held_emaji = self
		held = true
	if not event.pressed:
		held = false
		handle_release()
		if GameGlobal.held_emaji == self:
			GameGlobal.held_emaji = null

func handle_release():
	if GameGlobal.held_emaji != self:
		return
	if _emaji_to_merge == null:
		return
	print("Merging ", emaji_data.getemaji_name(), " with ", _emaji_to_merge.emaji_data.getemaji_name())
	EmojiGlobal.merge_emajis(emaji_data, _emaji_to_merge.emaji_data)

func _on_emaji_merge_component_area_entered(area):
	if area.get_parent() == self:
		return
	var other_emaji = area.get_parent() as Emaji
	other_emaji.display.scale *= 1.2
	_emaji_to_merge = other_emaji

func _on_emaji_merge_component_area_exited(area):
	var other_emaji = area.get_parent() as Emaji
	other_emaji.display.scale /= 1.2
	_emaji_to_merge = null
