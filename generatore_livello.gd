extends Node2D

@export var cella_template : PackedScene
@export var height : int = 20
@export var width : int = 20

@export var generator_seed : int = randi() % 3000

var randomGenerator : RandomNumberGenerator = RandomNumberGenerator.new()

var livello : Node2D

#Ciò che una cella può essere in questo generatore, e le texture associate ad ciascun tipo di cella in questo generatore
var tipi_livello = {
	Init.tipi.ARIA: Init.aria,
	Init.tipi.MURO: Init.muro,
	Init.tipi.PLATFORM: Init.piattaforma,
	Init.tipi.PLATFORM_OBSTACLE : Init.piattaforma_ostacolo,
	Init.tipi.EDGE_DOWN : Init.edge_down,
	Init.tipi.EDGE_DOWN_SX : Init.edge_down_sx,
	Init.tipi.PLATFORM_OBSTACLE_DOWN : Init.piattaforma_ostacolo_down,
	Init.tipi.MURO_RAMPA_DOWN : Init.muro_rampa_down,
	Init.tipi.MURO_RAMPA_UP : Init.muro_rampa_up,
	Init.tipi.NEMICO : Init.nemico,
	Init.tipi.VERTICALE : Init.verticale
}

#Le celle che comporranno il mondo
var celle = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Crea Nodo livello
	self.livello = Node2D.new()
	self.livello.name = "Livello"
	self.livello.position = Vector2(20,20)
	add_child(self.livello)
	
	#Setta il seed del Generatore Randomico
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
			istanza.inizializza(self.tipi_livello, self.randomGenerator)
			istanza.position = Vector2(iw*tex_size.x*cell_scale.x, ih*tex_size.y*cell_scale.y)
			istanza.scale = cell_scale
			self.celle.append(istanza)
			
	#A ogni istanza nell'array di celle vengono definiti i suoi vicini
	for indx in range(self.celle.size()):
		var cella = self.celle[indx]      
		#Pattern dei viini: SuSx, Su, SuDx, Sx, Dx, GiuSx, Giu, GiuDx
		#Sx
		if (indx-1) >= 0 and indx/self.width == (indx-1)/self.width:
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
			cella.vicini[0] = self.celle[indx-self.width].vicini[3]
		#SuDx
		if ((indx-(self.width-1))/self.width) != indx/self.width:
			cella.vicini[2] = self.celle[indx-self.width].vicini[4]
		#GiuSx
		if (indx+(self.width-1)) < self.celle.size() and ((indx+(self.width-1))/self.width) != indx/self.width:
			cella.vicini[5] = self.celle[indx+(self.width-1)]
		#GiuDx
		if (indx+(self.width)) < self.celle.size() and (indx+(self.width))/self.width == (indx+(self.width+1))/self.width:
			cella.vicini[7] = self.celle[indx+(self.width+1)]
	
	#Vicinato Allargato
	for cella in self.celle:
		if cella.vicini[0] != null:
			var suSx = cella.vicini[0]
			cella.vicinato_allargato[0] = suSx.vicini[0] 
			cella.vicinato_allargato[1] = suSx.vicini[1]  
			cella.vicinato_allargato[5] = suSx.vicini[3] 
		if cella.vicini[1] != null:
			var su = cella.vicini[1]
			cella.vicinato_allargato[2] = su.vicini[1]
		if cella.vicini[3] != null:
			var sx = cella.vicini[3]
			cella.vicinato_allargato[7] = sx.vicini[3]
		if cella.vicini[2] != null:
			var suDx = cella.vicini[2]
			cella.vicinato_allargato[3] = suDx.vicini[1]  
			cella.vicinato_allargato[4] = suDx.vicini[2]   
			cella.vicinato_allargato[6] = suDx.vicini[4]   
		if cella.vicini[4] != null:
			var dx = cella.vicini[4]
			cella.vicinato_allargato[8] = dx.vicini[4]
		if cella.vicini[7] != null:
			var giuDx = cella.vicini[7]
			cella.vicinato_allargato[10] = giuDx.vicini[4]   
			cella.vicinato_allargato[15] = giuDx.vicini[7]  
			cella.vicinato_allargato[14] = giuDx.vicini[6]    
		if cella.vicini[6] != null:
			var giu = cella.vicini[6]
			cella.vicinato_allargato[13] = giu.vicini[6]  
		if cella.vicini[5] != null:
			var giuSx = cella.vicini[5]
			cella.vicinato_allargato[12] = giuSx.vicini[6] 
			cella.vicinato_allargato[11] = giuSx.vicini[5] 
			cella.vicinato_allargato[9] = giuSx.vicini[3] 
		
	#Ultima riga collassata a muro x fare pavimento
	for e in range((self.width*self.height)-self.width, (self.width*self.height)):
		self.celle[e].set_tipo(Init.tipi.MURO)
	
	#Setta sei celle come PLATFORM
	for h in range(1,3):
		var riga = ((((self.height/3)*h)-1)*self.width)-1
		for w in range(1,4):
			self.celle[(((self.width/4)*w))+riga].set_tipo(Init.tipi.PLATFORM)
	
	#Celle on screen
	#for cella in self.celle:
	for i in range(self.celle.size()):
		self.celle[i].label.text = str(i)
		self.livello.add_child(self.celle[i])

var test_counter = 0
var numero_CA = 6
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.test_counter < self.numero_CA:
		cellular_automata()
		for i in range(self.celle.size()):
			self.celle[i].correggi()
		self.test_counter += 1
	if self.test_counter == (self.numero_CA):
		for i in range(self.celle.size()):
			self.celle[i].correggi()
			#Per evitare che corregga in continuazione
		self.test_counter += 1

#Determina il nuovo stato delle celle
func cellular_automata():
	for i in range(self.celle.size()):
		self.celle[i].determina_tipo()
