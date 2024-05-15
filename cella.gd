extends Sprite2D

class_name Cella

#ARIA è il default stato di una cella
@export var default_tipo : Init.tipi = Init.tipi.ARIA

var tipo : Init.tipi = self.default_tipo
var tipi_livello = {}
var randomGenerator : RandomNumberGenerator

#Pattern: SuSx, Su, SuDx, Sx, Dx, GiuSx, Giu, GiuDx
var vicini = [null,null,null,null,null,null,null,null]

var vicinato_allargato = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]

func inizializza(tipi_livello : Dictionary, randomGenerator : RandomNumberGenerator):
	self.texture = tipi_livello[self.default_tipo]
	self.tipi_livello = tipi_livello
	self.randomGenerator = randomGenerator

#Debug
var label : Label = Label.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#Debug
	self.label.scale = Vector2(fmod(self.scale.x, 1)-0.2,fmod(self.scale.y, 1)-0.2)
	#add_child(self.label)

func determina_tipo():
	
	var num_vicini_muro = vicini_con_stato(Init.tipi.MURO)
	var num_vicini_aria = vicini_con_stato(Init.tipi.ARIA)
	var num_vicini_allargati_muro = vicini_allargati_con_stato(Init.tipi.MURO)
	var num_vicini_allargati_aria = vicini_allargati_con_stato(Init.tipi.ARIA)
	var num_vicini_allargati_piattaforma = vicini_allargati_con_stato(Init.tipi.PLATFORM)
	
	#(1) Se tutti vicini sono ARIA % diventi platform
	if (num_vicini_aria + num_vicini_allargati_aria) == 24 :
		if( self.tipo == Init.tipi.ARIA ):
			probabilita_diventi_tipo(0.5, Init.tipi.PLATFORM)
			return
	
	#(2) Se Gsx G Gdx sono muro % diventi muro
	if(are_cells_stato([7, 6, 5], Init.tipi.MURO) and are_cells_stato([2, 0, 1], Init.tipi.ARIA)):
		if  not are_cells_stato([3], [Init.tipi.MURO_RAMPA_DOWN, Init.tipi.MURO_RAMPA_UP]) and not are_cells_stato([4], [Init.tipi.MURO_RAMPA_DOWN, Init.tipi.MURO_RAMPA_UP]):
			if probabilita_diventi_tipo(30.0, Init.tipi.MURO):
				return
	
	#(3) Se a VDx,Dx,Sx,VSx è piattaforma, favorisce che diventi ARIA  
	if are_cells_stato([3, 4, 15,16], [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE, Init.tipi.PLATFORM_OBSTACLE_DOWN]) and not are_cells_stato([1], Init.tipi.VERTICALE):
		if probabilita_diventi_tipo(30.0, Init.tipi.ARIA):
			return
		
	#(4) Se Dx è PIATTAFORMA e sotto e sopra è aria, diventa piattaforma
	if are_cells_stato([4], Init.tipi.PLATFORM, true) and are_cells_stato([6, 1], Init.tipi.ARIA, true ) and not are_cells_stato([3], Init.tipi.EDGE_DOWN):
		if not (are_cells_stato([0], [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE, Init.tipi.PLATFORM_OBSTACLE_DOWN, Init.tipi.VERTICALE], true) or are_cells_stato([2], [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE, Init.tipi.PLATFORM_OBSTACLE_DOWN, Init.tipi.VERTICALE], true)):
			if probabilita_diventi_tipo(30.0, Init.tipi.PLATFORM):
				return
	
	#(5) Se Sx è PIATTAFORMA e sotto e sopra è aria, diventa % PLATFORM
	if are_cells_stato([3], Init.tipi.PLATFORM, true) and are_cells_stato([6, 1], Init.tipi.ARIA, true):
		if not (are_cells_stato([0], [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE, Init.tipi.PLATFORM_OBSTACLE_DOWN, Init.tipi.VERTICALE], true) or are_cells_stato([2], [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE, Init.tipi.PLATFORM_OBSTACLE_DOWN, Init.tipi.VERTICALE], true)):
			if probabilita_diventi_tipo(30.0, Init.tipi.PLATFORM):
				return

	#(6) Se VSx, Sx è platform & Dx aria, % diventa EDGE 
	if(are_cells_stato([3, 15], Init.tipi.PLATFORM, true)):
		if are_cells_stato([4], Init.tipi.ARIA):
			if probabilita_diventi_tipo(40.0, Init.tipi.EDGE_DOWN):
				return
	
	#(7) Se Sx Dx è platform, può diventare ostacolo. Ostacolo 50% Up 50% Down
	if(are_cells_stato([3,4], Init.tipi.PLATFORM, true)):
		if determina_se_accade(25.0):
			if not probabilita_diventi_tipo(50.0, Init.tipi.PLATFORM_OBSTACLE):
				set_tipo(Init.tipi.PLATFORM_OBSTACLE_DOWN)
			return
			
	#(8) Verticale se sopra PLATFORM_OBSTACLE_DOWN down e EDGE DOWN e sotto aria e lontano da platform
	#	 Se VG hs un PLATFORM_OBSTACLE EDGE_DOWN PLATFORM -> più probabile VER|TICAlE
	if are_cells_stato([1], [Init.tipi.PLATFORM_OBSTACLE_DOWN, Init.tipi.EDGE_DOWN], true) and are_cells_stato([6], Init.tipi.ARIA):
		if are_cells_stato([21], [Init.tipi.PLATFORM_OBSTACLE, Init.tipi.EDGE_DOWN, Init.tipi.PLATFORM]):
			set_tipo(Init.tipi.VERTICALE)
			return
		else:
			if probabilita_diventi_tipo(15.0, Init.tipi.VERTICALE):
					return
	
	#(9) Verticale se sotto PLATFORM_OBSTACLE
	if are_cells_stato([6], Init.tipi.PLATFORM_OBSTACLE, true):
		if probabilita_diventi_tipo(40.0, Init.tipi.VERTICALE):
				return
	
	#(10) Se VSx o Sx o VDx o Dx -> % NEMICO
	var cond1 = are_cells_stato([7], Init.tipi.PLATFORM_OBSTACLE, true)
	var cond2 = are_cells_stato([17], Init.tipi.PLATFORM_OBSTACLE, true)
	var cond3 = are_cells_stato([18], Init.tipi.PLATFORM_OBSTACLE, true)
	if are_cells_stato([5], Init.tipi.PLATFORM_OBSTACLE, true) or cond1 or cond2 or cond3:
		if not (are_cells_stato([4], Init.tipi.NEMICO) or are_cells_stato([3], Init.tipi.NEMICO)):
			probabilita_diventi_tipo(30.0, Init.tipi.NEMICO)
	
	#Regole x RAMPE MURO
	
	#(11) Se Sx MURO; Dx ARIA; S MURO; SDx NON MURO 
	if are_cells_stato([3], Init.tipi.MURO) and are_cells_stato([4], Init.tipi.ARIA) and are_cells_stato([6], Init.tipi.MURO, true) and  not are_cells_stato([7], Init.tipi.MURO_RAMPA_DOWN, true) :
		probabilita_diventi_tipo(40.0, Init.tipi.MURO_RAMPA_DOWN)
	
	#(12) Se Dx MURO; Sx ARIA; S MURO; SSx NON MURO 
	if are_cells_stato([4], Init.tipi.MURO) and are_cells_stato([3], Init.tipi.ARIA) and are_cells_stato([6], Init.tipi.MURO, true) and not are_cells_stato([5], Init.tipi.MURO_RAMPA_UP, true):
		probabilita_diventi_tipo(40.0, Init.tipi.MURO_RAMPA_UP)
	
	#(13) Se Dx e SX MURO -> MURO
	if are_cells_stato([4], Init.tipi.MURO) and are_cells_stato([3], Init.tipi.MURO):
		set_tipo(Init.tipi.MURO)

