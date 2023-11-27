extends Node

const CENTER = Vector2(1280/2.0, 720/2.0)
const BALL_SPEED = 800
const WINNING_SCORE = 7
const SCORE_DELIMETER = " : "
const END_GAME_TIME = 1.5

@onready var scoreLabel: Label = $ScoreLabel
@onready var ball: Ball = $Ball
@onready var player1: Player = $Player1
@onready var player2: Player = $Player2
@onready var server: Player = self.player1
@onready var playerScores: Dictionary = {str(player1): 0, str(player2): 0}

func _ready() -> void:
	serve()

func serve() -> void:
	self.ball.position = CENTER
	self.ball.velocity = self.server.get_normal().rotated(randf_range(-PI/4, PI/4)) * BALL_SPEED

func update_score(scorer: Player) -> int:
	self.playerScores[str(scorer)] += 1
	var scoreString = ""
	for score in self.playerScores.values():
		scoreString += str(score) + SCORE_DELIMETER
	self.scoreLabel.text =  scoreString.left(-SCORE_DELIMETER.length())
	return self.playerScores[str(scorer)]

func end_game(winner: Player) -> void:
	self.scoreLabel.text += "\n" + winner.player_name + " wins!"
	self.ball.queue_free()
	var exploder = PlayerExploder.new()
	self.__get_other_player(winner).add_child(exploder)
	await get_tree().create_timer(END_GAME_TIME).timeout
	get_tree().change_scene_to_file("res://scenes/menu/Menu.tscn")
	

func _on_player_scored_on(player: Player) -> void:
	self.server = player
	var scorer = self.__get_other_player(player)
	
	if self.update_score(scorer) < WINNING_SCORE:
		self.serve()
	else:
		self.end_game(scorer)

func __get_other_player(player: Player):
	return player1 if player == player2 else player2
