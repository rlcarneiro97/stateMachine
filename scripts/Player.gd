extends KinematicBody2D

var velocity = Vector2()

var enterState := true
var currentState := 0
enum {IDLE, ATTACK, RUN, JUMP, FALL, SLIDE, ATTACK2, ATTACK3}

func _physics_process(delta):
	match currentState:
		IDLE:
			_idleState(delta)
		ATTACK:
			_attackState(delta)
		RUN:
			_runState(delta)
		JUMP:
			_jumpState(delta)
		FALL:
			_fallState(delta)
		SLIDE:
			_slideState(delta)
		ATTACK2:
			_attack2State(delta)
		ATTACK3:
			_attack3State(delta)
			
# CHECK FUNCTIONS
func _checkIdleState():
	var newState = currentState
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		newState = RUN
	elif Input.is_action_pressed("ui_space"):
		newState = ATTACK
	elif Input.is_action_pressed("ui_up"):
		newState = JUMP
	elif !is_on_floor():
		newState = FALL
	return newState

func _checkAttackState():
	var newState = currentState
	if $AnimatedSprite.animation == "Attack" and Input.is_action_pressed("ui_space"):
		newState = ATTACK2
	elif $AnimatedSprite.animation == "Attack":
		newState = IDLE
	return newState
	
func _checkAttack2State():
	var newState = currentState
	if $AnimatedSprite.animation == "Attack2" and Input.is_action_pressed("ui_space"):
		newState = ATTACK3
	elif $AnimatedSprite.animation == "Attack2":
		newState = IDLE
	return newState
	
func _checkAttack3State():
	var newState = currentState
	if $AnimatedSprite.animation == "Attack3":
		newState = IDLE
	return newState
	
func _checkRunState():
	var newState = currentState
	if !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
		newState = IDLE
	elif Input.is_action_pressed("ui_space"):
		newState = ATTACK
	elif Input.is_action_pressed("ui_up"):
		newState = JUMP
	elif Input.is_action_pressed("ui_down"):
		newState = SLIDE
	elif !is_on_floor():
		newState = FALL
	return newState

func _checkJumpState():
	var newState = currentState
	if velocity.y >= 0:
		newState = FALL
	elif Input.is_action_pressed("ui_space"):
		newState = ATTACK
	return newState

func _checkFallState():
	var newState = currentState
	if is_on_floor():
		newState = IDLE
	elif Input.is_action_pressed("ui_space"):
		newState = ATTACK
	return newState

func _checkSlideState():
	var newState = currentState
	if abs(round(velocity.x)) <= 20:
		newState = IDLE
	elif !is_on_floor():
		newState = FALL
	return newState

# STATE FUNCTIONS
func _idleState(_delta):
	$AnimatedSprite.play("Idle")
	_applyGravity(_delta)
	velocity.x = 0
	_move_and_slide()
	_setState(_checkIdleState())
	
func _attackState(_delta):
	$AnimatedSprite.play("Attack")
	_applyGravity(_delta)
	if is_on_floor():
		velocity.x = 0
	_move_and_slide()
	yield(get_node("AnimatedSprite"), "animation_finished")
	_setState(_checkAttackState())
	
func _attack2State(_delta):
	$AnimatedSprite.play("Attack2")
	_applyGravity(_delta)
	if is_on_floor():
		velocity.x = 0
	_move_and_slide()
	yield(get_node("AnimatedSprite"), "animation_finished")
	_setState(_checkAttack2State())
	
func _attack3State(_delta):
	$AnimatedSprite.play("Attack3")
	_applyGravity(_delta)
	if is_on_floor():
		velocity.x = 0
	_move_and_slide()
	yield(get_node("AnimatedSprite"), "animation_finished")
	_setState(_checkAttack3State())

func _runState(_delta):
	$AnimatedSprite.play("Run")
	_move()
	_applyGravity(_delta)
	_move_and_slide()
	_setState(_checkRunState())
	
func _jumpState(_delta):
	if enterState:
		$AnimatedSprite.play("Jump")
		velocity.y = -450
		enterState = false
		
	_applyGravity(_delta)
	_move()
	_move_and_slide()
	_setState(_checkJumpState())
	
func _fallState(_delta):
	$AnimatedSprite.play("Fall")
	_applyGravity(_delta)
	_move()
	_move_and_slide()
	_setState(_checkFallState())

func _slideState(_delta):
	$AnimatedSprite.play("Slide")
	_applyGravity(_delta)
	_move_and_slide()
	velocity.x = lerp(velocity.x, 0, 0.04)
	_setState(_checkSlideState())

# HELPERS
func _applyGravity(_delta):
	velocity.y += 800 * _delta
	
func _move_and_slide():
	velocity = move_and_slide(velocity, Vector2.UP)

func _move():
	if Input.is_action_pressed("ui_left"):
		velocity.x = -250
		$AnimatedSprite.flip_h = true
	elif Input.is_action_pressed("ui_right"):
		velocity.x = 250
		$AnimatedSprite.flip_h = false

func _setState(newState):
	if newState != currentState:
		enterState = true
	currentState = newState
