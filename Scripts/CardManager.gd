extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const CARD_BIGGER_SIZE = 1.05

var screen_size
var card_being_gragged: Node2D
var is_hovering_on_card
var player_hand_reference: Node2D
#var EndRoundButton_reference: Node2D
var original_card_index: int = -1 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	#EndRoundButton_reference = $"../UIManager/EndRoundButton"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_gragged:
		var mouse_pos = get_global_mouse_position()
		card_being_gragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
											 clamp(mouse_pos.y, 0, screen_size.y))
		


func start_drag(card: Node2D):
	card_being_gragged = card
	card.scale = Vector2(1, 1)
	
	# 记录原始索引
	if card in player_hand_reference.player_hand:
		original_card_index = player_hand_reference.player_hand.find(card)
	else:
		original_card_index = -1 


func finish_drag():
	card_being_gragged.scale = Vector2(CARD_BIGGER_SIZE, CARD_BIGGER_SIZE)

	var mouse_pos = get_global_mouse_position()

	# 暂时禁用拖拽到卡槽的功能
	#var card_slot_found:Node2D = raycast_check_for_card_slot()
	#if card_slot_found and not card_slot_found.card_in_slot:
		# card dropped in empty card slot
		#card_being_gragged.position = card_slot_found.position
		#card_being_gragged.get_node('Area2D/CollisionShape2D').disabled = true
		#card_slot_found.card_in_slot = true
		#player_hand_reference.remove_card_from_hand(card_being_gragged)
		#card_being_gragged = null
		#return

	# 交换手牌位置功能
	var hand_rect = player_hand_reference.get_hand_area_rect()
	if hand_rect.has_point(mouse_pos):
		# 在手牌区域内，计算插入索引
		var insert_index = player_hand_reference.calculate_insert_index(mouse_pos.x, card_being_gragged)
		# 重新排序手牌
		player_hand_reference.reorder_card(card_being_gragged, insert_index, DEFAULT_CARD_MOVE_SPEED)
	else:
		# 不在手牌区域，放回原始位置
		if original_card_index >= 0:
			# 放回原始索引
			player_hand_reference.reorder_card(card_being_gragged, original_card_index, DEFAULT_CARD_MOVE_SPEED)
		else:
			# 手牌原本不在手中（可能是刚抽出的牌），添加到手牌中
			player_hand_reference.add_card_to_hand(card_being_gragged, DEFAULT_CARD_MOVE_SPEED)

	card_being_gragged = null
	original_card_index = -1


func connect_card_signals(card: Node2D):
	card.connect("hovered", on_hovered_over_card)
	card.connect('hovered_off', on_hovered_off_card)


func on_left_click_released():
	if card_being_gragged:
		finish_drag()


func on_hovered_over_card(card: Node2D):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		hlight_card(card, true)


func on_hovered_off_card(card: Node2D):
	if !card_being_gragged:
		hlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			hlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false


func hlight_card(card: Node2D, hovered: bool):
	if hovered:
		card.scale = Vector2(CARD_BIGGER_SIZE, CARD_BIGGER_SIZE)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1


func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null


func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null


func get_card_with_highest_z_index(result):
	var highest_z_card: Node2D = result[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	# loop find the highest z card
	for i in range(1, result.size()):
		var card: Node2D = result[i].collider.get_parent()
		
		if highest_z_index < card.z_index:
			highest_z_card = card
			highest_z_index = highest_z_card.z_index
	
	return highest_z_card
