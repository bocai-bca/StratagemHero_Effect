extends CanvasItem
class_name StratagemHeroEffect
## 主类

static var instance: StratagemHeroEffect

@onready var audio_title_music: AudioStreamPlayer = $Audio_TitleMusic as AudioStreamPlayer
@onready var audio_ready: AudioStreamPlayer = $Audio_Ready as AudioStreamPlayer
@onready var audio_menu_click: AudioStreamPlayer = $Audio_MenuClick as AudioStreamPlayer
@onready var audio_press: AudioStreamPlayer = $Audio_Press as AudioStreamPlayer
@onready var audio_done: AudioStreamPlayer = $Audio_Done as AudioStreamPlayer
@onready var audio_wrong: AudioStreamPlayer = $Audio_Wrong as AudioStreamPlayer
@onready var audio_start: AudioStreamPlayer = $Audio_Start as AudioStreamPlayer
@onready var audio_playing_music: AudioStreamPlayer = $Audio_PlayingMusic as AudioStreamPlayer
@onready var audio_game_over: AudioStreamPlayer = $Audio_GameOver as AudioStreamPlayer
@onready var audio_game_over_large: AudioStreamPlayer = $Audio_GameOverLarge as AudioStreamPlayer
@onready var audio_round_completes: Array[AudioStreamPlayer] = [
	$Audio_RoundComplete_0 as AudioStreamPlayer,
	$Audio_RoundComplete_1 as AudioStreamPlayer,
	$Audio_RoundComplete_2 as AudioStreamPlayer,
	$Audio_RoundComplete_3 as AudioStreamPlayer,
]

@onready var n_super_earth_background: TextureRect = $SuperEarthBackground as TextureRect
@onready var n_title: Label = $Title as Label
@onready var n_title_tip_text: Label = $TitleTipText as Label
@onready var n_title_line_top: ColorRect = $TitleLineTop as ColorRect
@onready var n_title_line_bottom: ColorRect = $TitleLineBottom as ColorRect
@onready var n_main_menu_text: MainMenu_Text = $MainMenu_Text as MainMenu_Text

@onready var classic_game: StratagemHeroEffect_ClassicGame = $ClassicGame as StratagemHeroEffect_ClassicGame

