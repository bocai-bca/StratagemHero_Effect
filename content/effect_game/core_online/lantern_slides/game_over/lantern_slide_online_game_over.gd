extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlideOnline_GameOver
## 联机效果模式游戏结束幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core_online/lantern_slides/game_over/lantern_slide_online_game_over.tscn") as PackedScene

var n_super_earth_logo: TextureRect
var n_container: MarginContainer
var n_win_lose_text: Label
var n_detail_text: RichTextLabel

## 继续计时，用于阻断空格连发
const CONTINUE_TIME: float = 0.15
## 胜负文本默认字体大小
const WIN_LOSE_TEXT_FONT_SIZE_DEFAULT: float = 96.0
## 胜利颜色
const WIN_COLOR: Color = Color(1.0, 1.0, 0.0)
## 失败颜色
const LOSE_COLOR: Color = Color(0.7, 0.7, 0.7)
## 平局颜色
const TIE_COLOR: Color = Color(1.0, 1.0, 1.0)
## 详细文本字体大小默认值
const DETAIL_TEXT_FONT_SIZE_DEFAULT: float = 48.0

## 继续计时器，用于阻断空格连发
var continue_timer: float = CONTINUE_TIME + 1.0
## 本地完成时间缓存
var local_time_cache: int

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_win_lose_text = $MC/HBC/WinLostText as Label
		n_container = $MC as MarginContainer
		n_detail_text = $MC/HBC/DetailText as RichTextLabel

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_container.size = window_size
	n_win_lose_text.add_theme_font_size_override(&"font_size", int(StratagemHeroEffect.instance.get_fit_size(WIN_LOSE_TEXT_FONT_SIZE_DEFAULT)))
	n_detail_text.add_theme_font_size_override(&"normal_font_size", int(StratagemHeroEffect.instance.get_fit_size(DETAIL_TEXT_FONT_SIZE_DEFAULT)))

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(delta: float) -> void:
	if (StratagemHeroEffect_EffectGame.instance.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
		if (Input.is_action_just_pressed(&"space")):
			continue_timer = CONTINUE_TIME
		if (continue_timer <= 0.0):
			StratagemHeroEffect_EffectGame.instance.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_CLOSE + ","), MultiplayerPeer.TransferMode.TRANSFER_MODE_RELIABLE)
			drop_focus()
		elif (continue_timer <= CONTINUE_TIME):
			continue_timer -= delta
	ingame_data_handle_loop()

func ingame_data_handle_loop() -> void:
	var reback_list: Array[StratagemHeroEffect_EffectGame_InGameData] = []
	while (not StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.is_empty()):
		var ingame_data: StratagemHeroEffect_EffectGame_InGameData = StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.pop_front() as StratagemHeroEffect_EffectGame_InGameData
		match (ingame_data.head):
			StratagemHeroEffect_EffectGame_InGameData.DataHead.CLOSE:
				drop_focus()
			StratagemHeroEffect_EffectGame_InGameData.DataHead.COMPLETE_TIME: # 完成时间数据，应该只有默写竞速和标准竞速会发，所以直接写竞速的逻辑了
				set_detail_racing(local_time_cache, ingame_data.data.to_int())
			_:
				reback_list.append(ingame_data) #不是本幻灯片该处理的，塞回去
	StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.append_array(reback_list)

## 设置详细信息-竞速模式
func set_detail_racing(local_time: int, opponent_time: int) -> void:
	print("GameOver detail racing set, local:", local_time, " opponent:", opponent_time)
	local_time_cache = local_time
	var temp_str: String
	temp_str = str(local_time % 60)
	if (temp_str.length() <= 1):
		temp_str = "0" + temp_str
	@warning_ignore("integer_division") var local_time_str: String = str(local_time / 60) + ":" + temp_str
	temp_str = str(opponent_time % 60)
	if (temp_str.length() <= 1):
		temp_str = "0" + temp_str
	@warning_ignore("integer_division") var opponent_time_str: String = str(opponent_time / 60) + ":" + temp_str
	if (local_time < opponent_time): # 胜利
		n_win_lose_text.text = tr(&"effect_online_text.lantern_slide.game_over.win")
		n_win_lose_text.modulate = WIN_COLOR
		n_detail_text.text = "[color=yellow]" + tr(&"effect_online_text.lantern_slide.game_over.your_time_used") + "[/color]   " + tr(&"effect_online_text.lantern_slide.game_over.opponent_time_used") + "\n[color=yellow]" + local_time_str + "[/color]   " + opponent_time_str
	elif (local_time > opponent_time): # 失败
		n_win_lose_text.text = tr(&"effect_online_text.lantern_slide.game_over.lose")
		n_win_lose_text.modulate = LOSE_COLOR
		n_detail_text.text = tr(&"effect_online_text.lantern_slide.game_over.your_time_used") + "   [color=yellow]" + tr(&"effect_online_text.lantern_slide.game_over.opponent_time_used") + "[/color]\n" + local_time_str + "   [color=yellow]" + opponent_time_str + "[/color]"
	else: # 平局
		n_win_lose_text.text = tr(&"effect_online_text.lantern_slide.game_over.tie")
		n_win_lose_text.modulate = TIE_COLOR
		n_detail_text.text = tr(&"effect_online_text.lantern_slide.game_over.your_time_used") + "   " + tr(&"effect_online_text.lantern_slide.game_over.opponent_time_used") + "\n" + local_time_str + "   " + opponent_time_str

## 设置详细信息-弹幕夺取
func set_detail_capturing(local_score: int, opponent_score: int) -> void:
	print("GameOver detail capturing set, local:", local_score, " opponent:", opponent_score)
	#TODO

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_title_music.play()

func get_exitable() -> bool:
	return false

func _on_esc_exit() -> void:
	StratagemHeroEffect_EffectGame.instance.soft_disconnect()
