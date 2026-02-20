extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver
## 效果模式游戏结束幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/game_over/lantern_slide_game_over.tscn") as PackedScene

static var label_settings_names: LabelSettings = preload("res://content/effect_game/core/lantern_slides/game_over/label_settings_names.tres") as LabelSettings
static var label_settings_values: LabelSettings = preload("res://content/effect_game/core/lantern_slides/game_over/label_settings_values.tres") as LabelSettings
static var label_settings_continue_tip: LabelSettings = preload("res://content/effect_game/core/lantern_slides/game_over/label_settings_continue_tip.tres") as LabelSettings
static var label_settings_one_heart: LabelSettings = preload("res://content/effect_game/core/lantern_slides/game_over/label_settings_one_heart.tres") as LabelSettings

## 继续计时，用于阻断空格连发
const CONTINUE_TIME: float = 0.15

var n_root_container: MarginContainer
var n_effect_mode_name: Label
var n_score_name: Label
var n_level_reached_name: Label
var n_avg_speed_name: Label
var n_effect_mode_value: Label
var n_effect_mode_oneheart: Label
var n_score_value: Label
var n_level_reached_value: Label
var n_avg_speed_value: Label
var n_continue_tip: Label

## 继续计时器，用于阻断空格连发
var continue_timer: float = CONTINUE_TIME + 1.0

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_root_container = $MC as MarginContainer
		n_effect_mode_name = $MC/VBC/EffectMode/Name as Label
		n_score_name = $MC/VBC/Score/Name as Label
		n_level_reached_name = $MC/VBC/LevelReached/Name as Label
		n_avg_speed_name = $MC/VBC/AvgSpeed/Name as Label
		n_effect_mode_value = $MC/VBC/EffectMode/Value as Label
		n_effect_mode_oneheart = $MC/VBC/EffectMode/OneHeart as Label
		n_score_value = $MC/VBC/Score/Value as Label
		n_level_reached_value = $MC/VBC/LevelReached/Value as Label
		n_avg_speed_value = $MC/VBC/AvgSpeed/Value as Label
		n_continue_tip = $ContinueTip as Label

func _ready() -> void:
	n_continue_tip.text = tr(&"effect_text.lantern_slide.game_over.continue_tip")
	n_effect_mode_name.text = tr(&"effect_text.lantern_slide.game_over.effect_mode")
	n_score_name.text = tr(&"effect_text.lantern_slide.game_over.score")
	n_level_reached_name.text = tr(&"effect_text.lantern_slide.game_over.level_reached")
	n_avg_speed_name.text = tr(&"effect_text.lantern_slide.game_over.avg_speed")

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_root_container.size = size
	n_continue_tip.size = size
	label_settings_names.font_size = int(StratagemHeroEffect.instance.get_fit_size(64.0))
	label_settings_values.font_size = int(StratagemHeroEffect.instance.get_fit_size(96.0))
	label_settings_continue_tip.font_size = int(StratagemHeroEffect.instance.get_fit_size(48.0))
	label_settings_one_heart.font_size = int(StratagemHeroEffect.instance.get_fit_size(64.0))

func _update_focus(delta: float) -> void:
	if (Input.is_action_just_pressed(&"space")):
		continue_timer = CONTINUE_TIME
	if (continue_timer <= 0.0):
		drop_focus()
	elif (continue_timer <= CONTINUE_TIME):
		continue_timer -= delta

func _drop_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_title_music.play()

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_playing_music.stop()

## 设置本幻灯片的文本，需要给定已翻译的模式名称
func update_text(mode_name: String, the_score: int, level_reached: int, avg_speed_for_minute: float) -> void:
	n_effect_mode_value.text = mode_name
	n_score_value.text = str(the_score)
	n_level_reached_value.text = str(level_reached)
	n_avg_speed_value.text = str(snappedf(avg_speed_for_minute, 0.1)) + "/min"
	n_effect_mode_oneheart.visible = StratagemHeroEffect_EffectGame.one_heart
	n_effect_mode_oneheart.text = tr(&"effect_text.lantern_slide.game_over.one_heart_shortname")

## 设置本幻灯片的文本，与update_text()类似但是所有参数都变为字符串
func update_text_str(mode_name: String, the_score: String, level_reached: String, avg_speed: String) -> void:
	n_effect_mode_value.text = mode_name
	n_score_value.text = the_score
	n_level_reached_value.text = level_reached
	n_avg_speed_value.text = avg_speed
	n_effect_mode_oneheart.visible = StratagemHeroEffect_EffectGame.one_heart
	n_effect_mode_oneheart.text = tr(&"effect_text.lantern_slide.game_over.one_heart_shortname")
