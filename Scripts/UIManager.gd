extends Node2D
class_name UIManager


const OPTION_SCENE_PATH = "res://scenes/OptionButton.tscn"
const ENG_TO_CN = {"Fold": "弃牌", "Check": "过牌", "Call": "跟注", "Raise": "加注", "Allin": "全押", "EndRound": "结束"}
const OPTION_X = 1835
const OPTION_Y_INTERVAL = 80
const OPTION_Y_LOWSET = 900

var current_hovered_option: Node2D = null
var registered_options: Array[Node2D] = []


func _ready():
	# 自动注册场景中所有OptionButton节点
	register_all_options()


func register_option(option: Node2D):
	if option in registered_options:
		return

	registered_options.append(option)

	# 连接选项信号
	if option.has_signal("option_hovered"):
		option.connect("option_hovered", _on_option_hovered)

	if option.has_signal("option_selected"):
		option.connect("option_selected", _on_option_selected)

	print("Registered option: ", option.name)

func unregister_option(option: Node2D):
	if not option in registered_options:
		return

	registered_options.erase(option)

	# 断开信号连接
	if option.is_connected("option_hovered", _on_option_hovered):
		option.disconnect("option_hovered", _on_option_hovered)

	if option.is_connected("option_selected", _on_option_selected):
		option.disconnect("option_selected", _on_option_selected)

func _on_option_hovered(option: Node2D):
	# 如果已经有悬停的选项且不是同一个，触发其恢复动画
	if current_hovered_option and current_hovered_option != option:
		# 调用选项的unhighlight方法
		if current_hovered_option.has_method("unhighlight"):
			current_hovered_option.unhighlight()

	current_hovered_option = option
	print("Option hovered: ", option.name)

func _on_option_selected(option: Node2D):
	print("Option selected: ", option.name)

	# 这里可以处理选项选择逻辑
	# 例如：触发游戏事件、改变游戏状态等

	# 示例：广播选项选择事件
	get_tree().call_group("option_listeners", "_on_option_selected", option)

func register_all_options():
	# 可以优化查找
	# 查找场景中所有OptionButton节点并注册
	var root = get_tree().root
	var all_nodes = root.get_children()

	# 递归查找所有节点
	var found_options: Array[Node2D] = []
	find_option_nodes_recursive(root, found_options)

	for option in found_options:
		register_option(option)

	print("Registered ", found_options.size(), " option(s)")

func find_option_nodes_recursive(node: Node, result: Array[Node2D]):
	# 检查节点是否是OptionButton（通过检查是否有option_hovered信号）
	if node.has_signal("option_hovered"):
		result.append(node as Node2D)

	# 递归检查子节点
	for child in node.get_children():
		find_option_nodes_recursive(child, result)

func clear_all_options():
	for option in registered_options:
		unregister_option(option)

	registered_options.clear()
	current_hovered_option = null


func add_option_buttons(options):
	for option in options:
		var option_scene = preload(OPTION_SCENE_PATH)
		var new_option = option_scene.instantiate()
		
		$".".add_child(new_option)
		new_option.name = option
		register_option(new_option)
		new_option.option_text = ENG_TO_CN[option] 
		
		draw_option_buttons(registered_options)

func draw_option_buttons(registered_options_):
	if registered_options_:
		for index in range(registered_options.size()):
			var option_node = registered_options_[index]
			var current_y = OPTION_Y_LOWSET - index * OPTION_Y_INTERVAL
			
			option_node.position = Vector2(OPTION_X, current_y)
