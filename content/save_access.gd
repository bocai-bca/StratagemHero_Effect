extends RefCounted
class_name StratagemHeroEffect_SaveAccess
## 存档访问

static var save_struct_in_memory: SaveStruct = SaveStruct.new()

static func load_save() -> bool:
	var save_data_path: String = "user://save_data.json"
	if (not FileAccess.file_exists(save_data_path)):
		return false
	var json: JSON = JSON.new()
	var file_content: String = FileAccess.get_file_as_string(save_data_path)
	if (file_content.is_empty()):
		push_error("StratagemHeroEffect_SaveAccess: Failed to read save data file, ErrorCode=", FileAccess.get_open_error())
		return false
	if (json.parse(file_content) != OK):
		push_error("StratagemHeroEffect_SaveAccess: Failed to parse save data, ErrorLine=", json.get_error_line(), " ErrorMessage=", json.get_error_message())
		return false
	var data_dictionary: Dictionary = json.data as Dictionary
	if (data_dictionary == null):
		push_error("StratagemHeroEffect_SaveAccess: Failed to parse save data, parsed data is not Dictionary")
		return false
	if (data_dictionary.has("volume_music")):
		save_struct_in_memory.volume_music = data_dictionary.get("volume_music", 0.8) as float
	if (data_dictionary.has("volume_sfx")):
		save_struct_in_memory.volume_sfx = data_dictionary.get("volume_sfx", 0.8) as float
	if (data_dictionary.has("element_scale")):
		save_struct_in_memory.element_scale = data_dictionary.get("element_scale", 1.0) as float
	if (data_dictionary.has("arrow_style")):
		save_struct_in_memory.arrow_style = data_dictionary.get("arrow_style", 0) as int
	if (data_dictionary.has("sfx_variant")):
		save_struct_in_memory.sfx_variant = data_dictionary.get("sfx_variant", "normal") as String
	if (data_dictionary.has("classic_high_score")):
		save_struct_in_memory.classic_high_score = HighScoreStruct.from_dictionary(data_dictionary.get("classic_high_score", null))
	if (data_dictionary.has("classic_high_level")):
		save_struct_in_memory.classic_high_level = HighScoreStruct.from_dictionary(data_dictionary.get("classic_high_level", null))
	if (data_dictionary.has("effect_high_score_none")):
		save_struct_in_memory.effect_high_score_none = EffectHighScoreStruct.from_dictionary_deep(data_dictionary.get("effect_high_score_none", null))
	if (data_dictionary.has("effect_high_score_dictation")):
		save_struct_in_memory.effect_high_score_dictation = EffectHighScoreStruct.from_dictionary_deep(data_dictionary.get("effect_high_score_dictation", null))
	if (data_dictionary.has("effect_high_score_greatwall")):
		save_struct_in_memory.effect_high_score_greatwall = EffectHighScoreStruct.from_dictionary_deep(data_dictionary.get("effect_high_score_greatwall", null))
	if (data_dictionary.has("effect_high_score_multilines")):
		save_struct_in_memory.effect_high_score_multilines = EffectHighScoreStruct.from_dictionary_deep(data_dictionary.get("effect_high_score_multilines", null))
	if (data_dictionary.has("effect_high_score_terminal")):
		save_struct_in_memory.effect_high_score_terminal = EffectHighScoreStruct.from_dictionary_deep(data_dictionary.get("effect_high_score_terminal", null))
	if (data_dictionary.has("effect_mode_stratagems_enabled")):
		save_struct_in_memory.effect_mode_stratagems_enabled = SaveStruct.stratagems_enabled_from_var(data_dictionary.get("effect_mode_stratagems_enabled", []))
	return true

static func store_save() -> bool:
	var save_data_path: String = "user://save_data.json"
	var file_access: FileAccess = FileAccess.open(save_data_path, FileAccess.WRITE)
	if (file_access == null):
		push_error("StratagemHeroEffect_SaveAccess: Failed to open save data FileAccess, ErrorCode=", FileAccess.get_open_error())
		return false
	var data_dictionary: Dictionary[String, Variant] = {
		"volume_music": save_struct_in_memory.volume_music,
		"volume_sfx": save_struct_in_memory.volume_sfx,
		"element_scale": save_struct_in_memory.element_scale,
		"arrow_style": save_struct_in_memory.arrow_style,
		"sfx_variant": save_struct_in_memory.sfx_variant,
		"classic_high_score": save_struct_in_memory.classic_high_score.to_dictionary(),
		"classic_high_level": save_struct_in_memory.classic_high_level.to_dictionary(),
		"effect_high_score_none": save_struct_in_memory.effect_high_score_none.to_dictionary_deep(),
		"effect_high_score_dictation": save_struct_in_memory.effect_high_score_dictation.to_dictionary_deep(),
		"effect_high_score_greatwall": save_struct_in_memory.effect_high_score_greatwall.to_dictionary_deep(),
		"effect_high_score_multilines": save_struct_in_memory.effect_high_score_multilines.to_dictionary_deep(),
		"effect_high_score_terminal": save_struct_in_memory.effect_high_score_terminal.to_dictionary_deep(),
		"effect_mode_stratagems_enabled": save_struct_in_memory.effect_mode_stratagems_enabled,
	}
	if (not file_access.store_string(JSON.stringify(data_dictionary, "\t"))):
		push_error("StratagemHeroEffect_SaveAccess: Error on storing save data, ErrorCode=", file_access.get_error())
		return false
	return true

