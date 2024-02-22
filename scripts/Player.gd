extends CharacterBody3D

@onready var camera = $Camera3D;
@onready var anim_player = $AnimationPlayer;
@onready var muzzleflash = $Camera3D/pistol/MuzzleFlash;
@onready var raycast = $Camera3D/RayCast3D;

var health = 3;

const SPEED = 10.0
const JUMP_VELOCITY = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20

func _enter_tree():
	set_multiplayer_authority(str(name).to_int());
	
func _ready():
	if not is_multiplayer_authority(): return;
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;	
	camera.current = true;

func _unhandled_input(event):	
	if not is_multiplayer_authority(): return;
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005);
		camera.rotate_x(-event.relative.y * 0.005);
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2);
		
	if Input.is_action_just_pressed("shoot") and \
	 anim_player.current_animation != "shot":
		play_shoot_effects();
		if raycast.is_colliding():
			var hit_player = raycast.get_collider();
			hit_player.health -= 1;
			
			
		
	
func _physics_process(delta):
	if not is_multiplayer_authority(): return;
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if anim_player.current_animation == 'shot':
		pass;
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move");
	else:
		anim_player.play("idle");
		
	move_and_slide()


func play_shoot_effects():
	anim_player.stop();
	anim_player.play('shot');
	muzzleflash.restart();
	muzzleflash.emitting = true;
	
	
