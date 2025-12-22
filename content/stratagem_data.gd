extends RefCounted
class_name StratagemData
## 战备数据类

## 指令箭头方向的易读对应枚举
enum CodeArrow{
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

## 战备的图标
var icon: Texture2D
## 战备的翻译键名
var name_key: String
## 战备指令列表
var codes: Array[CodeArrow]

## 以字符串的形式设定指令，可接受这四种字符：< ^ > v
func set_codes_by_string(string: String) -> void:
	codes = []
	for current_char in string:
		match (current_char):
			"<":
				codes.append(CodeArrow.LEFT)
			"^":
				codes.append(CodeArrow.UP)
			">":
				codes.append(CodeArrow.RIGHT)
			"v":
				codes.append(CodeArrow.DOWN)
