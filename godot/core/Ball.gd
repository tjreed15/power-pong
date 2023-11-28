class_name Ball extends CharacterBody2D

const MAX_BOUNCE_ANGLE: float = PI/4
const MIN_SPEED: float = 100
const MAX_SPEED: float = 3000

@onready var colorRect: ColorRect = $ColorRect
@onready var collisionShape: CollisionShape2D = $CollisionShape2D

@export var initial_speed: float = 800.0
@export var color: Color = Color.WHITE :
	set(new_value):
		color = new_value
		if not is_node_ready():
			await ready
		self.colorRect.color = new_value

func _physics_process(delta: float) -> void:
	var collisionInfo = self.move_and_collide(self.velocity * delta)
	if collisionInfo:
		self.velocity = self.__get_velocity_from_collision(collisionInfo)
		SignalBus.ball_collided.emit(self, collisionInfo.get_collider())

func set_speed(speed: float) -> void:
	self.velocity = self.velocity.normalized() * clampf(speed, MIN_SPEED, MAX_SPEED)

func __get_velocity_from_collision(collisionInfo: KinematicCollision2D) -> Vector2:
	var vel = self.velocity.bounce(collisionInfo.get_normal())
	var normalized_vel = Vector2(abs(vel.x), vel.y).normalized()
	var angle = clamp(normalized_vel.angle(), -MAX_BOUNCE_ANGLE, MAX_BOUNCE_ANGLE)
	var vel_dir = Vector2.RIGHT.rotated(angle)
	return Vector2(vel_dir.x * sign(vel.x), vel_dir.y) * min(vel.length(), MAX_SPEED)
