class_name BattleParticipant ## Stores information about a unit in the context of a battle.
extends Node

@export_group("Unit Ref")
@export var u : Unit 
@export var w : Weapon
## We'll calculate pseudostats from weapon and stats in the Unit
##	and adjusting based on the enemy will be handled here.
@export_group("Adjusted Pseudostats Offenses")
@export var adj_dmg : int ## DMG - Enemy Prot + Support Bonuses x Effectiveness
@export var adj_hit : int ### HIT - Enemy Avo + Support Bonuses + Weapon Triangle
@export var adj_crit : int ## CRIT - Enemy Ddg + Support Bonuses
@export_group("Adjusted Pseudostat Defenses")
@export var adj_prot: int ## PROT+ Terrain Prot+ Support Bonuses
@export var adj_avo : int ## AVO + Terrain Avo + Support Bonuses
@export var adj_ddg : int ## DDG + Support Bonuses

func adjust(terrainBonus : Vector4i, supportBonus : Array[int]) -> void: ## TODO add support and terrain
	adj_dmg = u.dmg
	adj_hit = u.hit
	adj_crit= u.crit
	
	adj_prot= u.prot
	adj_avo = u.avo
	adj_ddg = u.ddg

func oppose(e: BattleParticipant) -> void: ## TODO Adjust DMG, HIT, and CRIT by enemy PROT(+DEF/RES), AVO, and DDG
	pass
