extends RefCounted
class_name StratagemHeroEffect_EffectGame_InGameData
## 效果模式-联机游戏内数据。为联机模式的反序列化后的某些游戏内数据

## 数据头，标志数据的类型
enum DataHead{
	STRATAGEM_INDEX, ## 更换战备索引，在弹幕夺取模式中表示对方夺取的战备
	ARROW_INDEX, ## 箭头完成索引
	COMPLETE, ## 已完成
	WRONG, ## 错误
	COMPLETE_TIME, ## 完成时间，在弹幕夺取模式中表示发送方的详细完成情况
	SCORES, ## 游戏分数数据，只在弹幕夺取模式中有效，由主机结算完毕后发给客机
	GAME_OVER, ## 移动至游戏结束幻灯片
	GAME_OVER_CONFIRM, ## 是否准备好游戏结束的询问和响应，主机向客机发送代表询问客机是否准备好(一般不会这么做)，客机向主机回应代表已确认
	CLOSE, ## 结束效果模式核心
}

## 操作符头-战备索引
const HEAD_STRATAGEM_INDEX: String = "si"
## 操作符头-箭头索引
const HEAD_ARROW_INDEX: String = "ai"
## 操作符头-已完成
const HEAD_COMPLETE: String = "cp"
## 操作符头-错误
const HEAD_WRONG: String = "wr"
## 操作符头-完成时间
const HEAD_COMPLETE_TIME: String = "ct"
## 操作符头-游戏分数数据
const HEAD_SCORES: String = "sc"
## 操作符头-移动至游戏结束幻灯片
const HEAD_GAME_OVER: String = "go"
## 操作符头-是否准备好游戏结束的询问和响应
const HEAD_GAME_OVER_CONFIRM: String = "gc"
## 操作符头-结束核心
const HEAD_CLOSE: String = "cl"

## 数据头
var head: DataHead
## 数据
var data: String

func _init(new_head: DataHead, new_data: String = "") -> void:
	head = new_head
	data = new_data

## 从联机指令的操作码解析
static func from_online_code(operation: String) -> StratagemHeroEffect_EffectGame_InGameData:
	var splitted: PackedStringArray = operation.split(",", true, 1)
	if (splitted.size() < 2):
		push_error("Got data from question answered but error on splitting.")
		return null
	match (splitted[0]):
		HEAD_STRATAGEM_INDEX:
			return StratagemHeroEffect_EffectGame_InGameData.new(
				StratagemHeroEffect_EffectGame_InGameData.DataHead.STRATAGEM_INDEX,
				splitted[1]
			)
		HEAD_ARROW_INDEX:
			return StratagemHeroEffect_EffectGame_InGameData.new(
				StratagemHeroEffect_EffectGame_InGameData.DataHead.ARROW_INDEX,
				splitted[1] # 这里是箭头序号
			)
		HEAD_COMPLETE:
			print("Received IngameData: COMPLETE")
			return StratagemHeroEffect_EffectGame_InGameData.new(
				StratagemHeroEffect_EffectGame_InGameData.DataHead.COMPLETE
			)
		HEAD_WRONG:
			return StratagemHeroEffect_EffectGame_InGameData.new(
				StratagemHeroEffect_EffectGame_InGameData.DataHead.WRONG,
				splitted[1] # 这里是当前的战备索引号，用来加强同步战备进度
			)
		HEAD_COMPLETE_TIME:
			print("Received IngameData: COMPLETE_TIME")
			return StratagemHeroEffect_EffectGame_InGameData.new(
				StratagemHeroEffect_EffectGame_InGameData.DataHead.COMPLETE_TIME,
				splitted[1] # 这里是对方完成时间
			)
		HEAD_GAME_OVER:
			print("Received IngameData: GAME_OVER")
			return StratagemHeroEffect_EffectGame_InGameData.new(
				StratagemHeroEffect_EffectGame_InGameData.DataHead.GAME_OVER
			)
		HEAD_GAME_OVER_CONFIRM:
			print("Received IngameData: GAME_OVER_CONFIRM")
			return StratagemHeroEffect_EffectGame_InGameData.new(
				StratagemHeroEffect_EffectGame_InGameData.DataHead.GAME_OVER_CONFIRM
			)
		HEAD_CLOSE:
			print("Received IngameData: CLOSE")
			return StratagemHeroEffect_EffectGame_InGameData.new(
				StratagemHeroEffect_EffectGame_InGameData.DataHead.CLOSE
			)
		HEAD_SCORES:
			print("Received IngameData: SCORES")
			return StratagemHeroEffect_EffectGame_InGameData.new(
				StratagemHeroEffect_EffectGame_InGameData.DataHead.SCORES,
				splitted[1] # 这里是分数数据
			)
		_:
			push_warning("Dirty data! Unknown ingame data operation head.")
			return null
