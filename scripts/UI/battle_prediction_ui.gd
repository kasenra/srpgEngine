extends Control

@onready var _att_name = $Grid/Names/Att
@onready var _def_name = $Grid/Names/Def

@onready var _att_dmg = $Grid/Damage/Att
@onready var _def_dmg = $Grid/Damage/Def

@onready var _att_hit = $Grid/Hit/Att
@onready var _def_hit = $Grid/Hit/Def

@onready var _att_crit = $Grid/Crit/Att
@onready var _def_crit = $Grid/Crit/Def

func _ready() -> void:
	UISignal.connect("display_prediction", on_display_prediction)
	UISignal.connect("hide_prediction", on_hide_prediction)
	hide()

func on_display_prediction(b : Battle) -> void:
	if b.att_supporter:
		_att_name.text = "%s (%s)" % [b.attacker.stat.uName, b.att_supporter.stat.uName]
		_att_dmg.text = "%dx%d + %dx%d" % [b.att_dmg.x, b.att_multi.x, b.att_dmg.y, b.att_multi.y]
		_att_hit.text = "%d + %d" % [b.att_hit.x, b.att_hit.y]
		_att_crit.text = "%d + %d" % [b.att_crit.x, b.att_crit.y]
	else:
		_att_name.text = b.attacker.stat.uName
		_att_dmg.text = "%dx%d" % [b.att_dmg.x, b.att_multi.x]
		_att_hit.text = "%d" % b.att_hit.x
		_att_crit.text = "%d" % b.att_crit.x
	if b.def_supporter:
		_def_name.text = "%s (%s)" % [b.attacker.stat.uName, b.def_supporter.stat.uName]
		_def_dmg.text = "%dx%d + %dx%d" % [b.def_dmg.x, b.def_multi.x, b.def_dmg.y, b.def_multi.y]
		_def_hit.text = "%d + %d" % [b.def_hit.x, b.def_hit.y]
		_def_crit.text = "%d + %d" % [b.def_crit.x, b.def_crit.y]
	else:
		_def_name.text = b.defender.stat.uName
		_def_dmg.text = "%dx%d" % [b.def_dmg.x, b.def_multi.x]
		_def_hit.text = "%d" % b.def_hit.x
		_def_crit.text = "%d" % b.def_crit.x
	show()

func on_hide_prediction() -> void:
	hide()
