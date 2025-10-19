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
	var httprequest_node = HTTPRequest.new()
	add_child(httprequest_node)
	httprequest = httprequest_node
	httprequest.request_completed.connect(_on_http_request_request_completed)
	

func merge_emajis(emaji1: EmajiData, emaji2: EmajiData) -> EmajiData:
	var new_emaji = EmajiData.new()
	new_emaji._rarity = get_rarity()
	call_openai("test")
	return new_emaji

func call_openai(prompt_text: String):
	var url = "https://api.openai.com/v1/chat/completions"

	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % api_key
	]

	var body = {
		"model": "gpt-3.5-turbo",
		"messages": [{"role":"user","content":prompt_text}],
		"max_tokens": 100
	}

	var body_json = JSON.stringify(body)
	var err = httprequest.request(url, headers, HTTPClient.METHOD_POST, body_json)
	if err != OK:
		print("Erreur requête HTTP :", err)

func _on_http_request_request_completed(result:int, response_code:int, headers:PackedStringArray, body:PackedByteArray):
	print("HTTP Request completed with response code: ", response_code)
	pass # Replace with function body.
