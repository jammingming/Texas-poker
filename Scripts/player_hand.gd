extends Node2D

const HAND_COUNT = 2
const CARD_WIDTH = 150
const HAND_Y_POSITION = 960
const HAND_AREA_HEIGHT = 128  # 手牌区域的高度，用于检测拖放手牌（减少高度使区域更紧凑）
const DEFAULT_CARD_MOVE_SPEED = 0.1

var player_hand = []
var center_screen_x: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2


func get_hand_area_rect() -> Rect2:
	# 返回手牌区域的矩形，用于检测拖放手牌
	# 基于实际手牌位置计算区域，更精确
	var min_x = INF
	var max_x = -INF

	# 找到所有手牌的最小和最大X坐标
	for card in player_hand:
		if card.get("hand_card_position") != null:
			min_x = min(min_x, card.hand_card_position.x)
			max_x = max(max_x, card.hand_card_position.x)

	# 如果没有手牌或手牌位置未初始化，使用默认计算
	if min_x == INF or max_x == -INF:
		var rect_width = player_hand.size() * CARD_WIDTH + CARD_WIDTH  # 减少额外宽度
		var left = center_screen_x - rect_width / 2
		var top = HAND_Y_POSITION - HAND_AREA_HEIGHT / 2
		return Rect2(left, top, rect_width, HAND_AREA_HEIGHT)

	# 基于实际手牌位置，添加半个卡牌宽度的缓冲
	var buffer = CARD_WIDTH * 1.5
	var left = min_x - buffer
	var right = max_x + buffer
	var top = HAND_Y_POSITION - HAND_AREA_HEIGHT / 2
	return Rect2(left, top, right - left, HAND_AREA_HEIGHT)


func calculate_insert_index(mouse_x: float, exclude_card: Node2D) -> int:
	# 根据鼠标X坐标计算手牌应该插入的索引，排除被拖拽的手牌
	if player_hand.size() == 0:
		return 0

	# 创建不包括排除手牌的临时列表
	var temp_hand = []
	for card in player_hand:
		if card != exclude_card:
			temp_hand.append(card)

	if temp_hand.size() == 0:
		# 只有被拖拽的手牌本身或手牌没有位置信息
		return 0

	# 按X坐标排序
	temp_hand.sort_custom(func(a, b): return a.hand_card_position.x < b.hand_card_position.x)

	# 找到插入位置
	for i in range(temp_hand.size()):
		var card = temp_hand[i]
		if mouse_x < card.hand_card_position.x:
			return i

	# 鼠标在最右侧
	return temp_hand.size()


func reorder_card(card: Node2D, new_index: int, speed: float = DEFAULT_CARD_MOVE_SPEED) -> void:
	# 将手牌移动到新的索引位置，并更新所有手牌的位置
	if card not in player_hand:
		# 如果手牌不在手中，先添加到手牌中
		player_hand.insert(new_index, card)
	else:
		# 移动手牌到新索引
		player_hand.erase(card)
		player_hand.insert(new_index, card)

	# 更新所有手牌的位置
	update_card_positions(speed)	


func add_card_to_hand(card, speed, insert_index: int = -1):
	if card not in player_hand:
		if insert_index >= 0 and insert_index <= player_hand.size():
			player_hand.insert(insert_index, card)
		else:
			player_hand.insert(0, card)
		update_card_positions(speed)
	else:
		# 手牌已经在手中，如果需要改变索引则重新排序
		if insert_index >= 0 and insert_index <= player_hand.size():
			reorder_card(card, insert_index, speed)
		else:
			# 保持原位置
			animate_card_to_position(card, card.hand_card_position, speed)


func update_card_positions(speed):
	for i in range(player_hand.size()):
		# get new card position based on index
		var new_position: Vector2 = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card: Node2D = player_hand[i]
		card.hand_card_position = new_position
		animate_card_to_position(card, new_position, speed)


func calculate_card_position(index):
	var x_offset: float = (player_hand.size() - 1) * CARD_WIDTH
	var x_postion: float = center_screen_x + index * CARD_WIDTH - x_offset / 2
	return x_postion


func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, 'position', new_position, speed)


func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_card_positions(DEFAULT_CARD_MOVE_SPEED)
	else:
		animate_card_to_position(card, card.card_hand_position, DEFAULT_CARD_MOVE_SPEED)


func clear_hand():
	for card in player_hand:
		card.queue_free()
	player_hand.clear()
	# No need to update positions since hand is empty
