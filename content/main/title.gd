extends Label

## 用于标题时的字体大小
var font_size_title: float = 92.0
## 用于菜单时的字体大小
var font_size_menu: float = 64.0

func _ready() -> void:
	_physics_process(0.0)

func _process(_delta: float) -> void:
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Classic):
		return
	var window: Window = get_window()
	size = Vector2(window.size)
	var title_pos: Vector2 = Vector2(0.0, -window.size.y / 12.5)
	var menu_pos: Vector2 = Vector2(0.0, -window.size.y * 0.45)
	var percent: float = StratagemHeroEffect.transfer_timers[0].percent
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Title):
		position = menu_pos.lerp(title_pos, percent)
		label_settings.font_size = int(lerpf(font_size_menu, font_size_title, percent))
	else:
		position = title_pos.lerp(menu_pos, percent)
		label_settings.font_size = int(lerpf(font_size_title, font_size_menu, percent))

func _physics_process(_delta: float) -> void:
	font_size_title = StratagemHeroEffect.instance.get_font_size(92.0)
	font_size_menu = StratagemHeroEffect.instance.get_font_size(64.0)
