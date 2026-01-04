extends PanelContainer
class_name StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton

const CPS: PackedScene = preload("res://content/effect_game/stratagem_selection_icon.tscn") as PackedScene

## 一般情况下使用的边框
static var icon_frame_stylebox_normal: StyleBoxFlat = preload("res://content/effect_game/stratagem_selection_icon_frame_normal.tres")
## 处于焦点时使用的边框
static var icon_frame_stylebox_focus: StyleBoxFlat = preload("res://content/effect_game/stratagem_selection_icon_frame_focus.tres")

@onready var n_texture_button: TextureButton = $TextureButton as TextureButton

## 记录本按钮表示的战备，用于方便其他使用者类进行访问，值应对应StratagemData.list的键
var stratagem_name: StringName

## 设置当前按钮的焦点状态
func set_on_focus(is_on_focus: bool) -> void:
	add_theme_stylebox_override(&"panel", icon_frame_stylebox_focus if is_on_focus else icon_frame_stylebox_normal)

func _ready() -> void:
	_physics_process(0.0)
	update_lightness()

func _process(_delta: float) -> void:
	if (n_texture_button.has_focus()):
		var rgb: float = sin(Time.get_ticks_msec() / 250.0) + 0.5
		self_modulate = Color(1.0, 1.0, rgb)

func _physics_process(_delta: float) -> void:
	custom_minimum_size = Vector2.ONE * StratagemHeroEffect.instance.get_fit_size(66.0)
	size = custom_minimum_size

## 创建一个本类的实例，本方法返回值可直接送进add_child()添加进场景树
static func create(new_name: StringName, icon_texture: Texture2D) -> StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton:
	var new_instance: StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton = CPS.instantiate() as StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton
	new_instance.stratagem_name = new_name
	(new_instance.get_node(^"TextureButton") as TextureButton).texture_normal = icon_texture
	return new_instance

func on_focus_entered() -> void:
	add_theme_stylebox_override(&"panel", icon_frame_stylebox_focus)
	StratagemHeroEffect.instance.audio_press.play()

func on_focus_exited() -> void:
	add_theme_stylebox_override(&"panel", icon_frame_stylebox_normal)
	self_modulate = Color.WHITE

func on_button_pressed() -> void:
	StratagemHeroEffect.instance.audio_menu_click.play()
	var find_index: int = StratagemHeroEffect_EffectGame_StratagemSelectionPanel.stratagems_enabled.find(stratagem_name)
	if (find_index == -1): # 没找到，说明本次按下意味着启用战备
		StratagemHeroEffect_EffectGame_StratagemSelectionPanel.stratagems_enabled.append(stratagem_name)
		n_texture_button.set_instance_shader_parameter(&"enable_gray", false)
	else:
		StratagemHeroEffect_EffectGame_StratagemSelectionPanel.stratagems_enabled.remove_at(find_index)
		n_texture_button.set_instance_shader_parameter(&"enable_gray", true)

func update_lightness() -> void:
	if (StratagemHeroEffect_EffectGame_StratagemSelectionPanel.stratagems_enabled.has(stratagem_name)):
		n_texture_button.set_instance_shader_parameter(&"enable_gray", false)
	else:
		n_texture_button.set_instance_shader_parameter(&"enable_gray", true)
