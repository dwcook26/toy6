extends CharacterBody2D


const SPEED = 400.0
const ACCELERATION = 1200
const DECELERATION = 2400
const JUMP_VELOCITY = -400.0

@onready var jump_sound = $JumpSound
@onready var land_sound = $LandSound
@onready var coyoteTimer = $coyoteTimer
@onready var jumpTimer = $jumpTimer
@onready var sprite_2d = $Sprite2D
@onready var spawn = $"../level1/spawn"
@onready var camera_2d = $"../Camera2D"

func _ready():
	set_floor_snap_length(1.3)
	var levels = []
	levels = get_parent().get_children()
	levels.pop_at(0)
	print(levels)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var doubleJumpCharge = 1
var coyoteJumpCharge = 1
var inAir = 1
var facedDirection = 1
var jumpedRecently
var levelNum = 1
var konamiCode = ["ui_up","ui_up","ui_down","ui_down","ui_left","ui_right","ui_left","ui_right","b","a"]
var konamiIndex = 0

func _physics_process(delta):
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jumpedRecently = 1
		jumpTimer.start()
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
		
	elif Input.is_action_just_pressed("ui_accept") and coyoteJumpCharge == 1:
		coyoteJumpCharge = 0
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
		
	elif Input.is_action_just_pressed("ui_accept") and doubleJumpCharge == 1:
		doubleJumpCharge = 0
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction == facedDirection:
		velocity.x = move_toward(velocity.x, SPEED * direction, ACCELERATION * delta)
		sprite_2d.rotate(0.05 * velocity.x * delta)
	elif direction != facedDirection:
		velocity.x = move_toward(velocity.x, SPEED * direction, DECELERATION * delta)
		sprite_2d.rotate(0.05 * velocity.x * delta)
		if velocity.x == 0:
			facedDirection *= -1
			
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		sprite_2d.rotate(0.05 * velocity.x * delta)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if (inAir == 0 and jumpedRecently == 0):
			coyoteJumpCharge = 1
			coyoteTimer.start()
		inAir = 1
	else:
		doubleJumpCharge = 1
		coyoteJumpCharge = 0
		if inAir == 1:
			inAir = 0
			land_sound.play()
			
	# Konami Code detection
	if not Input.is_action_pressed(konamiCode[konamiIndex]) and Input.is_anything_pressed() == true and Input.is_action_just_released(konamiCode[konamiIndex]):
			konamiIndex = 0
	elif Input.is_action_just_pressed(konamiCode[konamiIndex]):
		konamiIndex += 1
	if konamiIndex == 10:
		konamiIndex = 0
		self.position.x = 0
		self.position.y = 0
		camera_2d.position.x = 640
		camera_2d.position.y = 360
	print(konamiIndex)
		

	move_and_slide()


func _on_coyote_timer_timeout():
	coyoteJumpCharge == 0


func _on_jump_timer_timeout():
	jumpedRecently = 0



func _on_pit_body_entered(body):
	print(spawn.position)
	print(self.position)
	self.position = spawn.position


func _on_exit_body_entered(body):
	# WARNING!!! GROSS AHEAD!!!! 
	if body == self:
		levelNum += 1
		print(get_parent().get_child(levelNum).get_child(2))
		self.position = get_parent().get_child(levelNum + 1).get_child(2).position
		print(len(get_parent().get_children()) - 1)
		get_parent().get_child(len(get_parent().get_children()) - 1).position.y += 720