## 检查并在可用时记录经典模式最高分，如果刷新最高分记录则返回true，否则返回false
static func check_and_save_classic_score(new_score: int, new_reach_round: int) -> bool:
	if (save_struct_in_memory == null):
		save_struct_in_memory = SaveStruct.new()
	var this_struct: HighScoreStruct = HighScoreStruct.new()
	this_struct.score = new_score
	this_struct.reach_level = new_reach_round
	var result: bool = false
	if (save_struct_in_memory.classic_high_score == null):
		save_struct_in_memory.classic_high_score = this_struct
		result = true
	elif (save_struct_in_memory.classic_high_score.score == this_struct.score):
		if (save_struct_in_memory.classic_high_score.reach_level < this_struct.reach_level):
			save_struct_in_memory.classic_high_score = this_struct
			result = true
	elif (save_struct_in_memory.classic_high_score.score < this_struct.score):
		save_struct_in_memory.classic_high_score = this_struct
		result = true
	if (save_struct_in_memory.classic_high_level == null):
		save_struct_in_memory.classic_high_level = this_struct
		result = true
	elif (save_struct_in_memory.classic_high_level.reach_level == this_struct.reach_level):
		if (save_struct_in_memory.classic_high_level.score < this_struct.score):
			save_struct_in_memory.classic_high_level = this_struct
			result = true
	elif (save_struct_in_memory.classic_high_level.reach_level < this_struct.reach_level):
		save_struct_in_memory.classic_high_level = this_struct
		result = true
	if (result):
		store_save()
		print("New high score for classic mode")
	return result

## 检查并在可用时记录效果模式最高分，如果刷新最高分记录则返回true，否则返回false
static func check_and_save_effect_score(special_mode: StratagemHeroEffect_EffectGame.SpecialEffectMode, new_score: int, new_reach_round: int, new_speed_for_minute: float) -> bool:
	if (save_struct_in_memory == null):
		save_struct_in_memory = SaveStruct.new()
	var this_struct: HighScoreStruct = HighScoreStruct.new()
	this_struct.score = new_score
	this_struct.reach_level = new_reach_round
	this_struct.speed_per_minute = new_speed_for_minute
	var result: bool = false
	var target_effect_high_score_struct: EffectHighScoreStruct
	match (special_mode):
		StratagemHeroEffect_EffectGame.SpecialEffectMode.NONE:
			target_effect_high_score_struct = save_struct_in_memory.effect_high_score_none
		StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION:
			target_effect_high_score_struct = save_struct_in_memory.effect_high_score_dictation
		StratagemHeroEffect_EffectGame.SpecialEffectMode.GREATWALL:
			target_effect_high_score_struct = save_struct_in_memory.effect_high_score_greatwall
		StratagemHeroEffect_EffectGame.SpecialEffectMode.MULTILINES:
			target_effect_high_score_struct = save_struct_in_memory.effect_high_score_multilines
		StratagemHeroEffect_EffectGame.SpecialEffectMode.TERMINAL:
			target_effect_high_score_struct = save_struct_in_memory.effect_high_score_terminal
		_:
			return false
	if (target_effect_high_score_struct == null):
		target_effect_high_score_struct = EffectHighScoreStruct.new()
	if (target_effect_high_score_struct.high_score == null):
		target_effect_high_score_struct.high_score = this_struct
		result = true
	elif (target_effect_high_score_struct.high_score.score == this_struct.score):
		if (target_effect_high_score_struct.high_score.reach_level < this_struct.reach_level and target_effect_high_score_struct.high_score.speed_per_minute < this_struct.speed_per_minute):
			target_effect_high_score_struct.high_score = this_struct
			result = true
	elif (target_effect_high_score_struct.high_score.score < this_struct.score):
		target_effect_high_score_struct.high_score = this_struct
		result = true
	if (target_effect_high_score_struct.high_level == null):
		target_effect_high_score_struct.high_level = this_struct
		result = true
	elif (target_effect_high_score_struct.high_level.reach_level == this_struct.reach_level):
		if (target_effect_high_score_struct.high_level.score < this_struct.score and target_effect_high_score_struct.high_level.speed_per_minute < this_struct.speed_per_minute):
			target_effect_high_score_struct.high_level = this_struct
			result = true
	elif (target_effect_high_score_struct.high_level.reach_level < this_struct.reach_level):
		target_effect_high_score_struct.high_level = this_struct
		result = true
	if (target_effect_high_score_struct.high_speed == null):
		target_effect_high_score_struct.high_speed = this_struct
		result = true
	elif (target_effect_high_score_struct.high_speed.speed_per_minute == this_struct.speed_per_minute):
		if (target_effect_high_score_struct.high_speed.score < this_struct.score and target_effect_high_score_struct.high_speed.reach_level < this_struct.reach_level):
			target_effect_high_score_struct.high_speed = this_struct
			result = true
	elif (target_effect_high_score_struct.high_speed.speed_per_minute < this_struct.speed_per_minute):
		target_effect_high_score_struct.high_speed = this_struct
		result = true
	if (result):
		store_save()
		print("New high score for effect mode")
	return result

