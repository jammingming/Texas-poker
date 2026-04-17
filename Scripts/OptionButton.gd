extends Node2D

signal option_hovered
signal option_selected
signal pressed  # 兼容Button的pressed信号

var card_manager_reference: Node2D

@export var option_text: String = "Option"
@export var option_value: Variant

var original_scale: Vector2 = Vector2.ONE
var is_hovered: bool = false
@export var disabled: bool = false


func _ready():
	card_manager_reference = $"../../CardManager"
	
	original_scale = scale
	# 设置初始文本
	if has_node("Label"):
		$Label.text = option_text

	# 连接Area2D信号
	if has_node("Area2D"):
		var area = $Area2D
		area.mouse_entered.connect(_on_area_2d_mouse_entered)
		area.mouse_exited.connect(_on_area_2d_mouse_exited)
		area.input_event.connect(_on_area_2d_input_event)


func _on_area_2d_mouse_entered() -> void:
	if disabled or card_manager_reference.card_being_gragged:
		return
	is_hovered = true
	emit_signal("option_hovered", self)
	highlight()
	$Entered.play()


func _on_area_2d_mouse_exited() -> void:
	if disabled or card_manager_reference.card_being_gragged:
		return
	is_hovered = false
	unhighlight()


func highlight():
	# 缩放动画
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# 缩放动画 (1.2倍)
	tween.tween_property(self, "scale", original_scale * 1.2, 0.15)

	# 颜色变亮效果
	if has_node("Sprite2D"):
		tween.parallel().tween_property($Sprite2D, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.15)


func unhighlight():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# 恢复缩放
	tween.tween_property(self, "scale", original_scale, 0.15)

	# 恢复颜色
	if has_node("Sprite2D"):
		tween.parallel().tween_property($Sprite2D, "modulate", Color.WHITE, 0.15)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if disabled:
		return
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			select()
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.is_released():
			highlight()


func select():
	if disabled:
		return
	
	unhighlight()
	$Selected.play()
	emit_signal("option_selected", self)
	emit_signal("pressed")  # 兼容Button信号
	# 这里可以添加选中状态的视觉效果
	print("Option selected: ", option_text, " (", option_value, ")")
