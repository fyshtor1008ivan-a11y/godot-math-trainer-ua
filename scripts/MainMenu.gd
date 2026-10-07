extends Control

@onready var title_label: Label = $Content/Title
@onready var subtitle_label: Label = $Content/SubTitle
@onready var mode_buttons: Array[Button] = [
    $Content/ModePanel/ModeGrid/BtnAdd,
    $Content/ModePanel/ModeGrid/BtnSubtract,
    $Content/ModePanel/ModeGrid/BtnMultiply,
    $Content/ModePanel/ModeGrid/BtnDivide,
    $Content/ModePanel/ModeGrid/BtnMixed,
]
@onready var difficulty_buttons: Array[Button] = [
    $Content/DifficultyPanel/DifficultyGrid/BtnEasy,
    $Content/DifficultyPanel/DifficultyGrid/BtnMedium,
    $Content/DifficultyPanel/DifficultyGrid/BtnHard,
]
@onready var start_button: Button = $Content/StartButton

func _ready() -> void:
    _set_mode(Global.selected_mode)
    _set_difficulty(Global.selected_difficulty)
    _connect_buttons()
    _animate_title()
    _animate_background()

func _connect_buttons() -> void:
    for button in mode_buttons:
        button.pressed.connect(_on_mode_button_pressed.bind(button.name))
    for button in difficulty_buttons:
        button.pressed.connect(_on_difficulty_button_pressed.bind(button.name))
    start_button.pressed.connect(_on_start_pressed)

func _on_mode_button_pressed(button_name: String) -> void:
    match button_name:
        "BtnAdd":
            _set_mode("add")
        "BtnSubtract":
            _set_mode("subtract")
        "BtnMultiply":
            _set_mode("multiply")
        "BtnDivide":
            _set_mode("divide")
        "BtnMixed":
            _set_mode("mixed")

func _on_difficulty_button_pressed(button_name: String) -> void:
    match button_name:
        "BtnEasy":
            _set_difficulty("easy")
        "BtnMedium":
            _set_difficulty("medium")
        "BtnHard":
            _set_difficulty("hard")

func _set_mode(mode: String) -> void:
    Global.selected_mode = mode
    for button in mode_buttons:
        var selected: bool = false
        match mode:
            "add":
                selected = button.name == "BtnAdd"
            "subtract":
                selected = button.name == "BtnSubtract"
            "multiply":
                selected = button.name == "BtnMultiply"
            "divide":
                selected = button.name == "BtnDivide"
            "mixed":
                selected = button.name == "BtnMixed"
        if selected:
            button.modulate = Color(0.95, 0.97, 1.0, 1.0)
            button.set("theme_override_styles/normal", null)
            button.set("theme_override_styles/hover", null)
            button.set("theme_override_styles/pressed", null)
            button.set("theme_override_colors/font_color", Color(0.08, 0.12, 0.2, 1.0))
        else:
            button.modulate = Color(0.7, 0.78, 0.92, 0.9)
            button.set("theme_override_colors/font_color", Color(0.95, 0.98, 1.0, 1.0))

func _set_difficulty(difficulty: String) -> void:
    Global.selected_difficulty = difficulty
    for button in difficulty_buttons:
        var selected: bool = false
        match difficulty:
            "easy":
                selected = button.name == "BtnEasy"
            "medium":
                selected = button.name == "BtnMedium"
            "hard":
                selected = button.name == "BtnHard"
        if selected:
            button.modulate = Color(0.26, 0.82, 0.74, 1.0)
            button.set("theme_override_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
        else:
            button.modulate = Color(0.68, 0.73, 0.90, 0.85)
            button.set("theme_override_colors/font_color", Color(0.12, 0.18, 0.28, 1.0))

func _animate_title() -> void:
    var tween = create_tween().set_loops()
    tween.tween_property(title_label, "position:y", title_label.position.y - 12, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(title_label, "position:y", title_label.position.y + 12, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _animate_background() -> void:
    var bg: ColorRect = $Background
    var tween = create_tween().set_loops()
    tween.tween_property(bg, "color", Color(0.11, 0.16, 0.26, 1.0), 3.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(bg, "color", Color(0.08, 0.12, 0.20, 1.0), 3.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_start_pressed() -> void:
    Global.reset_session()
    get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
