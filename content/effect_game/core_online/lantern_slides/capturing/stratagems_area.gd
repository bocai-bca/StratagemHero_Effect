extends Control
class_name StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing_StratagemsArea
## 联机效果模式弹幕夺取幻灯片类的战备区域

## 当某个轨道被选中以添加新弹幕时，该轨道的权重将被设为此数
const TRACK_WEIGHT_CHANGED_ON_HIT: float = -0.6

## 父节点的引用
var parent: StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing
## 主计时器，记录当前自开始起已过去多久
var timer: float = 0.0
## 管理中的战备行
var lines: Array[LineInstance] = []
## 轨道权重表
var tracks_weights: PackedFloat32Array = [0.0, 0.0, 0.0, 0.0, 0.0]
## 生成轨道序号用的随机器
var track_random: RandomNumberGenerator = RandomNumberGenerator.new()
## 行完成时间
var line_completion_time: PackedFloat32Array = []

func _ready() -> void:
	track_random.seed = StratagemHeroEffect_EffectGame.online_seed_cache
	line_completion_time.resize(StratagemHeroEffect_EffectGame.ONLINE_SPECIAL_EFFECT_MODE_CAPTURING_STRATAGEMS_COUNT)
	line_completion_time.fill(0.0)

func update(delta: float) -> void:
	var last_tick_time: float = timer
	timer += delta
	for i in parent.stratagems_time_and_life.size():
		var stratagem_time_and_life: StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing.StratagemTimeAndLife = parent.stratagems_time_and_life[i]
		if (last_tick_time <= stratagem_time_and_life.spawn_time and stratagem_time_and_life.spawn_time <= timer):
			var new_line: StratagemHeroEffect_EffectGameCore_StratagemLine = StratagemHeroEffect_EffectGameCore_StratagemLine.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_StratagemLine
			new_line.change_stratagem_data_to(parent.effect_game_main.online_in_game_stratagems_list[i])
			add_line(LineInstance.new(new_line, i, get_best_track()))
	update_line(delta)
	update_tracks_weights(delta)

## 添加战备行实例，将该实例添加到
func add_line(line_instance: LineInstance) -> void:
	lines.append(line_instance)
	add_child(line_instance.line)
	line_instance.line.stratagem_done.connect(on_line_complete.bind([line_instance.index]))

func update_line(delta: float) -> void:
	for i in lines.size():
		var line_instance: LineInstance = lines[lines.size() - i - 1]
		var line: StratagemHeroEffect_EffectGameCore_StratagemLine = line_instance.line
		var time_data: StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing.StratagemTimeAndLife = parent.stratagems_time_and_life[line_instance.index]
		var time_lived: float = timer - time_data.spawn_time
		line.position = Vector2((size.x + line.DEFAULT_ICON_DIAMETER * line.scale.x) * (time_lived / time_data.life_time) - line.total_arrow_width_cache * line.scale.x, get_position_y_for_track(line_instance.track))
		line.update_check_input()
		line.update(delta)

## 获取用于某一轨道的Y坐标
func get_position_y_for_track(track_index: int) -> float:
	return size.y / 2.0 + (track_index - 2) * (StratagemHeroEffect_EffectGameCore_StratagemLine.DEFAULT_ICON_RADIUS + StratagemHeroEffect_EffectGameCore_StratagemLine.DEFAULT_TEXT_BAR_HEIGHT)

## 更新轨道权重，应跟随update调用
func update_tracks_weights(delta: float) -> void:
	for i in tracks_weights.size():
		tracks_weights[i] = move_toward(tracks_weights[i], 1.0, delta)

## 设置持有给定索引号的战备行被持有，方法内部包含了对方和己方是否已夺取的判断，方法内部没有超出数组边界保护，请注意传入参数的可靠性
func set_line_captured(line_index: int) -> void:
	for line_instance in lines:
		if (line_instance.index != line_index):
			continue
		line_instance.line.set_captured(parent.opponent_line_completion_time[line_index] != 0.0, line_completion_time[line_index] != 0.0)

## 获取一个当前状态最好的轨道
func get_best_track() -> int:
	var result: int = track_random.rand_weighted(tracks_weights)
	tracks_weights[result] = TRACK_WEIGHT_CHANGED_ON_HIT
	return result

## 信号方法-行完成时调用
func on_line_complete(line_index: int) -> void:
	if (0 <= line_index and line_index < line_completion_time.size()):
		line_completion_time[line_index] = timer

## 战备实例引用数据
class LineInstance extends RefCounted:
	## 战备行实例
	var line: StratagemHeroEffect_EffectGameCore_StratagemLine
	## 该战备行在父节点的stratagems_time_and_life列表中的对应项的索引号
	var index: int
	## 该战备行所在的轨道
	var track: int
	func _init(new_line: StratagemHeroEffect_EffectGameCore_StratagemLine, new_index: int, new_track: int) -> void:
		line = new_line
		index = new_index
		track = new_track
