extends CharacterBody2D

var speed : int = 150
var looking_left : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player_movement()
	player_animation()

func player_animation() -> void:
	if velocity.x > 0 and looking_left:
		$Sprite2D.flip_h = !$Sprite2D.flip_h
		looking_left = !looking_left
	elif velocity.x < 0 and !looking_left:
		$Sprite2D.flip_h = !$Sprite2D.flip_h
		looking_left = !looking_left
		
		
func player_movement() -> void:
	var input = Input.get_vector("left","right","up","down")

	velocity = input.normalized() * speed
	
	move_and_slide()
