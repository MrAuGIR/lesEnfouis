class_name Audio
extends Node
## Manager audio (grey-box) — passe SFX (placeholders synthétisés).
## Tous les sons sont GÉNÉRÉS en mémoire (AudioStreamWAV, PCM 16 bits) : zéro
## fichier externe, on remplacera par de vrais sons à la passe DA/audio finale.
## Trois familles : gameplay (creuser, tir, coup, ramasser, construire),
## ALERTES (gaz / raid / PV bas / lampe — chacune un son DISTINCT et reconnaissable,
## car l'utilisateur est daltonien : l'oreille double l'information de l'écran),
## et feedbacks UI (ouverture de menu, validation, action invalide).
## Usage : main.gd / combat.gd appellent audio.play("nom").

const MIX_RATE := 22050
const POOL := 10                      # voix simultanées (sons qui se chevauchent)

var _lib := {}                        # nom -> AudioStreamWAV
var _players: Array[AudioStreamPlayer] = []
var _next := 0

func _ready() -> void:
	_ensure_bus("SFX")
	_build_library()
	for i in POOL:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)

# Joue un son du répertoire sur la prochaine voix libre du pool (round-robin).
func play(name: String, pitch := 1.0, vol_db := 0.0) -> void:
	var s = _lib.get(name)
	if s == null:
		return
	var p := _players[_next]
	_next = (_next + 1) % POOL
	p.stream = s
	p.pitch_scale = clampf(pitch, 0.5, 2.0)
	p.volume_db = vol_db
	p.play()

# --- Bus -----------------------------------------------------------------------
func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	var idx := AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")

# --- Synthèse ------------------------------------------------------------------
# Encode des échantillons flottants [-1..1] en AudioStreamWAV PCM 16 bits mono.
func _wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = MIX_RATE
	w.stereo = false
	w.data = data
	return w

