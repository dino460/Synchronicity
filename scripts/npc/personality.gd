extends Node

class_name Personality

## How aggressive the NPC tends to relate to others.
## 0 to 1.
## Higher values increase the chance of the NPC attacking others or having bad reputation.
## Lower values increase the chance of the NPC being passive.
@export var aggression : float
## How easily the NPC gets attached to others.
## 0 to 1.
## Higher values increase ease of creating new Relationships and having longer lasting ones.
## Lower values decrease the chance of creating new Relationships and makes existing ones fade faster.
@export var loyalty : float
## How easily the NPC takes risks and how big are those risks.
## 0 to 1.
## Higher values increase how easily the NPC might try something new.
## Lower values mean a more static NPC and decerease how easily the NPC might gamble.
@export var bravery : float
## How chaotic and NPC can be, how eaily is for it to  completely ignore its own Personality.
## 0 to 1.
## Higher values increase randomness.
## Lower values prioritize determinism.
@export var chaos : float
## How much the NPC would want to do stuff, especially if it is far away.
## 0 to 1.
## Higher values increase likelyhood of NPC to travel long distances, even on purpose
## Lower values increase change of NPC prioritizing closer activities
@export var energy : float

## Physical prowess of the NPC, how strong it is, how fast, how resiliant.
## 0 to 1.
## Higher values mean a stronger, more agile NPC.
## Lower values mean a more fragile NPC.
@export var body : float
## How 'smart' the NPC is.
## 0 to 1.
## Higher values nudges the NPc to take 'smarter' more rational decisions.
## Lower values prioritize wants to needs.
@export var mind : float
## How easy it is for the NPC to have its Personality changed.
## 0 to 1.
## Higher valuse increase chance of positive reiforcement and changing what it wants, and decreases other NPC influence over this one.
## Lower values increase chance of having its Personality changed by others, and decreases learning.
@export var soul : float
