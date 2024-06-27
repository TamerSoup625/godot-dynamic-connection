@tool
@icon("res://addons/dynamic_connection/object_icon.svg")
class_name DynamicConnection
extends RefCounted


## Helper class for handling a signal/callable connection and modifying it during runtime.
##
## [DynamicConnection] represents a connection between a [Signal] and a [Callable] or the absence of one.[br]
## This class ensures there's at most only one connection and avoids leaving leftover connections
## if its state ever changes.
## [codeblock]
## extends Node2D
## var _button_connection = DynamicConnection.new()
##
## func _ready():
##     var button1 = Button.new()
##     var button2 = Button.new()
##     # Connects "button1.pressed" signal to method "hide"
##     _button_connection.set_connection(button1.pressed, hide)
##     # Removes the old connection,
##     # and connects the signal "button2.pressed" to "hide"
##     _button_connection.set_signal(button2.pressed)
##     # With the call below, "button2.pressed" is no longer connected
##     # to "hide", but instead to the method "show"
##     _button_connection.set_callable(show)
##     # Disconnects "button2.pressed" from "show"
##     _button_connection.remove_connection()
## [/codeblock]
## Note that this class represents an [i]optional[/i] connection. This class can also work
## without a connection. The [code]*_or_null[/code] functions remove the connection if you supply
## null values, but their normal versions fail if you pass invalid ones.


var _signal: Signal
var _callable: Callable
var _flags: ConnectFlags = 0


## Initialize the class with a set of flags with [code]DynamicConnection.new()[/code].
func _init(flags: ConnectFlags = 0):
	_flags = flags
	remove_connection()


func _are_valid(p_signal: Signal, p_callable: Callable):
	return (not p_signal.is_null()) and is_instance_valid(p_signal.get_object()) and p_callable.is_valid()


# Set and remove connection
## Create a new [DynamicConnection] which already connected [code]p_signal[/code] to [code]p_callable[/code]
## with a set of flags.[br]
## Fails if [code]p_signal[/code] or [code]p_callable[/code] are invalid.
static func with_connection(p_signal: Signal = Signal(), p_callable: Callable = Callable(), flags: ConnectFlags = 0) -> DynamicConnection:
	var connection = DynamicConnection.new(flags)
	connection.set_connection(p_signal, p_callable, flags)
	return connection


## Remove the connection previously memorized if it exists,
## and connect [code]p_signal[/code] to [code]p_callable[/code] with a set of flags.[br]
## Fails if [code]p_signal[/code] or [code]p_callable[/code] are invalid. Also see [method set_connection_or_null].
func set_connection(new_signal: Signal, new_callable: Callable, flags: ConnectFlags = -1):
	assert(
			(not new_signal.is_null()) and is_instance_valid(new_signal.get_object()),
			'Invalid signal. If this is inteded and you want the connection to be removed when the signal is null, use "set_connection_or_null".',
	)
	assert(
			new_callable.is_valid(),
			'Invalid callable. If this is inteded and you want the connection to be removed when the callable is null, use "set_connection_or_null".',
	)
	set_connection_or_null(new_signal, new_callable, flags)


## Remove the connection previously memorized if it exists,
## and connect [code]p_signal[/code] to [code]p_callable[/code] with a set of flags.[br]
## If [code]p_signal[/code] or [code]p_callable[/code] are invalid, do not make any new connection.[br]
## Also see [method set_connection].
func set_connection_or_null(new_signal: Signal, new_callable: Callable, flags: ConnectFlags = -1):
	if flags != -1:
		_flags = flags
	
	# _signal and _callable are the old ones
	if _are_valid(_signal, _callable) and _signal.is_connected(_callable):
		_signal.disconnect(_callable)
	
	if _are_valid(new_signal, new_callable):
		new_signal.connect(new_callable, _flags)
	
	_signal = new_signal
	_callable = new_callable


## Disconnect the memorized signal with the memorized callable and clear this class' respective members.
func remove_connection():
	set_connection_or_null(Signal(), Callable())


# Set and Get signal
## Change the memorized signal to [code]p_signal[/code] and update the connections accordingly.[br]
## If [code]p_signal[/code] is invalid, remove the current connection if there was one.[br]
## Also see [method set_signal].
func set_signal_or_null(p_signal: Signal):
	set_connection_or_null(p_signal, _callable)


## Change the memorized signal to [code]p_signal[/code] and update the connections accordingly.[br]
## Fails if [code]p_signal[/code] is invalid. Also see [method set_signal_or_null].
func set_signal(p_signal: Signal):
	assert(
			(not p_signal.is_null()) and is_instance_valid(p_signal.get_object()),
			'Invalid signal. If this is inteded and you want the connection to be removed when the signal is null, use "set_signal_or_null".',
	)
	set_signal_or_null(p_signal)


## Returns the current connection's signal.
func get_signal() -> Signal:
	return _signal


# Set and Get callable
## Change the memorized callable to [code]p_callable[/code] and update the connections accordingly.[br]
## If [code]p_callable[/code] is invalid, remove the current connection if there was one.[br]
## Also see [method set_callable].
func set_callable_or_null(p_callable: Callable):
	set_connection_or_null(_signal, p_callable)


## Change the memorized callable to [code]p_callable[/code] and update the connections accordingly.[br]
## Fails if [code]p_callable[/code] is invalid. Also see [method set_callable_or_null].
func set_callable(p_callable: Callable):
	assert(
			p_callable.is_valid(),
			'Invalid callable. If this is inteded and you want the connection to be removed when the callable is null, use "set_callable_or_null".',
	)
	set_callable_or_null(p_callable)


## Returns the current connection's callable.
func get_callable() -> Callable:
	return _callable


# Boolean functions
## Returns [code]true[/code] if the memorized signal and callable are both valid (not null).[br]
## This method returning [code]true[/code] does not mean there is a connection.
## The connection can still be removed by outside sources
## or if [enum Object.CONNECT_ONE_SHOT] was set on connection and the signal was emitted at least once. See [method is_connection_made].
func is_valid() -> bool:
	return _are_valid(_signal, _callable)


## Returns [code]true[/code] if the memorized signal is connected to the memorized callable.[br]
## If this method returns [code]true[/code], then [method is_valid] will also return [code]true[/code].
func is_connection_made() -> bool:
	return is_valid() and _signal.is_connected(_callable)
