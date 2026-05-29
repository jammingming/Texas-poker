extends Node2D

@onready var deck = $"../Deck"
@onready var player_hand = $"../PlayerHand"
@onready var end_round_button = $"../UIManager/EndRoundButton"
@onready var card_slots = $"../CardSlots"
@onready var UIManager_reference = $"../UIManager"

const ENEMY_HAND_SCENE_PATH = "res://scenes/enemy_hand.tscn"
const ENEMY_NUMBER = 5

var is_round_busy = false
var is_first_round = true
var current_round = 1
var Enemies = []

func _ready() -> void:
	pre_load_enemies(ENEMY_NUMBER)
	
	# Connect end round button signal
	if end_round_button:
		end_round_button.pressed.connect(_on_end_round_button_pressed)
	# 开始第一回合 - 延迟执行确保敌人节点完全加入场景树
	call_deferred("start_round")


func pre_load_enemies(enemy_number: int):
	var enemy_hand_scen_reference = preload(ENEMY_HAND_SCENE_PATH)
	var res
	for i in range(enemy_number):
		var enemy_hand = enemy_hand_scen_reference.instantiate()
		$"..".add_child.call_deferred(enemy_hand)
		enemy_hand.name = "EnemyHand" + str(i)
		res = calculate_enemy_positions(enemy_number, i)
		enemy_hand.position = res[0]
		enemy_hand.lay_axis = res[1]
		Enemies.append(enemy_hand)


func calculate_enemy_positions(enemy_number: int, i: int) -> Array:
	const SCREEN_WIDTH = 1920
	const SCREEN_HEIGHT = 1080
	const TOP_MARGIN = 250
	const TOP_MARGIN_ = 100
	const LEFT_MARGIN = 180
	const SPACING = 400

	# 定义：顶部数量、左侧数量
	var top_count = 0
	var left_count = 0
	match enemy_number:
		1: top_count = 1
		2: top_count = 1; left_count = 1
		3: top_count = 1; left_count = 2
		4: top_count = 2; left_count = 2
		5: top_count = 2; left_count = 3
		6: top_count = 3; left_count = 3
		@warning_ignore("integer_division")
		_: return [Vector2(SCREEN_WIDTH/2, TOP_MARGIN), 0]

	# 顶部均匀排列（修复语法后）
	if i < top_count:
		@warning_ignore("integer_division")
		var start_x = SCREEN_WIDTH/2 - (top_count - 1) * SPACING / 2
		var x = start_x + i * SPACING
		return [Vector2(x, TOP_MARGIN_), 0]
	# 左侧均匀排列（修复语法后）
	else:
		var left_index = i - top_count
		var total_height = SCREEN_HEIGHT - TOP_MARGIN*2
		# 防止除以0（核心语法/逻辑修复）
		var divisor = max(left_count - 1, 1)
		@warning_ignore("integer_division")
		var y = TOP_MARGIN/2 + left_index * total_height / divisor
		return [Vector2(LEFT_MARGIN, y), 1]


func start_round() -> void:
	print("Starting new round (first round: %s)" % is_first_round)

	# Increment round counter if not first round
	if not is_first_round:
		current_round += 1
	print("Current round: %s" % current_round)

	# Draw cards only in first round
	if is_first_round and deck.has_method("draw_cards"):
		print("Drawing 2 cards for first round")
		print("Drawing options")
		deck.draw_cards(2)
		deck.draw_enemy_cards(2, Enemies)
		UIManager_reference.add_option_buttons(["Fold", "Check", "Call", "Raise", "Allin"])
		
		is_first_round = false
	else:
		print("No cards drawn (not first round)")

	# In second round, draw 3 cards to first three slots
	if current_round == 2:
		print("Second round: drawing 3 cards to first three slots")
		if card_slots and deck:
			var slot_children = card_slots.get_children()
			var slots_drawn = 0
			for i in range(min(3, slot_children.size())):
				var slot = slot_children[i]
				if slot.card_in_slot:
					print("Slot %s already occupied, skipping" % i)
					continue
				deck.draw_card_to_slot(slot)
				slot.card_in_slot = true
				slots_drawn += 1
				print("Card placed in slot %s" % i)
			print("Finished drawing %s cards to slots" % slots_drawn)
		else:
			print("Card slots or deck not found!")

	print("Finished starting round")


func end_round() -> void:
	if is_round_busy:
		return

	is_round_busy = true
	print("Ending current round")

	# Disable button to prevent multiple clicks
	if end_round_button:
		end_round_button.disabled = true

	# Start next round
	print("Starting next round...")
	start_round()

	# Reset processing flag and re-enable button
	is_round_busy = false
	if end_round_button:
		end_round_button.disabled = false
		print("Button re-enabled")

func _on_end_round_button_pressed() -> void:
	if is_round_busy:
		return
	print("End round button pressed!")
	end_round()
