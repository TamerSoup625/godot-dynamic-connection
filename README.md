# Dynamic Connection: Remove Signal Connection Boilerplate
This plugin adds the **DynamicConnection** class for handling a signal/callable connection and modifying it during runtime.

DynamicConnection represents a connection between a Signal and a Callable or the absence of one. 
This class ensures there's at most only one connection and avoids leaving leftover connections if its state ever changes.

## Example use
```gdscript
extends Node2D
var _button_connection = DynamicConnection.new()

func _ready():
	var button1 = Button.new()
	var button2 = Button.new()
	# Connects "button1.pressed" signal to method "hide"
	_button_connection.set_connection(button1.pressed, hide)
	# Removes the old connection,
	# and connects the signal "button2.pressed" to "hide"
	_button_connection.set_signal(button2.pressed)
	# With the call below, "button2.pressed" is no longer connected
	# to "hide", but instead to the method "show"
	_button_connection.set_callable(show)
	# Disconnects "button2.pressed" from "show"
	_button_connection.remove_connection()
```
