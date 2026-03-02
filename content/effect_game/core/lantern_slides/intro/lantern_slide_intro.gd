extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_Intro
## 效果模式开幕幻灯片类

static func CPS() -> PackedScene:
	return preload("res://content/effect_game/core/lantern_slides/intro/lantern_slide_intro.tscn") as PackedScene

const WAIT_TIME: float = 1.25

var n_super_earth_logo: TextureRect
var n_text: RichTextLabel

var wait_timer: float = WAIT_TIME

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_text = $RichTextLabel as RichTextLabel

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_text.size = window_size
	update_logo(n_super_earth_logo, window_size)

func _update_focus(delta: float) -> void:
	wait_timer -= delta
	if (wait_timer <= 0.0):
		drop_focus()

func _drop_focus_postfix() -> void:
	pass

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_title_music.stop()
	StratagemHeroEffect.instance.audio_start.play()

## 设置用于显示的效果模式的特殊模式
func set_effect_mode_displayed(special_mode: StratagemHeroEffect_EffectGame.SpecialEffectMode) -> void:
	var mode_name: String
	match (special_mode):
		StratagemHeroEffect_EffectGame.SpecialEffectMode.NONE:
			mode_name = tr(&"effect_text.lantern_slide.generic.mode_none")
		StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION:
			mode_name = tr(&"effect_text.lantern_slide.generic.mode_dictation")
		StratagemHeroEffect_EffectGame.SpecialEffectMode.GREATWALL:
			mode_name = tr(&"effect_text.lantern_slide.generic.mode_greatwall")
		StratagemHeroEffect_EffectGame.SpecialEffectMode.MULTILINES:
			mode_name = tr(&"effect_text.lantern_slide.generic.mode_multilines")
	n_text.text = tr(&"effect_text.lantern_slide.intro.title") + "\n[color=yellow][b]" + mode_name + "[/b][/color]"
