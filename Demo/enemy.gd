extends CharacterBody2D

@export var speed = 200
@export var gravity : float = 30
@export var sprite = "chicken"
var time_run = 0
var facing = 1
var canturn = true
var spawn_point 
var alive = true

func _ready() -> void:
	$AnimatedSprite2D.play()
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	sprite = $AnimatedSprite2D.animation
	facing = 1 if randf()< 0.5 else -1
	velocity.x = speed * facing
	spawn_point = position
	
func _process(delta: float) -> void:		
	if !alive: return
	if !is_on_floor():
		velocity.y += gravity
	if time_run > 1 && abs(velocity.x) < 50 && canturn == true:
		canturn = false
		await get_tree().create_timer(0.1).timeout
		canturn = true
		facing = 1 if facing == -1 else -1
		velocity.x = speed * facing
		time_run = 0
	#if  !$AnimatedSprite2D.is_playing() || $AnimatedSprite2D.animation != sprite :
	#	$AnimatedSprite2D.play(sprite)
	$AnimatedSprite2D.flip_h = -velocity.x > 0.0 
	time_run += delta
	move_and_slide()
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player") && alive:
		death_tween()

func death_tween():
	alive = false
	GameManager.add_score()
	$CPUParticles2D.emitting = true
	$Bodysplat.play()
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$HitArea/CollisionShape2D.set_deferred("disabled", true)
	velocity.x = 0
	gravity = 0
	await get_tree().create_timer(1).timeout
	hide()
	var delay = randf_range(5,10)
	await get_tree().create_timer(delay).timeout
	respawn_tween()

func respawn_tween():
	velocity.y = 0
	position = spawn_point
	$AnimatedSprite2D.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	$HitArea/CollisionShape2D.set_deferred("disabled", false)
	gravity = 30
	show()
	alive = true
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2) 
	await tween.finished
	$AnimatedSprite2D.play(sprite)
	velocity.x = speed if randf()< 0.5 else -speed
	velocity.y = -200	
