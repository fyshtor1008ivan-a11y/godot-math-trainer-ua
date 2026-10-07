extends Control

@onready var score_value: Label = $Panel/Stats/ScoreRow/ScoreValue
@onready var combo_value: Label = $Panel/Stats/ComboRow/ComboValue
@onready var correct_value: Label = $Panel/Stats/CorrectRow/CorrectValue
@onready var wrong_value: Label = $Panel/Stats/WrongRow/WrongValue
@onready var retry_button: Button = $Panel/Stats/Buttons/RetryButton
@onready var menu_button: Button = $Panel/Stats/Buttons/MenuButton

func _ready() -> void:
    _connect_buttons()
    _update_stats()

func _connect_buttons() -> void:
    retry_button.pressed.connect(_on_retry_pressed)
    menu_button.pressed.connect(_on_menu_pressed)

func _update_stats() -> void:
    score_value.text = str(Global.score)
    combo_value.text = str(Global.best_combo)
    correct_value.text = str(Global.correct_answers)
    wrong_value.text = str(Global.wrong_answers)

func _on_retry_pressed() -> void:
    Global.reset_session()
    get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func _on_menu_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
