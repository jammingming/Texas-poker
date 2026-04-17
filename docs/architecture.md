# 架构

Root Node: Main (Top-level game node)
Core Management Node: Managers (Child of Main)
Subordinate Managers: Modular functional controllers
Architecture Rule: Centralized management of instance behaviors and cross-node interactions; decoupled design with unified signal and constant invocation

## Key Constants & Signals

- **Collision masks**:
  - `COLLISION_MASK_CARD = 1` (CardManager.gd, InputManager.gd)
  - `COLLISION_MASK_CARD_SLOT = 2` (CardManager.gd)
  - `COLLISION_MASK_DECK = 4` (CardManager.gd, InputManager.gd)
- **Signals**:
  - `card.gd`: `hovered`, `hovered_off`
  - `input_manager.gd`: `left_mouse_button_clicked`, `left_mouse_button_released`
  - `OptionButton.gd`: `option_hovered`, `option_selected`, `pressed`