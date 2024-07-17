## ATTENTION: This script MUST be attached to the root node of the main scene of your game.
## "Boots" and initializes the Comedot Framework and applies global flags.
## NOTE: If you need a custom functionality for your main scene's root node, such as initializing the game-specific environment, then your script must extend [Start] and call [super._ready()]

class_name Start
extends Node


#region Framework Settings

@export_category("Comedot")

@export_group("Debugging Flags")

## NOTE: Only applicable in debug builds (i.e. running from the Godot Editor)
@export var showDebugWindow: bool = true:
	set(newValue):
		showDebugWindow = newValue
		if Debug.window: Debug.window.visible = newValue

## Sets the visibility of "debug"-level messages in the log.
## NOTE: Does NOT affect normal logging.
@export var printDebugLogs: bool = true:
	set(newValue):
		printDebugLogs = newValue
		Debug.printDebugLogs = newValue

## Sets the visibility of the debug information overlay text.
## NOTE: Does NOT affect the visibility of the framework warning label.
@export var showDebugLabels: bool = true:
	set(newValue):
		showDebugLabels = newValue
		Debug.showDebugLabels = newValue

@export var showTestBackground: bool = true:
	set(newValue):
		showTestBackground = newValue
		if GlobalOverlay.testBackground: GlobalOverlay.testBackground.visible = newValue

#endregion


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.hasStartScript = true
	Debug.performFrameworkChecks() # Update the warning about missing Start script
	applyGlobalFlags()


func applyGlobalFlags() -> void:
	GlobalOverlay.testBackground.visible = self.showTestBackground
	Debug.window.visible		= self.showDebugWindow if OS.is_debug_build() else false
	Debug.printDebugLogs		= self.printDebugLogs
	Debug.showDebugLabels	= self.showDebugLabels