## 游戏状态
enum GameState{
	Init, ## 初始化
	Title, ## 标题界面
	MainMenu, ## 主菜单
	Settings, ## 设置菜单
	Classic, ## 经典游戏
}
## 支持的语言
const LanguagesSupported: PackedStringArray = [
	"en",
	"zh",
]
## 战备数据列表
static var StratagemDataList: Dictionary[StringName, StratagemData] = {
	&"airburst_rocket_launcher":
		StratagemData.new(
			preload("res://resources/images/airburst_rocket_launcher.svg"),
			"stratagem_name.airburst_rocket_launcher",
			"v^^<>"
		),
	&"anti_materiel_rifle":
		StratagemData.new(
			preload("res://resources/images/anti_materiel_rifle.svg"),
			"stratagem_name.anti_materiel_rifle",
			"v<>^v"
		),
	&"anti_personnel_minefield":
		StratagemData.new(
			preload("res://resources/images/anti_personnel_minefield.svg"),
			"stratagem_name.anti_personnel_minefield",
			"v<^>"
		),
	&"anti_tank_emplacement":
		StratagemData.new(
			preload("res://resources/images/anti_tank_emplacement.svg"),
			"stratagem_name.anti_tank_emplacement",
			"v^<>>>"
		),
	&"anti_tank_mines":
		StratagemData.new(
			preload("res://resources/images/anti_tank_mines.svg"),
			"stratagem_name.anti_tank_mines",
			"v<^^"
		),
	&"arc_thrower":
		StratagemData.new(
			preload("res://resources/images/arc_thrower.svg"),
			"stratagem_name.arc_thrower",
			"v>v^<<"
		),
	&"autocannon":
		StratagemData.new(
			preload("res://resources/images/autocannon.svg"),
			"stratagem_name.autocannon",
			"v<v^^>"
		),
	&"autocannon_sentry":
		StratagemData.new(
			preload("res://resources/images/autocannon_sentry.svg"),
			"stratagem_name.autocannon_sentry",
			"v^>^<^"
		),
	&"ballistic_shield_backpack":
		StratagemData.new(
			preload("res://resources/images/ballistic_shield_backpack.svg"),
			"stratagem_name.ballistic_shield_backpack",
			"v<vv^<"
		),
	&"cargo_container":
		StratagemData.new(
			preload("res://resources/images/cargo_container.svg"),
			"stratagem_name.cargo_container",
			"^^vv>v"
		),
	&"commando":
		StratagemData.new(
			preload("res://resources/images/commando.svg"),
			"stratagem_name.commando",
			"v<^v>"
		),
	&"dark_fluid_vessel":
		StratagemData.new(
			preload("res://resources/images/dark_fluid_vessel.svg"),
			"stratagem_name.dark_fluid_vessel",
			"^<>v^^"
		),
	&"defoliation_tool":
		StratagemData.new(
			preload("res://resources/images/defoliation_tool.svg"),
			"stratagem_name.defoliation_tool",
			"v<>>v"
		),
	&"directional_shield":
		StratagemData.new(
			preload("res://resources/images/directional_shield.svg"),
			"stratagem_name.directional_shield",
			"v^<>^^"
		),
	&"eagle_110mm_rocket_pods":
		StratagemData.new(
			preload("res://resources/images/eagle_110mm_rocket_pods.svg"),
			"stratagem_name.eagle_110mm_rocket_pods",
			"^>^<"
		),
	&"eagle_500kg_bomb":
		StratagemData.new(
			preload("res://resources/images/eagle_500kg_bomb.svg"),
			"stratagem_name.eagle_500kg_bomb",
			"^>vvv"
		),
	&"eagle_airstrike":
		StratagemData.new(
			preload("res://resources/images/eagle_airstrike.svg"),
			"stratagem_name.eagle_airstrike",
			"^>v>"
		),
	&"eagle_cluster_bomb":
		StratagemData.new(
			preload("res://resources/images/eagle_cluster_bomb.svg"),
			"stratagem_name.eagle_cluster_bomb",
			"^>vv>"
		),
	&"eagle_napalm_airstrike":
		StratagemData.new(
			preload("res://resources/images/eagle_napalm_airstrike.svg"),
			"stratagem_name.eagle_napalm_airstrike",
			"^>V^"
		),
	&"eagle_rearm":
		StratagemData.new(
			preload("res://resources/images/eagle_rearm.svg"),
			"stratagem_name.eagle_rearm",
			"^^<^>"
		),
	&"eagle_smoke_strike":
		StratagemData.new(
			preload("res://resources/images/eagle_smoke_strike.svg"),
			"stratagem_name.eagle_smoke_strike",
			"^>^v"
		),
	&"eagle_strafing_run":
		StratagemData.new(
			preload("res://resources/images/eagle_strafing_run.svg"),
			"stratagem_name.eagle_strafing_run",
			"^>>"
		),
	&"emancipator_exosuit":
		StratagemData.new(
			preload("res://resources/images/emancipator_exosuit.svg"),
			"stratagem_name.emancipator_exosuit",
			"<v>^<v^"
		),
	&"ems_mortar_sentry":
		StratagemData.new(
			preload("res://resources/images/ems_mortar_sentry.svg"),
			"stratagem_name.ems_mortar_sentry",
			"v^>v>"
		),
	&"epoch":
		StratagemData.new(
			preload("res://resources/images/epoch.svg"),
			"stratagem_name.epoch",
			"v<^<>"
		),
	&"expendable_anti_tank":
		StratagemData.new(
			preload("res://resources/images/expendable_anti_tank.svg"),
			"stratagem_name.expendable_anti_tank",
			"vv<^>"
		),
	&"expendable_napalm":
		StratagemData.new(
			preload("res://resources/images/expendable_napalm.svg"),
			"stratagem_name.expendable_napalm",
			"vv<^<"
		),
	&"fast_recon_vehicle":
		StratagemData.new(
			preload("res://resources/images/fast_recon_vehicle.svg"),
			"stratagem_name.fast_recon_vehicle",
			"<v>v>v^"
		),
	&"flame_sentry":
		StratagemData.new(
			preload("res://resources/images/flame_sentry.svg"),
			"stratagem_name.flame_sentry",
			"v^>v^^"
		),
	&"flamethrower":
		StratagemData.new(
			preload("res://resources/images/flamethrower.svg"),
			"stratagem_name.flamethrower",
			"v<^v^"
		),
	&"gas_mine":
		StratagemData.new(
			preload("res://resources/images/gas_mine.svg"),
			"stratagem_name.gas_mine",
			"v<<>"
		),
	&"gatling_sentry":
		StratagemData.new(
			preload("res://resources/images/gatling_sentry.svg"),
			"stratagem_name.gatling_sentry",
			"v^><"
		),
	&"gl_52_de_escalator":
		StratagemData.new(
			preload("res://resources/images/gl_52_de_escalator.svg"),
			"stratagem_name.gl_52_de_escalator",
			"v>^<>"
		),
	&"grenade_launcher":
		StratagemData.new(
			preload("res://resources/images/grenade_launcher.svg"),
			"stratagem_name.grenade_launcher",
			"v<^<v"
		),
	&"grenadier_battlement":
		StratagemData.new(
			preload("res://resources/images/grenadier_battlement.svg"),
			"stratagem_name.grenadier_battlement",
			"v>v<>"
		),
	&"guard_dog":
		StratagemData.new(
			preload("res://resources/images/guard_dog.svg"),
			"stratagem_name.guard_dog",
			"v^<^>v"
		),
	&"guard_dog_breath":
		StratagemData.new(
			preload("res://resources/images/guard_dog_breath.svg"),
			"stratagem_name.guard_dog_breath",
			"v^<^>^"
		),
	&"guard_dog_hot_dog":
		StratagemData.new(
			preload("res://resources/images/guard_dog_hot_dog.svg"),
			"stratagem_name.guard_dog_hot_dog",
			"v^<^<<"
		),
	&"guard_dog_k_9":
		StratagemData.new(
			preload("res://resources/images/guard_dog_k_9.svg"),
			"stratagem_name.guard_dog_k_9",
			"v^<^><"
		),
	&"guard_dog_rover":
		StratagemData.new(
			preload("res://resources/images/guard_dog_rover.svg"),
			"stratagem_name.guard_dog_rover",
			"v^<^>>"
		),
	&"heavy_machine_gun":
		StratagemData.new(
			preload("res://resources/images/heavy_machine_gun.svg"),
			"stratagem_name.heavy_machine_gun",
			"v<^vv"
		),
	&"hellbomb":
		StratagemData.new(
			preload("res://resources/images/hellbomb.svg"),
			"stratagem_name.hellbomb",
			"v^<v^>v^"
		),
	&"hellbomb_portable":
		StratagemData.new(
			preload("res://resources/images/hellbomb_portable.svg"),
			"stratagem_name.hellbomb_portable",
			"v>^^^"
		),
	&"hive_breaker_drill":
		StratagemData.new(
			preload("res://resources/images/hive_breaker_drill.svg"),
			"stratagem_name.hive_breaker_drill",
			"<^v>vv"
		),
	&"hmg_emplacement":
		StratagemData.new(
			preload("res://resources/images/hmg_emplacement.svg"),
			"stratagem_name.hmg_emplacement",
			"v^<>><"
		),
	&"hover_pack":
		StratagemData.new(
			preload("res://resources/images/hover_pack.svg"),
			"stratagem_name.hover_pack",
			"v^^v<>"
		),
	&"incendiary_mines":
		StratagemData.new(
			preload("res://resources/images/incendiary_mines.svg"),
			"stratagem_name.incendiary_mines",
			"v<<v"
		),
	&"jump_pack":
		StratagemData.new(
			preload("res://resources/images/jump_pack.svg"),
			"stratagem_name.jump_pack",
			"v^^v^"
		),
	&"laser_cannon":
		StratagemData.new(
			preload("res://resources/images/laser_cannon.svg"),
			"stratagem_name.laser_cannon",
			"v<v^<"
		),
	&"laser_sentry":
		StratagemData.new(
			preload("res://resources/images/laser_sentry.svg"),
			"stratagem_name.laser_sentry",
			"v^>v^>"
		),
	&"machine_gun":
		StratagemData.new(
			preload("res://resources/images/machine_gun.svg"),
			"stratagem_name.machine_gun",
			"v<v^>"
		),
	&"machine_gun_sentry":
		StratagemData.new(
			preload("res://resources/images/machine_gun_sentry.svg"),
			"stratagem_name.machine_gun_sentry",
			"v^>>^"
		),
	&"maxigun":
		StratagemData.new(
			preload("res://resources/images/maxigun.svg"),
			"stratagem_name.maxigun",
			"v<>v^^"
		),
	&"mortar_sentry":
		StratagemData.new(
			preload("res://resources/images/mortar_sentry.svg"),
			"stratagem_name.mortar_sentry",
			"v^>>v"
		),
	&"one_true_flag":
		StratagemData.new(
			preload("res://resources/images/one_true_flag.svg"),
			"stratagem_name.one_true_flag",
			"v<>>^"
		),
	&"orbital_120mm_he_barrage":
		StratagemData.new(
			preload("res://resources/images/orbital_120mm_he_barrage.svg"),
			"stratagem_name.orbital_120mm_he_barrage",
			">>v<>v"
		),
	&"orbital_380mm_he_barrage":
		StratagemData.new(
			preload("res://resources/images/orbital_380mm_he_barrage.svg"),
			"stratagem_name.orbital_380mm_he_barrage",
			">v^^<vv"
		),
	&"orbital_airburst_strike":
		StratagemData.new(
			preload("res://resources/images/orbital_airburst_strike.svg"),
			"stratagem_name.orbital_airburst_strike",
			">>>"
		),
	&"orbital_ems_strike":
		StratagemData.new(
			preload("res://resources/images/orbital_ems_strike.svg"),
			"stratagem_name.orbital_ems_strike",
			">><v"
		),
	&"orbital_gas_strike":
		StratagemData.new(
			preload("res://resources/images/orbital_gas_strike.svg"),
			"stratagem_name.orbital_gas_strike",
			">>v>"
		),
	&"orbital_gatling_barrage":
		StratagemData.new(
			preload("res://resources/images/orbital_gatling_barrage.svg"),
			"stratagem_name.orbital_gatling_barrage",
			">v<^^"
		),
	&"orbital_laser":
		StratagemData.new(
			preload("res://resources/images/orbital_laser.svg"),
			"stratagem_name.orbital_laser",
			">v^>v"
		),
	&"orbital_napalm_barrage":
		StratagemData.new(
			preload("res://resources/images/orbital_napalm_barrage.svg"),
			"stratagem_name.orbital_napalm_barrage",
			">>v<>^"
		),
	&"orbital_precision_strike":
		StratagemData.new(
			preload("res://resources/images/orbital_precision_strike.svg"),
			"stratagem_name.orbital_precision_strike",
			">>^"
		),
	&"orbital_railcannon_strike":
		StratagemData.new(
			preload("res://resources/images/orbital_railcannon_strike.svg"),
			"stratagem_name.orbital_railcannon_strike",
			">^vv>"
		),
	&"orbital_smoke_strike":
		StratagemData.new(
			preload("res://resources/images/orbital_smoke_strike.svg"),
			"stratagem_name.orbital_smoke_strike",
			">>v^"
		),
	&"orbital_walking_barrage":
		StratagemData.new(
			preload("res://resources/images/orbital_walking_barrage.svg"),
			"stratagem_name.orbital_walking_barrage",
			">v>v>v"
		),
	&"patriot_exosuit":
		StratagemData.new(
			preload("res://resources/images/patriot_exosuit.svg"),
			"stratagem_name.patriot_exosuit",
			"<v>^<vv"
		),
	&"prospecting_drill":
		StratagemData.new(
			preload("res://resources/images/prospecting_drill.svg"),
			"stratagem_name.prospecting_drill",
			"vv<>vv"
		),
	&"quasar_cannon":
		StratagemData.new(
			preload("res://resources/images/quasar_cannon.svg"),
			"stratagem_name.quasar_cannon",
			"vv^<>"
		),
	&"railgun":
		StratagemData.new(
			preload("res://resources/images/railgun.svg"),
			"stratagem_name.railgun",
			"v>v^<>"
		),
	&"recoilless_rifle":
		StratagemData.new(
			preload("res://resources/images/recoilless_rifle.svg"),
			"stratagem_name.recoilless_rifle",
			"v<>><"
		),
	&"reinforce":
		StratagemData.new(
			preload("res://resources/images/reinforce.svg"),
			"stratagem_name.reinforce",
			"^v><^"
		),
	&"resupply":
		StratagemData.new(
			preload("res://resources/images/resupply.svg"),
			"stratagem_name.resupply",
			"vv^>"
		),
	&"rocket_sentry":
		StratagemData.new(
			preload("res://resources/images/rocket_sentry.svg"),
			"stratagem_name.rocket_sentry",
			"v^>><"
		),
	&"seaf_artillery":
		StratagemData.new(
			preload("res://resources/images/seaf_artillery.svg"),
			"stratagem_name.seaf_artillery",
			">^^v"
		),
	&"seismic_probe":
		StratagemData.new(
			preload("res://resources/images/seismic_probe.svg"),
			"stratagem_name.seismic_probe",
			"^^<>vv"
		),
	&"shield_generator_pack":
		StratagemData.new(
			preload("res://resources/images/shield_generator_pack.svg"),
			"stratagem_name.shield_generator_pack",
			"v^<><>"
		),
	&"shield_generator_relay":
		StratagemData.new(
			preload("res://resources/images/shield_generator_relay.svg"),
			"stratagem_name.shield_generator_relay",
			"vv<><>"
		),
	&"solo_silo":
		StratagemData.new(
			preload("res://resources/images/solo_silo.svg"),
			"stratagem_name.solo_silo",
			"v^>vv"
		),
	&"sos_beacon":
		StratagemData.new(
			preload("res://resources/images/sos_beacon.svg"),
			"stratagem_name.sos_beacon",
			"^v>^"
		),
	&"spear":
		StratagemData.new(
			preload("res://resources/images/spear.svg"),
			"stratagem_name.spear",
			"vv^vv"
		),
	&"speargun":
		StratagemData.new(
			preload("res://resources/images/speargun.svg"),
			"stratagem_name.speargun",
			"v>v<^>"
		),
	&"sta_x3_wasp_launcher":
		StratagemData.new(
			preload("res://resources/images/sta_x3_w.a.s.p._launcher.svg"),
			"stratagem_name.sta_x3_wasp_launcher",
			"vv^v>"
		),
	&"stalwart":
		StratagemData.new(
			preload("res://resources/images/stalwart.svg"),
			"stratagem_name.stalwart",
			"v<v^^<"
		),
	&"sterilizer":
		StratagemData.new(
			preload("res://resources/images/sterilizer.svg"),
			"stratagem_name.sterilizer",
			"v<^v<"
		),
	&"super_earth_flag":
		StratagemData.new(
			preload("res://resources/images/super_earth_flag.svg"),
			"stratagem_name.super_earth_flag",
			"v^v^"
		),
	&"supply_pack":
		StratagemData.new(
			preload("res://resources/images/supply_pack.svg"),
			"stratagem_name.supply_pack",
			"v<v^^v"
		),
	&"tectonic_drill":
		StratagemData.new(
			preload("res://resources/images/tectonic_drill.svg"),
			"stratagem_name.tectonic_drill",
			"^v^v^v"
		),
	&"tesla_tower":
		StratagemData.new(
			preload("res://resources/images/tesla_tower.svg"),
			"stratagem_name.tesla_tower",
			"v^>^<>"
		),
	&"upload_data":
		StratagemData.new(
			preload("res://resources/images/upload_data.svg"),
			"stratagem_name.upload_data",
			"<>^^^"
		),
	&"warp_pack":
		StratagemData.new(
			preload("res://resources/images/warp_pack.svg"),
			"stratagem_name.warp_pack",
			"v<>v<>"
		),
}

