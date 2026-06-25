extends RefCounted
class_name StratagemHeroEffect_EffectGame_OnlineCode
## 效果模式-联机指令。为联机模式的通信数据

## 指令枚举
enum Code{
	UNDEFINED = 0, ## 未定义，不被使用的特殊指令
	START_GAME = 1, ## 开始游戏，只由主机发出，操作符存放要开始的特殊效果模式名称
	ASK_QUESTION = 2, ## 向对方请求数据，操作符存放提问的问题
	ANSWER_QUESTION = 3, ## 向对方提交问题返回的数据，操作符存放回答的数据
	FAILED_TO_START_GAME, ## 开始游戏时失败，告知对方请重置游戏状态
	VERSION_VARIFIED, ## 已验证版本，客机告知主机已确认版本符合
	VERSION_NOT_MATCH, ## 版本不符合，客机告知主机版本不符合、需要断开
}

## 指令段
var code: Code
## 操作符
var oprt: String

func _init(new_code: Code = Code.UNDEFINED, new_oprt: String = "") -> void:
	code = new_code
	oprt = new_oprt
