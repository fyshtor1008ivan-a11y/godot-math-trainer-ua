extends Node

var selected_mode: String = "mixed" setget set_selected_mode
var selected_difficulty: String = "medium" setget set_selected_difficulty

var score: int = 0
var combo: int = 0
var best_combo: int = 0
var correct_answers: int = 0
var wrong_answers: int = 0
var lives: int = 3

func _ready() -> void:
    reset_session()

func reset_session() -> void:
    score = 0
    combo = 0
    best_combo = 0
    correct_answers = 0
    wrong_answers = 0
    lives = 3

func set_selected_mode(value: String) -> void:
    selected_mode = value

func set_selected_difficulty(value: String) -> void:
    selected_difficulty = value

func get_difficulty_range() -> Dictionary:
    match selected_difficulty:
        "easy":
            return {"min": 1, "max": 10}
        "hard":
            return {"min": 1, "max": 100}
        _:
            return {"min": 1, "max": 50}

func get_mode_label() -> String:
    match selected_mode:
        "add":
            return "Додавання"
        "subtract":
            return "Віднімання"
        "multiply":
            return "Множення"
        "divide":
            return "Ділення"
        _:
            return "Мікс"

func get_difficulty_name() -> String:
    match selected_difficulty:
        "easy":
            return "Легкий"
        "hard":
            return "Важкий"
        _:
            return "Середній"
