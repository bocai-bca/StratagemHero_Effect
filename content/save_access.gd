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

	return true

class SaveStruct extends RefCounted:
	var volume_music: float = 0.8
	var volume_sfx: float = 0.8
