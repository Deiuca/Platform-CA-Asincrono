extends Node2D

@export var cella_template : PackedScene
@export var height : int = 20
@export var width : int = 20

@export var generator_seed : int = randi() % 3000

var randomGenerator : RandomNumberGenerator = RandomNumberGenerator.new()

var livello : Node2D

#Ciò che una cella può essere in questo generatore, e le texture associate ad ciascun tipo di cella in questo mondo
var tipi_livello = {
	Init.tipi.ARIA: Init.aria,
	Init.tipi.MURO: Init.muro,
}

#Le celle che comporranno il mondo
var celle = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Crea Nodo livello
	self.livello = Node2D.new()
	self.livello.name = "Livello"
	add_child(self.livello)
	
	#Determina il seed del Generatore di mondo
	self.randomGenerator.set_seed(self.generator_seed)
	print(generator_seed)
	
	#Determina la scala delle Celle in base alla dimensione delle texture
	var tex_size = self.tipi_livello[self.tipi_livello.keys()[0]].get_size()
	
	var windows_size = get_viewport().size
	var cell_scale = Vector2((windows_size.x/tex_size.x)/self.width, (windows_size.y/tex_size.y)/self.height)
	
	#Popolo array Celle
	for ih in self.height:
		for iw in self.width:
			var istanza = cella_template.instantiate()
			istanza.inizializza(self.tipi_livello, self.randomGenerator, Vector2(width, height))
			istanza.position = Vector2(iw*tex_size.x*cell_scale.x, ih*tex_size.y*cell_scale.y)
			istanza.scale = cell_scale
			self.celle.append(istanza)
			
			
	#A ogni istanza nell'array di celle vengono definiti i suoi vicini
	for indx in range(self.celle.size()):
		var cella = self.celle[indx]      #Cella corrente
		#Pattern: SuSx, Su, SuDx, Sx, Dx, GiuSx, Giu, GiuDx
		#Sx
		if (indx-1) >= 0:
			cella.vicini[3] = self.celle[indx-1]
		#Dx
		@warning_ignore("integer_division", "integer_division", "integer_division")
		if (indx+1) < self.celle.size() and (indx+1)/self.width == indx/self.width:
			cella.vicini[4] = self.celle[indx+1]
		#Su
		if (indx-self.width) >= 0:
			cella.vicini[1] = self.celle[indx-self.width]
		#Giu
		if (indx+self.width) < self.celle.size():
			cella.vicini[6] = self.celle[indx+self.width]
		#SuSx
		if(indx-(self.width+1)) >= 0:
			cella.vicini[0] = self.celle[indx-(self.width+1)]
		#SuDx
		if ((indx-(self.width-1))/self.width) != indx/self.width:
			cella.vicini[2] = self.celle[indx-(self.width-1)]
		#GiuSx
		if (indx+(self.width-1)) < self.celle.size() and ((indx+(self.width-1))/self.width) != indx/self.width:
			cella.vicini[5] = self.celle[indx+(self.width-1)]
		#GiuDx
		if (indx+(self.width)) < self.celle.size() and (indx+(self.width))/self.width == (indx+(self.width+1))/self.width:
			cella.vicini[7] = self.celle[indx+(self.width+1)]
	
	#Ultima riga collassata a muro x fare pavimento
	for e in range((self.width*self.height)-self.width, (self.width*self.height)):
		self.celle[e].set_tipo(Init.tipi.MURO)
	
	#Setta randomicamente seeds per piattaforme
	
	#Sprite on screen
	#for cella in self.celle:
	for i in range(self.celle.size()):
		self.celle[i].label.text = str(i)
		self.livello.add_child(self.celle[i])
		if i == 751:
			pass
		self.celle[i].determina_tipo()

var test_counter = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	while test_counter < 2:
		for i in range(self.celle.size()):
			self.celle[i].determina_tipo()
		test_counter += 1
