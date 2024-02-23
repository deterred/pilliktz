extends CharacterBody3D

signal health_changed(health_value);


@onready var camera = $Camera3D;
@onready var anim_player = $AnimationPlayer;
@onready var muzzleflash = $Camera3D/pistol/MuzzleFlash;
@onready var raycast = $Camera3D/RayCast3D;

@onready var playerBody = $body
@onready var nicknamelabel = $playerid

var player_color : Color = Color("000000");


var health = 3;

const SPEED = 10.0
const JUMP_VELOCITY = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20

func _enter_tree():
	set_multiplayer_authority(str(name).to_int());
	
func _ready():
	if !is_multiplayer_authority():	
		setnick();
		#setcolor();


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
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
			
			
		
	
func _physics_process(delta):

		#setcolor();
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



@rpc("any_peer")
func sync_color(new_color: Color) -> void:
	print("sync_color")
	player_color = new_color
	var material = playerBody.get_surface_override_material(0)
	material.albedo_color = player_color;
	playerBody.set_surface_override_material(0, material)
	
func change_color(new_color: Color) -> void:
	print("change_color "+ str(new_color))
	player_color = new_color
	rpc("sync_color", new_color)

@rpc("any_peer", "call_local", "unreliable")
func setnick():
	if not is_multiplayer_authority():
		print("setnick" + str(name));		
		nicknamelabel.text = str(name);
		
	
@rpc("any_peer")
func receive_damage():
	health -=1;
	if (health <= 0):
		health = 3;
		position = Vector3.ZERO;
	health_changed.emit(health);


