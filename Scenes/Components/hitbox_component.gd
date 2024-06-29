# Base component for all hitboxes.
# Used as damage zone of all entities, weapons, bullets, etc.
# 
# To use, set proper collision layer and/or mask and add CollisionShape.

class_name HitboxComponent
extends Area2D

@export var damage: int
