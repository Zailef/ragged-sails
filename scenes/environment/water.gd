@tool
extends Sprite2D;

func calculate_aspect_ratio():
	material.set("aspect_ratio", scale.y/scale.x)
