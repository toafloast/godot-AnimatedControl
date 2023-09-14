@icon("res://addons/AnimatedControl/animated_control_icon.png")
@tool
extends Control
class_name AnimatedControl


@export var target_controls : Array[Control]:
	set(value):
		for i in value.size():
			var meta_name = "blend_"+str(i)
			set_meta(meta_name, get_meta(meta_name, 0.0))
			print("%s: Added meta %s" % [name, meta_name])
		for over_meta in get_meta_list():
			if over_meta.begins_with("blend_"):
				var num = over_meta.split("_", false)[1]
				if int(num) > value.size()-1:
					print("%s: Removed meta %s" % [name, over_meta])
					remove_meta(over_meta)
		notify_property_list_changed.call_deferred()
		target_controls = value
@export var interpolate_size : bool = false


func _get_configuration_warnings() -> PackedStringArray:
	if target_controls.size() == 0:
		return ["No target controls set."]
	if target_controls[0] == null:
		return ["0th index must be set."]
	return []


func _process(delta: float) -> void:
	if Engine.get_process_frames() % 20 == 0:
		update_configuration_warnings()
	if target_controls.size() > 0:
		if target_controls[0] == null:
			return
		global_position = target_controls[0].global_position
		if interpolate_size:
			size = target_controls[0].size
		for i in target_controls.size():
			if target_controls[i] == null:
				continue
			var blend_amount = get_meta("blend_"+str(i),null)
			if blend_amount == null:
				set_meta("blend_"+str(i), 0.0)
				blend_amount = 0.0
			global_position = lerp(global_position, target_controls[i].global_position, blend_amount)
			if interpolate_size:
				size = lerp(size, target_controls[i].size, blend_amount)


func set_blend(blend_name : String, value : float) -> void:
	set_meta(blend_name, value)


func tween_blends(blend_name : String, final_value : float = 0.0, duration : float = 0.0, _transition : Variant = Tween.TRANS_LINEAR, _ease : Variant = Tween.EASE_OUT) -> void:
	var tween := create_tween()
	#Setting the ease
	if _ease is int:
		tween.set_ease(_ease)
	if _ease is String:
		match _ease:
			"EASE_IN":tween.set_ease(Tween.EASE_IN)
			"EASE_IN_OUT":tween.set_ease(Tween.EASE_IN_OUT)
			"EASE_OUT":tween.set_ease(Tween.EASE_OUT)
			"EASE_OUT_IN":tween.set_ease(Tween.EASE_OUT_IN)
	#Setting the transition
	if _transition is int:
		tween.set_trans(_transition)
	if _transition is String:
		Tween.TRANS_LINEAR
		match _transition:
			"TRANS_LINEAR": 	tween.set_trans(Tween.TRANS_LINEAR)
			"TRANS_SINE":		tween.set_trans(Tween.TRANS_SINE)
			"TRANS_QUINT": 		tween.set_trans(Tween.TRANS_QUINT)
			"TRANS_QUART": 		tween.set_trans(Tween.TRANS_QUART)
			"TRANS_QUAD": 		tween.set_trans(Tween.TRANS_QUAD)
			"TRANS_EXPO": 		tween.set_trans(Tween.TRANS_EXPO)
			"TRANS_ELASTIC": 	tween.set_trans(Tween.TRANS_ELASTIC)
			"TRANS_CUBIC": 		tween.set_trans(Tween.TRANS_CUBIC)
			"TRANS_CIRC": 		tween.set_trans(Tween.TRANS_CIRC)
			"TRANS_BOUNCE": 	tween.set_trans(Tween.TRANS_BOUNCE)
			"TRANS_BACK": 		tween.set_trans(Tween.TRANS_BACK)
			"TRANS_SPRING":		tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "metadata/"+blend_name, final_value, duration)