#Applica Regole Correzione
func correggi():
	
	var num_vicini_muro = vicini_con_stato(Init.tipi.MURO)
	var num_vicini_aria = vicini_con_stato(Init.tipi.ARIA)
	var num_vicini_allargati_muro = vicini_allargati_con_stato(Init.tipi.MURO)
	var num_vicini_allargati_aria = vicini_allargati_con_stato(Init.tipi.ARIA)
	var num_vicini_allargati_piattaforma = vicini_allargati_con_stato(Init.tipi.PLATFORM)
	var num_vicini_rampa_down = vicini_con_stato(Init.tipi.MURO_RAMPA_DOWN)
	var num_vicini_rampa_up = vicini_con_stato(Init.tipi.MURO_RAMPA_UP)
	
	#REGOLE CORREZIONE
	
	#Se MURO_RAMPA_DOWN è vicino MURO_RAMPA_DOWN -> ARIA. Per evitare formazione piramidi
	if self.tipo == Init.tipi.MURO_RAMPA_DOWN and num_vicini_rampa_down > 0:
		set_tipo(Init.tipi.ARIA)
	
	#Se MURO_RAMPA_UP è vicino MURO_RAMPA_UP -> ARIA. Per evitare formazione piramidi
	if self.tipo == Init.tipi.MURO_RAMPA_UP and num_vicini_rampa_up > 0:
		set_tipo(Init.tipi.ARIA)
	
	#Controllo che MURO_RAMPA siano posizionte correttamente 
	if self.tipo == Init.tipi.MURO_RAMPA_UP and (not are_cells_stato([3], Init.tipi.ARIA) or not are_cells_stato([4], Init.tipi.MURO, true)):
		set_tipo(Init.tipi.ARIA)
		
	#Controllo che MURO_RAMPA siano posizionte correttamente 
	if self.tipo == Init.tipi.MURO_RAMPA_DOWN and (not are_cells_stato([4], Init.tipi.ARIA) or not are_cells_stato([3], Init.tipi.MURO, true)):
		set_tipo(Init.tipi.ARIA)
	
	#Controllo se VERTICALE compatibile con vicinato
	if self.tipo == Init.tipi.VERTICALE and ( (not are_cells_stato([6], Init.tipi.PLATFORM_OBSTACLE) or not are_cells_stato([1], Init.tipi.ARIA)) and (not are_cells_stato([6], Init.tipi.ARIA) or not are_cells_stato([1], [Init.tipi.PLATFORM_OBSTACLE_DOWN, Init.tipi.EDGE_DOWN], true))):
		set_tipo(Init.tipi.ARIA)
	
	#Se Sx è PIATTAFORMA && VSx ARIA -> Piattaforma
	if self.tipo == Init.tipi.ARIA  and are_cells_stato([3], Init.tipi.PLATFORM, true) and are_cells_stato([15], Init.tipi.ARIA, true):
		set_tipo(Init.tipi.PLATFORM)
		
	#Se Dx è PIATTAFORMA && VDx ARIA -> Piattaforma
	if self.tipo == Init.tipi.ARIA and are_cells_stato([4], Init.tipi.PLATFORM, true) and are_cells_stato([16], Init.tipi.ARIA, true) and not are_cells_stato([3], Init.tipi.EDGE_DOWN):
		set_tipo(Init.tipi.PLATFORM)
	
	#Controlla che nemico non flutti
	if self.tipo == Init.tipi.ARIA and are_cells_stato([1], Init.tipi.NEMICO, true):
		self.vicini[1].set_tipo(Init.tipi.ARIA)
	
	#Se piattaforma isolata -> ARIA
	if self.tipo == Init.tipi.PLATFORM and num_vicini_aria == 8:
		set_tipo(Init.tipi.ARIA)
	
	#Se piattaform like e isolata -> ARIA
	if self.tipo == Init.tipi.PLATFORM or self.tipo == Init.tipi.VERTICALE or self.tipo == Init.tipi.PLATFORM_OBSTACLE or self.tipo == Init.tipi.PLATFORM_OBSTACLE_DOWN or self.tipo == Init.tipi.EDGE_DOWN:
		if num_vicini_muro > 0 or num_vicini_rampa_down > 0 or num_vicini_rampa_up >0 or num_vicini_allargati_muro > 0:
			set_tipo(Init.tipi.ARIA)
	
	#Se MURO RAMPA sopra ha MURO -> MURO
	if (self.tipo == Init.tipi.MURO_RAMPA_UP or self.tipo == Init.tipi.MURO_RAMPA_DOWN ) and self.vicini[1].tipo == Init.tipi.MURO:
		set_tipo(Init.tipi.MURO)
	
	#Se PLATFORM è vicina ≠ ARIA o NEMICO -> ARIA
	if  self.tipo == Init.tipi.PLATFORM and not are_cells_stato([1,6], [Init.tipi.ARIA, Init.tipi.NEMICO], true):
		set_tipo(Init.tipi.ARIA)
	
	#Se EDGE ha a Dx ≠ ARIA -> ARIA 
	if self.tipo == Init.tipi.EDGE_DOWN and (not are_cells_stato([4], Init.tipi.ARIA) or not are_cells_stato([3], Init.tipi.PLATFORM)):
		set_tipo(Init.tipi.ARIA)
	
	#Se NEMICO ha S = ARIA -> ARIA
	if self.tipo == Init.tipi.NEMICO and are_cells_stato([6], Init.tipi.ARIA):
		set_tipo(Init.tipi.ARIA)
		
	if are_cells_stato([-1],  [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE, Init.tipi.PLATFORM_OBSTACLE_DOWN]):
		if are_cells_stato([0], [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE, Init.tipi.PLATFORM_OBSTACLE_DOWN]) or are_cells_stato([2], [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE, Init.tipi.PLATFORM_OBSTACLE_DOWN]):
			set_tipo(Init.tipi.ARIA)