static var config_file: ConfigFile = ConfigFile.new()
var game_state: GameState = GameState.Init:
	get:
		return game_state
	set(value):
		var from_game_state: GameState = game_state
		game_state = value
		match (value):
			GameState.Title:
				if (from_game_state == GameState.Init):
					audio_title_music.play()
			GameState.MainMenu:
				if (from_game_state == GameState.Title):
					audio_ready.play()
					menu_option_focus = 0
					transfer_timers[0].current = 0.0
					n_main_menu_text.update_text()
				if (from_game_state == GameState.Settings):
					audio_menu_click.play()
					menu_option_focus = 2
					n_main_menu_text.update_text()
				if (from_game_state == GameState.Classic):
					n_title.visible = true
					n_title_tip_text.visible = true
					n_title_line_top.visible = true
					n_title_line_bottom.visible = true
					n_main_menu_text.visible = true
					audio_title_music.play()
			GameState.Settings:
				audio_menu_click.play()
				menu_option_focus = 0
				n_main_menu_text.update_text()
			GameState.Classic:
				audio_title_music.stop()
				n_title.visible = false
				n_title_tip_text.visible = false
				n_title_line_top.visible = false
				n_title_line_bottom.visible = false
				n_main_menu_text.visible = false

## 菜单焦点
static var menu_option_focus: int
## 全局变换计数器列表
##  0 = 游戏状态变换计数器，用于：在标题按下空格后变换到主菜单的过程计时
static var transfer_timers: Array[TransferTimer] = [
	TransferTimer.new(0.2, true, 0.2),
]

