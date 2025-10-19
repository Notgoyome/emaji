extends Node
var httprequest: HTTPRequest
var api_key: String = ""

enum Type {
	# Main types
	ALIVE = 0,
	OBJECT = 1,
	EMOTION = 2,
	OTHER = 3,

	# Elemental types
	FIRE = 4,
	WATER = 5,
	EARTH = 6,
	AIR = 7,
}

enum Rarity {
	COMMON = 1,
	UNCOMMON = 2,
	RARE = 3,
	LEGENDARY = 5,
}

var type_names = {
	Type.ALIVE: "Alive",
	Type.OBJECT: "Object",
	Type.EMOTION: "Emotion",
	Type.OTHER: "Other",

	Type.FIRE: "Fire",
	Type.WATER: "Water",
	Type.EARTH: "Earth",
	Type.AIR: "Air",
}

var basicemajis = {
}

var chances = {
	Rarity.COMMON: 59,
	Rarity.UNCOMMON: 30,
	Rarity.RARE: 10,
	Rarity.LEGENDARY: 1,
}

func get_rarity() -> Rarity:
	var total = 0
	for chance in chances.values():
		total += chance
	var roll = randi() % total
	var cumulative = 0
	for rarity in chances.keys():
		cumulative += chances[rarity]
		if roll < cumulative:
			return rarity
	return Rarity.COMMON

func _ready():
	parse_config()

	var httprequest_node = HTTPRequest.new()
	add_child(httprequest_node)
	httprequest = httprequest_node
	httprequest.request_completed.connect(_on_http_request_request_completed)
	

func merge_emajis(emaji1: EmajiData, emaji2: EmajiData) -> EmajiData:
	var new_emaji = EmajiData.new()
	new_emaji._rarity = get_rarity()
	var stringified = "Emaji 1: " + emaji_to_json(emaji1) + "\nEmaji 2: " + emaji_to_json(emaji2) + "\n"
	var text = stringified + "
	Combine the following two emoji into a new single emoji that represents both concepts, be inventive with the emoji, example: lava + water = obisidian, or stone etc and name choice.
	Provide ONLY the raw JSON object with the same fields, no markdown, no backticks, no extra text:"
	call_openai(text)

	return new_emaji

func call_openai(prompt_text: String):
	var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent"
	
	var headers = [
		"Content-Type: application/json",
		"x-goog-api-key: %s" % api_key
	]

	var body = {
		"contents": [
			{
				"parts": [
					{"text": prompt_text}
				]
			}
		]
	}

	var body_json = JSON.stringify(body)
	var err = httprequest.request(url, headers, HTTPClient.METHOD_POST, body_json)
	if err != OK:
		print("Erreur requête HTTP :", err)

func _on_http_request_request_completed(result:int, response_code:int, headers:PackedStringArray, body:PackedByteArray):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var values = response["candidates"][0]["content"]["parts"][0]["text"]
	var emaji_data = json_to_emaji(values)
	if emaji_data == null:
		print("Failed to create emaji from OpenAI response")
		return
	var emaji = preload("res://emajis/emaji.tscn").instantiate() as Emaji
	get_tree().get_root().add_child(emaji)
	emaji.emaji_data = emaji_data
	emaji.global_position = Vector2(400, 300)
	print(emaji.emaji_data.emaji)
	print("Received emaji from OpenAI: ", emaji_data.getemaji_name())

	

func parse_config():
	var file = FileAccess.open("res://config.json", FileAccess.READ)
	if !file:
		print("Could not open config.json")
		return

	var config_data = JSON.parse_string(file.get_as_text())
	if (config_data == null):
		print("Error parsing config.json")
		return

	var config_dict = config_data
	if config_dict.has("gemini_key"):
		api_key = config_dict["gemini_key"]
	else:
		print("API key not found in config.json")

func emaji_to_json(emaji: EmajiData) -> String:
	var dict = {
		"emaji": emaji.getemaji(),
		"name": emaji.getemaji_name(),
		"defense": emaji.get_defense(),
		"attack": emaji.get_attack(),
		"speed": emaji.get_speed(),
		"health": emaji.get_health(),
		"type": int(emaji.get_type()),
	}
	return JSON.stringify(dict)

func json_to_emaji(json_str: String) -> EmajiData:
	var json = JSON.new()
	json.parse(json_str)
	var data = json.get_data()
	if data == null:
		print("Error parsing emaji JSON")
		return null
	var emaji = EmajiData.new()

	emaji.emaji = data["emaji"]
	emaji._name = data["name"]
	emaji._defense = data["defense"]
	emaji._attack = data["attack"]
	emaji._speed = data["speed"]
	emaji._health = data["health"]
	emaji._type = data["type"]

	return emaji