func are_cells_stato(array_celle , tipo , devono_esistere = false) -> bool:
	if typeof(tipo) == TYPE_ARRAY:
		return check_cells_stati(array_celle, tipo, devono_esistere)
	else:
		return check_cells_stato(array_celle, tipo, devono_esistere)

func check_cells_stato(array_celle , tipo, devono_esistere = false):
	for index in array_celle:
		var cella = recupera_vicino_by_ordine(index)
		if (((cella.tipo != tipo) if cella != null else (devono_esistere))):
			return false
	return true

func check_cells_stati(array_celle , tipi , devono_esistere = false):
	for index in array_celle:
		var cella = recupera_vicino_by_ordine(index)
		if ((( not cella.tipo in tipi) if cella != null else (devono_esistere))):
			return false
	return true
	
func recupera_vicino_by_ordine(index : int) -> Cella:
	if (index > 7):
		return self.vicinato_allargato[index - 8]
	else:
		return self.vicini[index] if index >= 0 else self

func determina_se_accade(probabilita : float) -> bool:
	probabilita = fmod(probabilita, 100.0)
	var random = self.randomGenerator.randf_range(0,100)
	if random <= probabilita:
		return true
	return false
	
func probabilita_diventi_tipo(probabilita : float, tipo_da_settare : Init.tipi)-> bool:
	if determina_se_accade(probabilita):
			if self.tipo != tipo_da_settare:
				self.set_tipo(tipo_da_settare)
				return true
	return false

func vicini_con_stato(tipo : Init.tipi) -> int:
	var contatore = 0
	for vicino in vicini:
		if vicino != null and vicino.tipo == tipo:
			contatore += 1
	return contatore

func vicini_allargati_con_stato(tipo : Init.tipi) -> int:
	var contatore = 0
	for vicino in vicinato_allargato:
		if vicino != null and vicino.tipo == tipo:
			contatore += 1
	return contatore

func set_tipo(tipo : Init.tipi):
	if tipo in self.tipi_livello:
		self.tipo = tipo
		self.texture = tipi_livello[tipo]
		return
	print("Tipo non consentito!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
