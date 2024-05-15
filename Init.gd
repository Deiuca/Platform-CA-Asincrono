extends Node2D

#Tipi di cella in questo progetto
enum tipi {
ARIA, 
MURO, MURO_RAMPA_DOWN, MURO_RAMPA_UP,
PLATFORM, PLATFORM_OBSTACLE, PLATFORM_OBSTACLE_DOWN,
VERTICALE,
EDGE_DOWN, EDGE_DOWN_SX, 
NEMICO
}

#Risorse Texture nel progetto
#N.B. PRE-COND: tutte le texture devono avere le stesse dimensioni!!!
var aria = preload("res://Texture/trasparente.png")
var muro = preload("res://Texture/nero.png")
var piattaforma = preload("res://Texture/piattaforma.png")
var piattaforma_ostacolo = preload("res://Texture/piattaforma_ostacolo.png")
var piattaforma_ostacolo_down = preload("res://Texture/piattaforma_ostacolo_down.png")
var edge_down = preload("res://Texture/edge_down.png")
var edge_down_sx = preload("res://Texture/edge_down_sx.png")
var muro_rampa_down = preload("res://Texture/muro_ramp.png")
var muro_rampa_up = preload("res://Texture/muro_rampa_up.png")
var nemico = preload("res://Texture/nemico.png")
var verticale = preload("res://Texture/verticale.png")
