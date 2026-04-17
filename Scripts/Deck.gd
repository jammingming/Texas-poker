extends Node2D

const CARD_SCENE_PATH = 'res://scenes/Card.tscn'
const ENEMY_CARD_SCENE_PATH = 'res://scenes/EnemyCard.tscn'
const CARD_RAW_SPEED = 0.2

var player_deck = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var initial_deck = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]  # Copy for resetting 


func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())


func draw_cards(count: int):
	for i in range(count):
		if player_deck.size() == 0:
			break
		var card_drawn_name = player_deck[0]
		player_deck.erase(card_drawn_name)

		if player_deck.size() == 0:
			$Area2D/CollisionShape2D.disabled = true
			$Sprite2D.visible = false
			$RichTextLabel.visible = false

		$RichTextLabel.text = str(player_deck.size())
		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()
		var card_image_path = "res://Assets/Spade" + card_drawn_name + ".png"

		new_card.get_node("CardImage").texture = load(card_image_path)
		$"../CardManager".add_child(new_card)
		new_card.name = "Card"
		$"../PlayerHand".add_card_to_hand(new_card, CARD_RAW_SPEED)
		new_card.get_node("AnimationPlayer").play("card_flip")


func draw_enemy_cards(count: int, Enemies: Array):
	for enemy in Enemies:
		for i in range(count):
			if player_deck.size() == 0:
				break
			var card_drawn_name = player_deck[0]
			player_deck.erase(card_drawn_name)

			if player_deck.size() == 0:
				$Area2D/CollisionShape2D.disabled = true
				$Sprite2D.visible = false
				$RichTextLabel.visible = false
				
			$RichTextLabel.text = str(player_deck.size())
			var card_scene = preload(ENEMY_CARD_SCENE_PATH)
			var new_card = card_scene.instantiate()
			var card_image_path = "res://Assets/Spade" + card_drawn_name + ".png"

			new_card.get_node("CardImage").texture = load(card_image_path)
			$"../CardManager".add_child(new_card)
			new_card.name = "EnemyCard"
			enemy.add_card_to_hand(new_card, CARD_RAW_SPEED)


func reset_round():
	# Reset deck to initial state
	player_deck = initial_deck
	player_deck.shuffle()

	# Re-enable deck visuals if they were disabled
	$Area2D/CollisionShape2D.disabled = false
	$Sprite2D.visible = true
	$RichTextLabel.visible = true
	$RichTextLabel.text = str(player_deck.size())
	print("Deck reset: ", player_deck.size(), " cards remaining")


func draw_card_to_slot(slot: Node2D) -> void:
	if player_deck.size() == 0:
		print("Deck is empty, cannot draw card to slot")
		return

	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)

	# Update deck visuals
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	$RichTextLabel.text = str(player_deck.size())
	print("Drew card %s to slot, deck remaining: %s" % [card_drawn_name, player_deck.size()])

	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = "res://Assets/Spade" + card_drawn_name + ".png"

	new_card.get_node("CardImage").texture = load(card_image_path)
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	new_card.get_node("AnimationPlayer").play("card_flip")

	# Start card at deck position for animation
	var deck_position = global_position
	new_card.global_position = deck_position

	# Animate card to slot position
	var tween = get_tree().create_tween()
	tween.tween_property(new_card, "global_position", slot.global_position, 0.5)
	# After animation completes, disable collision
	tween.tween_callback(func():
		new_card.get_node("Area2D/CollisionShape2D").disabled = true
	)
