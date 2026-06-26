extends RefCounted
class_name StratagemHeroEffect_EffectGame_InGameData
## 效果模式-联机游戏内数据。为联机模式的反序列化后的某些游戏内数据

## 数据头，标志数据的类型
enum DataHead{
	STRATAGEM_INDEX, ## 更换战备索引
	ARROW_INDEX, ## 箭头完成索引
	COMPLETE, ## 已完成
}

## 数据头
var head: DataHead
## 数据
var data: String

func _init(new_head: DataHead, new_data: String = "") -> void:
	head = new_head
	data = new_data