func _init() -> void:
	instance = self

func _enter_tree() -> void:
	get_window().min_size = Vector2i(640, 360)

func _ready() -> void:
	classic_game.game_end.connect(on_game_end)
	game_state = GameState.Title

func _unhandled_input(event: InputEvent) -> void:
	match (game_state):
		GameState.Title:
			if (event.is_action_released(&"space")):
				game_state = GameState.MainMenu
		GameState.MainMenu:
			if (event.is_action_released(&"up")):
				menu_option_focus -= 1
				if (menu_option_focus < 0):
					menu_option_focus = 4
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"down")):
				menu_option_focus += 1
				if (menu_option_focus > 4):
					menu_option_focus = 0
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"space")):
				menu_click()
		GameState.Settings:
			if (event.is_action_released(&"up")):
				menu_option_focus -= 1
				if (menu_option_focus < 0):
					menu_option_focus = 1
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"down")):
				menu_option_focus += 1
				if (menu_option_focus > 1):
					menu_option_focus = 0
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"space")):
				menu_click()

## 代表按下当前菜单的键，旨在实现高度封装
func menu_click() -> void:
	match (game_state):
		GameState.MainMenu:
			match (menu_option_focus):
				0: #经典
					game_state = GameState.Classic
					classic_game.start_game()
				2: #设置
					game_state = GameState.Settings
		GameState.Settings:
			match (menu_option_focus):
				0: #返回
					game_state = GameState.MainMenu
				1: #更改语言
					change_language()
					n_main_menu_text.update_text()
					audio_press.play()

func _process(delta: float) -> void:
	for transfer_timer in transfer_timers:
		transfer_timer.update(delta)

## 获取当前分辨率下合适的字体大小，需要给定在1280*720尺寸下的原始大小，不建议高频调用本方法
func get_font_size(original_size: float) -> float:
	var window: Window = get_window()
	return (original_size / 720.0) * window.size.y
	#var new_size_by_x: float = (original_size / 1280.0) * window.size.x
	#var new_size_by_y: float = (original_size / 720.0) * window.size.y
	#return minf(new_size_by_x, new_size_by_y)

## 切换语言
static func change_language() -> void:
	var current_language_index: int = LanguagesSupported.find(TranslationServer.get_locale())
	current_language_index += 1
	if (current_language_index >= LanguagesSupported.size()):
		current_language_index = 0
	TranslationServer.set_locale(LanguagesSupported[current_language_index])

## 信号方法-游戏结束，用于使画面回到主类接管
func on_game_end() -> void:
	game_state = GameState.MainMenu
