extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady
## 效果模式回合准备幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/round_ready/lantern_slide_round_ready.tscn") as PackedScene

## 停留时间
const STAY_TIME: float = 0.8

var label_settings_number: LabelSettings = preload("res://content/effect_game/core/lantern_slides/round_ready/label_settings_number.tres") as LabelSettings
var label_settings_round: LabelSettings = preload("res://content/effect_game/core/lantern_slides/round_ready/label_settings_round.tres") as LabelSettings

var n_super_earth_logo: TextureRect
var n_round: Label
var n_number: Label

## 停留计时器
var stay_timer: float = STAY_TIME

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_round = $Round as Label
		n_number = $Number as Label
		n_round.text = tr(&"effect_text.lantern_slide.round_ready.round")

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	update_logo(n_super_earth_logo, window_size)
	n_round.size = window_size
	n_number.size = window_size
	n_round.position = Vector2(0.0, window_size.y * -0.125)
	n_number.position = Vector2(0.0, window_size.y * 0.125)
	var font_size: int = int(StratagemHeroEffect.instance.get_fit_size(96.0))
	label_settings_round.font_size = font_size
	label_settings_number.font_size = font_size

func _update_focus(delta: float) -> void:
	stay_timer -= delta
	if (stay_timer <= 0.0):
		drop_focus()

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_ready.play()

func _drop_focus_postfix() -> void:
	pass

## 设置回合数
func set_number(round_number: int) -> void:
	n_number.text = str(round_number)

func get_exitable() -> bool:
	return false
