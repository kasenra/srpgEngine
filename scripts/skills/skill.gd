class_name Skill 
extends Resource
## Base Type for skills. 
## Skills needing custom code inherit from this class.

## FLAG Skills use this class, and are checked for in other segments.
## ACTIVATOR Skills extend to SkillActivator -> SkillActivatorReplacement /  and have a percent chance activation in combat
## ADJUSTOR Skills extend to SkillAdjustor and modify unit stats in battle prediction
## POSTEFFECT Skills extend to SkillPostEffect and affect units after combat is done.
## TODO SUPPORTER Skills extend to SkillSupporter and modify a unit's support bonuses, often limited to certain characters
## TODO COMMAND Skills extend to SkillCommand -> SkillCommandAugment / SkillCommandNew and either add new commands or new effects to existing commands



@export var name: String
@export var thumbPath: String
@export var desc: String
