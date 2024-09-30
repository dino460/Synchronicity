extends Node

class_name Personality

## How aggressive the NPC tends to relate to others.
## 0 to 1.
## Higher values increase the chance of the NPC attacking others or having bad reputation.
## Lower values increase the chance of the NPC being passive.
@export var aggression : float = 0.0
## How easily the NPC gets attached to others.
## 0 to 1.
## Higher values increase ease of creating new Relationships and having longer lasting ones.
## Lower values decrease the chance of creating new Relationships and makes existing ones fade faster.
@export var loyalty : float = 0.0
## How easily the NPC takes risks and how big are those risks.
## 0 to 1.
## Higher values increase how easily the NPC might try something new.
## Lower values mean a more static NPC and decerease how easily the NPC might gamble.
@export var bravery : float = 0.0
## How chaotic and NPC can be, how eaily is for it to  completely ignore its own Personality.
## 0 to 1.
## Higher values increase randomness.
## Lower values prioritize determinism.
@export var chaos : float = 0.0
## How much the NPC would want to do stuff, especially if it is far away.
## 0 to 1.
## Higher values increase likelyhood of NPC to travel long distances, even on purpose
## Lower values increase change of NPC prioritizing closer activities
@export var energy : float = 0.0

## Physical prowess of the NPC, how strong it is, how fast, how resiliant.
## 0 to 1.
## Higher values mean a stronger, more agile NPC.
## Lower values mean a more fragile NPC.
@export var body : float = 0.0
## How 'smart' the NPC is.
## 0 to 1.
## Higher values nudges the NPc to take 'smarter' more rational decisions.
## Lower values prioritize wants to needs.
@export var mind : float = 0.0
## How easy it is for the NPC to have its Personality changed.
## 0 to 1.
## Higher valuse increase chance of positive reiforcement and changing what it wants, and decreases other NPC influence over this one.
## Lower values increase chance of having its Personality changed by others, and decreases learning.
@export var soul : float = 0.0

func _ready():
	if aggression <= 0:
		aggression = randf_range(0.001, 1.0)
	if loyalty <= 0:
		loyalty = randf_range(0.001, 1.0)
	if bravery <= 0:
		bravery = randf_range(0.001, 1.0)
	if chaos <= 0:
		chaos = randf_range(0.001, 1.0)
	if energy <= 0:
		energy = randf_range(0.001, 1.0)
	if body <= 0:
		body = randf_range(0.001, 1.0)
	if mind <= 0:
		mind = randf_range(0.001, 1.0)
	if soul <= 0:
		soul = randf_range(0.001, 1.0)
