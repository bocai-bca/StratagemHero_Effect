extends Label

## 用于标题时的字体大小
var font_size_title: float = 48.0

func _ready() -> void:
	_physics_process(0.0)

func _process(_delta: float) -> void:
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Classic):
		return
	var window: Window = get_window()
	size = Vector2(window.size)
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Title):
		position = Vector2(0.0, size.y / 8.0)
		label_settings.font_color.a = sin(Time.get_ticks_msec() / 150.0) / 3.0 + 0.667
		label_settings.font_size = int(font_size_title)
	else:
		label_settings.font_color.a = 0.0

func _physics_process(_delta: float) -> void:
	font_size_title = StratagemHeroEffect.instance.get_font_size(48.0)