# Un fragment de ton : balaye la fréquence freq0→freq1, forme d'onde + enveloppe
# attaque/relâche. wave : 0 sinus · 1 carré · 2 bruit · 3 triangle.
func _tone(freq0: float, freq1: float, dur: float, wave := 0, atk := 0.004, rel := 0.06, amp := 0.5) -> PackedFloat32Array:
	var n := int(dur * MIX_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	var ta := maxf(1.0, atk * MIX_RATE)
	var tr := maxf(1.0, rel * MIX_RATE)
	for i in n:
		var t := float(i) / float(n)
		var f := lerpf(freq0, freq1, t)
		phase += TAU * f / MIX_RATE
		var s := 0.0
		match wave:
			0: s = sin(phase)
			1: s = 1.0 if sin(phase) >= 0.0 else -1.0
			2: s = randf() * 2.0 - 1.0
			3: s = asin(sin(phase)) * (2.0 / PI)
		var env := 1.0
		if i < ta:
			env = float(i) / ta
		elif i > n - tr:
			env = float(n - i) / tr
		out[i] = s * env * amp
	return out

# Silence (pause entre deux notes d'une séquence).
func _gap(dur: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(dur * MIX_RATE))
	return out

# Concatène plusieurs fragments en un seul son.
func _seq(parts: Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for p in parts:
		out.append_array(p)
	return out

# Superpose deux fragments (somme), longueur = le plus long.
func _mix(a: PackedFloat32Array, b: PackedFloat32Array) -> PackedFloat32Array:
	var n: int = maxi(a.size(), b.size())
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var va := a[i] if i < a.size() else 0.0
		var vb := b[i] if i < b.size() else 0.0
		out[i] = clampf(va + vb, -1.0, 1.0)
	return out

func _build_library() -> void:
	# --- Gameplay ---
	# Creuser : « thunk » mat et grave (carré descendant + grain de bruit).
	_lib["dig"] = _wav(_mix(_tone(150.0, 90.0, 0.09, 1, 0.002, 0.05, 0.30),
		_tone(0.0, 0.0, 0.05, 2, 0.001, 0.04, 0.12)))
	# Ramasser : petit blip clair qui monte.
	_lib["pickup"] = _wav(_tone(620.0, 940.0, 0.08, 0, 0.003, 0.05, 0.40))
	# Coup de mêlée : souffle bref (bruit qui retombe vite).
	_lib["melee"] = _wav(_tone(0.0, 0.0, 0.12, 2, 0.002, 0.10, 0.26))
	# Tir : « pew » carré descendant + claquement de bruit.
	_lib["shoot"] = _wav(_mix(_tone(760.0, 200.0, 0.10, 1, 0.001, 0.06, 0.34),
		_tone(0.0, 0.0, 0.04, 2, 0.001, 0.03, 0.18)))
	# Ennemi détruit : grave qui s'effondre.
	_lib["enemy_down"] = _wav(_tone(260.0, 70.0, 0.22, 3, 0.003, 0.12, 0.34))
	# Héros touché : coup grave et sec (carré bas).
	_lib["hurt"] = _wav(_tone(210.0, 120.0, 0.17, 1, 0.002, 0.08, 0.42))
	# Construire : petite arpège ascendante (confirmation positive, deux notes).
	_lib["build"] = _wav(_seq([_tone(420.0, 420.0, 0.08, 3, 0.004, 0.04, 0.34),
		_tone(630.0, 630.0, 0.12, 3, 0.004, 0.07, 0.34)]))

	# --- Feedbacks UI ---
	_lib["ui_open"] = _wav(_tone(480.0, 560.0, 0.07, 0, 0.003, 0.05, 0.30))
	_lib["ui_click"] = _wav(_tone(680.0, 680.0, 0.05, 0, 0.002, 0.04, 0.30))
	# Action invalide : buzz grave descendant (« non »).
	_lib["invalid"] = _wav(_tone(180.0, 130.0, 0.16, 1, 0.002, 0.06, 0.36))
	# Troc conclu : deux notes hautes brillantes (pièces).
	_lib["trade"] = _wav(_seq([_tone(900.0, 900.0, 0.06, 0, 0.002, 0.04, 0.34),
		_tone(1320.0, 1320.0, 0.10, 0, 0.002, 0.06, 0.34)]))

	# --- ALERTES (chacune un timbre/motif DISTINCT — accessibilité) ---
	# Gaz : trois notes qui CHUTENT, dissonantes (menace qui descend / s'installe).
	_lib["alert_gas"] = _wav(_seq([_tone(440.0, 440.0, 0.12, 3, 0.004, 0.05, 0.34),
		_tone(330.0, 330.0, 0.12, 3, 0.004, 0.05, 0.34),
		_tone(233.0, 233.0, 0.20, 3, 0.004, 0.10, 0.34)]))
	# Raid : alarme qui MONTE, deux bips urgents répétés (carré).
	_lib["alert_raid"] = _wav(_seq([_tone(660.0, 660.0, 0.10, 1, 0.003, 0.03, 0.32),
		_gap(0.05), _tone(880.0, 880.0, 0.10, 1, 0.003, 0.03, 0.32),
		_gap(0.05), _tone(660.0, 660.0, 0.10, 1, 0.003, 0.03, 0.32),
		_gap(0.05), _tone(880.0, 880.0, 0.14, 1, 0.003, 0.05, 0.32)]))
	# PV bas : double battement grave (cœur qui cogne).
	_lib["alert_lowhp"] = _wav(_seq([_tone(120.0, 90.0, 0.10, 3, 0.003, 0.05, 0.40),
		_gap(0.08), _tone(120.0, 90.0, 0.14, 3, 0.003, 0.07, 0.40)]))
	# Lampe faible : deux notes douces qui descendent (pile qui faiblit).
	_lib["alert_lamp"] = _wav(_seq([_tone(560.0, 560.0, 0.09, 0, 0.004, 0.05, 0.26),
		_tone(400.0, 400.0, 0.14, 0, 0.004, 0.08, 0.26)]))
