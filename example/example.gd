extends Control


# Initialize a null connection
# You can supply flags to the new() function
# You can also use DynamicConnection.with_connection() to create a new object with a connection
var _my_connection := DynamicConnection.new()

@onready var buttons = [%Button1, %Button2, %Button3]
@onready var callbacks = [%Sprite.rotate.bind(PI / 2), %Particles.restart]
@onready var signal_option: OptionButton = %SignalOption
@onready var callable_option: OptionButton = %CallableOption


func _ready() -> void:
	# Use set_connection to change both signal and callable
	_my_connection.set_connection(buttons[0].pressed, callbacks[0])


func _on_signal_option_item_selected(index: int) -> void:
	if index == 3:
		# DynamicConnection can be null safe
		# The *_or_null() functions work with invalid values,
		# whereas the other ones fail if you supply a null value
		_my_connection.set_signal_or_null(Signal())
		return
	# Use set_signal to change only the signal
	_my_connection.set_signal(buttons[index].pressed)


func _on_callable_option_item_selected(index: int) -> void:
	if index == 2:
		_my_connection.set_callable_or_null(Callable())
		return
	# Use set_callable to change only the callable
	_my_connection.set_callable(callbacks[index])


func _on_remove_connection_pressed() -> void:
	# The connection can be removed
	_my_connection.remove_connection()
	signal_option.select(-1)
	callable_option.select(-1)


func _on_connect_oneshot_toggled(toggled_on: bool) -> void:
	# You can change flags in the set_connection function
	_my_connection.set_connection_or_null(
			_my_connection.get_signal(),
			_my_connection.get_callable(),
			CONNECT_ONE_SHOT if toggled_on else 0,
	)
