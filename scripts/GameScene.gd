extends Control

@onready var round_timer: Timer = $HUD/RoundTimer
@onready var progress_bar: ProgressBar = $HUD/TimeBar
@onready var score_label: Label = $HUD/TopBar/ScoreValue
@onready var combo_label: Label = $HUD/TopBar/ComboValue
@onready var lives_label: Label = $HUD/TopBar/LivesValue
@onready var status_label: Label = $HUD/StatusLabel
@onready var question_label: Label = $QuestionPanel/VBox/QuestionLabel
@onready var answer_grid: GridContainer = $QuestionPanel/VBox/AnswerGrid
@onready var confetti: CPUParticles2D = $Effects/Confetti
@onready var camera: Camera2D = $Effects/Camera2D

var current_question: Dictionary = {}
var answer_buttons: Array[Button] = []
var warning_tween: Tween
var countdown_tween: Tween

func _ready() -> void:
    _build_answer_buttons()
    _setup_timer()
    _generate_question()
    _update_hud()
    _spawn_background_particles()

func _build_answer_buttons() -> void:
    answer_buttons = [
        $QuestionPanel/VBox/AnswerGrid/Answer1,
        $QuestionPanel/VBox/AnswerGrid/Answer2,
        $QuestionPanel/VBox/AnswerGrid/Answer3,
        $QuestionPanel/VBox/AnswerGrid/Answer4,
    ]
    for button in answer_buttons:
        button.pressed.connect(_on_answer_pressed.bind(button))
        button.mouse_entered.connect(_on_button_hover.bind(button))
        button.mouse_exited.connect(_on_button_hover_end.bind(button))

func _setup_timer() -> void:
    round_timer.wait_time = 30.0
    round_timer.one_shot = true
    round_timer.timeout.connect(_on_round_timer_timeout)
    progress_bar.max_value = 30.0
    progress_bar.min_value = 0.0
    progress_bar.value = 30.0

func _spawn_background_particles() -> void:
    # Плавна neumorphic/неонова фонова “пилюка”
    pass

func _generate_question() -> void:
    current_question = _create_question()
    question_label.text = str(current_question["left"]) + " " + current_question["operator_symbol"] + " " + str(current_question["right"]) + " = ?"
    _populate_answers(current_question["answer"])
    _start_round_timer()
    _update_hud()
    status_label.text = "Нова задача"
    status_label.modulate = Color(0.8, 0.95, 1.0, 1.0)

func _create_question() -> Dictionary:
    var mode: String = Global.selected_mode
    if mode == "mixed":
        var ops = ["add", "subtract", "multiply", "divide"]
        mode = ops[randi() % ops.size()]

    var range_data = Global.get_difficulty_range()
    var min_value: int = range_data["min"]
    var max_value: int = range_data["max"]

    var left: int
    var right: int
    var result: int

    match mode:
        "add":
            left = randi_range(min_value, max_value)
            right = randi_range(min_value, max_value)
            result = left + right
            return {"left": left, "right": right, "operator_symbol": "+", "answer": result, "operation": "add"}
        "subtract":
            left = randi_range(min_value, max_value)
            right = randi_range(min_value, max_value)
            if Global.selected_difficulty == "easy":
                if right > left:
                    var temp = left
                    left = right
                    right = temp
            result = left - right
            return {"left": left, "right": right, "operator_symbol": "−", "answer": result, "operation": "subtract"}
        "multiply":
            left = randi_range(min_value, max_value)
            right = randi_range(min_value, max_value)
            result = left * right
            return {"left": left, "right": right, "operator_symbol": "×", "answer": result, "operation": "multiply"}
        "divide":
            var divisor: int = randi_range(1, max_value)
            var quotient: int = randi_range(1, max_value)
            left = divisor * quotient
            right = divisor
            result = quotient
            return {"left": left, "right": right, "operator_symbol": "÷", "answer": result, "operation": "divide"}
        _:
            left = randi_range(min_value, max_value)
            right = randi_range(min_value, max_value)
            result = left + right
            return {"left": left, "right": right, "operator_symbol": "+", "answer": result, "operation": "add"}

func _populate_answers(correct_answer: int) -> void:
    var possible_answers: Array[int] = [correct_answer]
    while possible_answers.size() < 4:
        var candidate: int = correct_answer + randi_range(-20, 20)
        if candidate != correct_answer and candidate >= 0 and not possible_answers.has(candidate):
            possible_answers.append(candidate)
    possible_answers.shuffle()

    for i in range(answer_buttons.size()):
        answer_buttons[i].text = str(possible_answers[i])
        answer_buttons[i].disabled = false
        answer_buttons[i].modulate = Color(1, 1, 1, 1)

