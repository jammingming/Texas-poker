extends Node2D

const HAND_COUNT = 2
const CARD_WIDTH = 150
const DEFAULT_CARD_MOVE_SPEED = 0.1
const ROTATION_HORIZONTAL = 0.0      # 水平布局：0度
const ROTATION_VERTICAL = PI/2       # 垂直布局：90度（π/2弧度）
var player_hand = []
var lay_axis = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func reorder_card(card: Node2D, new_index: int, speed: float = DEFAULT_CARD_MOVE_SPEED, rotate_speed: float = -1.0) -> void:
	# 将手牌移动到新的索引位置，并更新所有手牌的位置
	if card not in player_hand:
		# 如果手牌不在手中，先添加到手牌中
		player_hand.insert(new_index, card)
	else:
		# 移动手牌到新索引
		player_hand.erase(card)
		player_hand.insert(new_index, card)

	# 更新所有手牌的位置和旋转
	update_card_positions_with_rotate(speed, rotate_speed)	


func add_card_to_hand(card, speed, insert_index: int = -1, rotate_speed: float = -1.0):
	if card not in player_hand:
		if insert_index >= 0 and insert_index <= player_hand.size():
			player_hand.insert(insert_index, card)
		else:
			player_hand.insert(0, card)

		# 立即设置正确的旋转（如果需要）
		if lay_axis == 1:
			card.rotation = ROTATION_VERTICAL
		elif lay_axis == 0:
			card.rotation = ROTATION_HORIZONTAL

		update_card_positions_with_rotate(speed, rotate_speed)
	else:
		# 手牌已经在手中，如果需要改变索引则重新排序
		if insert_index >= 0 and insert_index <= player_hand.size():
			reorder_card(card, insert_index, speed, rotate_speed)
		else:
			# 保持原位置
			animate_card_to_position(card, card.hand_card_position, speed, rotate_speed)


func update_card_positions(speed):
	for i in range(player_hand.size()):
		# get new card position based on index
		var new_position: Vector2 = calculate_card_position(i)
		var card: Node2D = player_hand[i]
		card.hand_card_position = new_position

		# 如果卡牌刚添加到手中，立即设置正确的旋转
		if lay_axis == 1 and abs(card.rotation - ROTATION_VERTICAL) > 0.01:
			card.rotation = ROTATION_VERTICAL
		elif lay_axis == 0 and abs(card.rotation - ROTATION_HORIZONTAL) > 0.01:
			card.rotation = ROTATION_HORIZONTAL

		animate_card_to_position(card, new_position, speed)


func calculate_card_position(index):
	const CARD_SPACE = CARD_WIDTH * 2/3 
	var offset: float = (player_hand.size() - 1) * CARD_SPACE
	if not lay_axis:
		var postion: float = global_position[0] + index * CARD_SPACE - offset / 2
		return Vector2(postion,  global_position[1])
	else:
		var postion: float = global_position[1] + index * CARD_SPACE - offset / 2
		return Vector2(global_position[0], postion)


func animate_card_to_position(card, new_position, speed, rotate_speed: float = -1.0):
	var tween = get_tree().create_tween()

	# 位置动画
	tween.tween_property(card, 'position', new_position, speed)

	# 计算目标旋转角度
	var target_rotation = ROTATION_HORIZONTAL if lay_axis == 0 else ROTATION_VERTICAL

	# 只有当需要改变旋转时才添加旋转动画
	if abs(card.rotation - target_rotation) > 0.01:
		# 使用指定的旋转速度，如果未指定则使用位置动画速度
		var actual_rotate_speed = rotate_speed if rotate_speed >= 0 else speed
		tween.parallel().tween_property(card, 'rotation', target_rotation, actual_rotate_speed)


func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_card_positions(DEFAULT_CARD_MOVE_SPEED)
	else:
		animate_card_to_position(card, card.card_hand_position, DEFAULT_CARD_MOVE_SPEED)


func update_card_positions_with_rotate(speed, rotate_speed: float = -1.0):
	for i in range(player_hand.size()):
		var new_position: Vector2 = calculate_card_position(i)
		var card: Node2D = player_hand[i]
		card.hand_card_position = new_position
		animate_card_to_position(card, new_position, speed, rotate_speed)


func set_layout_axis(axis: int, speed: float = DEFAULT_CARD_MOVE_SPEED, rotate_speed: float = -1.0):
	if lay_axis != axis:
		lay_axis = axis
		update_card_positions_with_rotate(speed, rotate_speed)


func clear_hand():
	for card in player_hand:
		card.queue_free()
	player_hand.clear()
	# No need to update positions since hand is empty
