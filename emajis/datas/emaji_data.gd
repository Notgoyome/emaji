extends Resource
class_name EmajiData

@export var emaji: String = ""
@export var _name: String = ""
@export var _defense: float = 0
@export var _attack: float = 0
@export var _speed: float = 0
@export var _health: float = 0
@export var _type: EmojiGlobal.Type = EmojiGlobal.Type.OTHER
@export var _rarity: EmojiGlobal.Rarity = EmojiGlobal.Rarity.COMMON

func getemaji() -> String:
	return emaji

func getemaji_name() -> String:
	return _name

func get_defense() -> int:
	return _defense * get_coefficient()

func get_attack() -> int:
	return _attack * get_coefficient()

func get_speed() -> int:
	return _speed * get_coefficient()

func get_health() -> int:
	return _health * get_coefficient()

func get_type() -> EmojiGlobal.Type:
	return _type

func get_rarity() -> EmojiGlobal.Rarity:
	return _rarity

func get_coefficient() -> float:
	return 1.0 + (float(_rarity) - 1.0) * 0.25
