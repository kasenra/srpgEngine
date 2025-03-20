class_name Battle ## Battle logic is stored here. UI Collects Units, their Terrains, and their Supporters 
extends Node

enum STANCE {ATTACKER, DEFENDER}

@export_category("Battle Scenario")
@export var range : int

@export_category("Attacker")
@export var attacker: Unit
@export var att_terrain: Codex.TERRAIN

@export_category("Defender")
@export var defender: Unit
@export var def_terrain: Codex.TERRAIN