func _start_round_timer() -> void:
    round_timer.stop()
    if countdown_tween:
        countdown_tween.kill()
    progress_bar.value = 30.0
    progress_bar.modulate = Color(0.4, 1.0, 0.75, 1.0)
    countdown_tween = create_tween()
    countdown_tween.tween_property(progress_bar, "value", 0.0, 30.0)
    round_timer.start(30.0)

func _on_answer_pressed(button: Button) -> void:
    var chosen_value: int = int(button.text)
    var is_correct: bool = chosen_value == current_question["answer"]

    for current_button in answer_buttons:
        current_button.disabled = true

    if is_correct:
        _handle_correct_answer(button)
    else:
        _handle_wrong_answer(button)

func _handle_correct_answer(button: Button) -> void:
    Global.combo += 1
    Global.best_combo = max(Global.best_combo, Global.combo)
    Global.correct_answers += 1
    var bonus: int = 10 + Global.combo * 5
    Global.score += bonus
    _update_hud()
    _flash_answer(button, Color(0.35, 1.0, 0.5, 1.0))
    status_label.text = "Правильно!"
    status_label.modulate = Color(0.35, 1.0, 0.55, 1.0)
    _trigger_confetti()
    _animate_combo_label()
    round_timer.stop()
    if countdown_tween:
        countdown_tween.kill()
    await get_tree().create_timer(0.35).timeout
    _generate_question()

func _handle_wrong_answer(button: Button) -> void:
    Global.combo = 0
    Global.wrong_answers += 1
    Global.lives -= 1
    _update_hud()
    _flash_answer(button, Color(1.0, 0.3, 0.3, 1.0))
    status_label.text = "Помилка!"
    status_label.modulate = Color(1.0, 0.35, 0.35, 1.0)
    _shake_camera()
    round_timer.stop()
    if countdown_tween:
        countdown_tween.kill()
    await get_tree().create_timer(0.45).timeout
    if Global.lives <= 0:
        get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
    else:
        _generate_question()

func _on_round_timer_timeout() -> void:
    Global.combo = 0
    Global.wrong_answers += 1
    Global.lives -= 1
    _update_hud()
    _shake_camera()
    status_label.text = "Час вийшов!"
    status_label.modulate = Color(1.0, 0.5, 0.25, 1.0)
    if Global.lives <= 0:
        get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
    else:
        await get_tree().create_timer(0.45).timeout
        _generate_question()

func _update_hud() -> void:
    score_label.text = "Рахунок: " + str(Global.score)
    combo_label.text = "Комбо: x" + str(Global.combo)
    lives_label.text = "Життя: " + str(Global.lives)

func _flash_answer(button: Button, color: Color) -> void:
    var tween = create_tween()
    tween.tween_property(button, "scale", Vector2(1.08, 1.08), 0.08)
    tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.12)
    tween.parallel().tween_property(button, "modulate", color, 0.1)

func _trigger_confetti() -> void:
    confetti.emitting = true
    confetti.restart()

func _shake_camera() -> void:
    var tween = create_tween()
    tween.tween_property(camera, "offset", Vector2(12, 0), 0.03)
    tween.tween_property(camera, "offset", Vector2(-12, 4), 0.03)
    tween.tween_property(camera, "offset", Vector2(8, -3), 0.03)
    tween.tween_property(camera, "offset", Vector2(0, 0), 0.05)

func _animate_combo_label() -> void:
    var tween = create_tween()
    tween.tween_property(combo_label, "scale", Vector2(1.25, 1.25), 0.12)
    tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.14)

func _on_button_hover(button: Button) -> void:
    var tween = create_tween()
    tween.tween_property(button, "scale", Vector2(1.04, 1.04), 0.08)

func _on_button_hover_end(button: Button) -> void:
    var tween = create_tween()
    tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.08)

func _process(_delta: float) -> void:
    if not round_timer.is_stopped():
        var time_left = round_timer.time_left
        if time_left <= 7.0:
            progress_bar.modulate = Color(1.0, 0.2, 0.2, 1.0)
            if warning_tween == null or not warning_tween.is_running():
                warning_tween = create_tween().set_loops()
                warning_tween.tween_property(progress_bar, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.12)
                warning_tween.tween_property(progress_bar, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
        else:
            progress_bar.modulate = Color(0.45, 1.0, 0.75, 1.0)
            if warning_tween != null and warning_tween.is_running():
                warning_tween.stop()
