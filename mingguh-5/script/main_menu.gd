extends Control

@onready var input_com: LineEdit = $CanvasLayer/Panel/VBoxContainer/InputCom
@onready var input_baud: LineEdit = $CanvasLayer/Panel/VBoxContainer/InputBaud
@onready var konek_btn: Button = $CanvasLayer/Panel/VBoxContainer/Button
@onready var label: Label = $CanvasLayer/Label
@onready var ui_controller = $Master_Hand
@onready var master_hand: Node2D = $Master_Hand
func _ready():
	label.text = " "


func _on_button_pressed() -> void:
	var com_text := input_com.text.strip_edges()
	var baud_text := input_baud.text.strip_edges()

	# --- Validasi ---
	if com_text == "":
		label.text = "COM port kosong!"
		return

	if baud_text == "":
		label.text = "Baud rate kosong!"
		return

	if not baud_text.is_valid_int():
		label.text = "Baud rate harus angka!"
		return

	var port := _normalize_com(com_text)
	var baud := int(baud_text)

	# --- Connect ---
	print("🔌 Mencoba connect ke:", port, " Baud:", baud)

	SerialManager.serial.set_port(port)
	SerialManager.serial.set_baud_rate(baud)

	if SerialManager.serial.open():
		label.text = "SUCCESS"
		SerialManager.serial.writeline("1")
		if !master_hand.serial.is_open:
			master_hand.serial = SerialManager.serial
	else:
		label.text = "Gagal"

func _normalize_com(s: String) -> String:
	s = s.to_upper()

	if s.begins_with("COM"):
		var number := s.substr(3)
		if number.is_valid_int():
			return "\\\\.\\COM%s" % number

	# Kalau cuma angka (user ngetik "6")
	if s.is_valid_int():
		return "\\\\.\\COM%s" % s

	# fallback (biar gak crash)
	return s