## 清除分数，实际上的行为是新建一个SaveStruct实例然后把音量数据转移过去
static func clear_score() -> void:
	if (save_struct_in_memory == null):
		return
	var new_save: SaveStruct = SaveStruct.new()
	new_save.volume_music = save_struct_in_memory.volume_music
	new_save.volume_sfx = save_struct_in_memory.volume_sfx
	save_struct_in_memory = new_save

## 存档主要结构类
class SaveStruct extends RefCounted:
	var volume_music: float = 0.8
	var volume_sfx: float = 0.8
	var element_scale: float = 1.0
	var arrow_style: int = 0
	var sfx_variant: String = "normal"
	var classic_high_score: HighScoreStruct = HighScoreStruct.new()
	var classic_high_level: HighScoreStruct = HighScoreStruct.new()
	var effect_high_score_none: EffectHighScoreStruct = EffectHighScoreStruct.new()
	var effect_high_score_dictation: EffectHighScoreStruct = EffectHighScoreStruct.new()
	var effect_high_score_greatwall: EffectHighScoreStruct = EffectHighScoreStruct.new()
	var effect_high_score_multilines: EffectHighScoreStruct = EffectHighScoreStruct.new()
	var effect_high_score_terminal: EffectHighScoreStruct = EffectHighScoreStruct.new()
	var effect_mode_stratagems_enabled: Array[StringName] = StratagemData.list.keys() as Array[StringName]
	static func stratagems_enabled_from_var(var_data: Variant) -> Array[StringName]:
		var result: Array[StringName] = []
		var array_data: Array = var_data as Array
		if (array_data == null):
			return result
		for obj in array_data:
			var str_obj: String = obj as String
			if (str_obj == null):
				continue
			result.append(StringName(str_obj))
		return result

## 高分对象结构类，代表一个最高分记录。每个成员变量的值如果小于0代表该值处于无效作用
class HighScoreStruct extends RefCounted:
	## 分数
	var score: int = -1
	## 抵达回合、等级
	var reach_level: int = -1
	## 平均速度
	var speed_per_minute: float = -1.0
	## 转换到字典
	func to_dictionary() -> Dictionary[String, Variant]:
		var result: Dictionary[String, Variant] = {
			"score": score,
			"reach_level": reach_level,
			"speed_per_minute": speed_per_minute,
		}
		return result
	## 从字典转换，如果给定的字典缺少值，则对应值会保留HighScoreStruct的默认值，如果给定字典为null，则返回的HighScoreStruct的所有参数皆为默认值
	static func from_dictionary(the_dictionary: Dictionary) -> HighScoreStruct:
		var result: HighScoreStruct = HighScoreStruct.new()
		if (the_dictionary == null):
			return result
		var temp: Variant = the_dictionary.get("score", -1)
		result.score = (temp as int) if ((temp as int) != null) else -1
		temp = the_dictionary.get("reach_level", -1)
		result.reach_level = (temp as int) if ((temp as int) != null) else -1
		temp = the_dictionary.get("speed_per_minute", -1.0)
		result.speed_per_minute = (temp as float) if ((temp as float) != null) else -1.0
		return result

## 效果模式高分对象集结构类，代表一个效果模式的一组高分记录
class EffectHighScoreStruct extends RefCounted:
	var high_score: HighScoreStruct = HighScoreStruct.new()
	var high_level: HighScoreStruct = HighScoreStruct.new()
	var high_speed: HighScoreStruct = HighScoreStruct.new()
	## 转换到字典，深度转换(将使内部所有分数记录都转换为字典)
	func to_dictionary_deep() -> Dictionary[String, Dictionary]:
		var result: Dictionary[String, Dictionary] = {
			"high_score": high_score.to_dictionary(),
			"high_level": high_level.to_dictionary(),
			"high_speed": high_speed.to_dictionary(),
		}
		return result
	## 从字典转换，如果给定的字典缺少值，则对应值为默认构造的HighScoreStruct，深度转换(将使给定字典内部所有分数记录都转换为HighScoreStruct，其中转化细节遵循将使给定字典内部所有分数记录都转换为HighScoreStruct，其中转化细节遵循from_dictionary.from_dictionary方法)
	static func from_dictionary_deep(the_dictionary: Dictionary) -> EffectHighScoreStruct:
		var result: EffectHighScoreStruct = EffectHighScoreStruct.new()
		if (the_dictionary == null):
			return result
		var temp: HighScoreStruct = HighScoreStruct.from_dictionary(the_dictionary.get("high_score", null))
		result.high_score = temp
		temp = HighScoreStruct.from_dictionary(the_dictionary.get("high_level", null))
		result.high_level = temp
		temp = HighScoreStruct.from_dictionary(the_dictionary.get("high_speed", null))
		result.high_speed = temp
		return result
