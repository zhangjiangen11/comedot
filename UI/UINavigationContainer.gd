## Replaces the first [Control] child with a different child in response to a child button or another event.

class_name UINavigationContainer
extends Container

# TODO: More flexibility and reliability?
# TODO: A UI navigation system based on global signals?


#region Parameters
@export var backButton: Button ## The "Back" button to show and hide depending on the navigation history.
@export var shouldShowDebugInfo: bool = false
#endregion


#region State
## A stack of scene paths representing the UI navigation history.
## NOTE: The END of the array is the TOP of the stack, and is the most recent scene/node/control.
var navigationStack: PackedStringArray # Better performance than Array[String]
#endregion


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetHistory()
	if backButton: connectBackButton()
	elif shouldShowDebugInfo: Debug.printWarning("Missing backButton", self) # Suppress warning in case there is a different way to close, such as the PauseButton.


func connectBackButton() -> void:
	if backButton: backButton.pressed.connect(self.onBackButton_pressed)


## Clears the [member navigationStack] array and re-adds the first child as the first member.
## Returns: The first child of type [Control]
func resetHistory() -> Control:
	navigationStack.clear()

	var firstChild: Control = self.findFirstChildControl()
	if firstChild:  addNodeToHistory(firstChild.scene_file_path)

	updateBackButton()
	showDebugInfo()
	return firstChild


## Returns: The new size of the history array.
func addNodeToHistory(path: String) -> int:
	navigationStack.append(path)
	updateBackButton()
	showDebugInfo()
	return navigationStack.size()


func findFirstChildControl() -> Control:
	return Tools.findFirstChildOfType(self, Control, false) # not includeParent


func replaceFirstChildControl(newControl: Control) -> bool:
	var childToReplace: Control = self.findFirstChildControl()

	if shouldShowDebugInfo: Debug.printDebug(str("replaceFirstChildControl(): ", childToReplace, " → ", newControl), self)

	if childToReplace:
		if Tools.replaceChild(self, childToReplace, newControl):
			childToReplace.queue_free() # NOTE: Important, as [remove_child()] does not delete the child.
			return true
	else:
		self.add_child(newControl)
		return true

	showDebugInfo()
	return false


func displayNavigationDestination(newDestination: String) -> bool:
	if  shouldShowDebugInfo: Debug.printDebug("displayNavigationDestination(): " + newDestination, self)
	var newDestinationScene: Node = Tools.instantiateSceneFromPath(newDestination) #navigationDestination.instantiate()
	var result: bool

	if newDestinationScene is not Control:
		Debug.printWarning(str("newDestinationScene is not a Control: ", newDestinationScene, " @ ", newDestination), self)
		return false

	if self.replaceFirstChildControl(newDestinationScene):
		navigationStack.append(newDestination)
		result = true
	else:
		result = false

	updateBackButton()
	if shouldShowDebugInfo:
		showDebugInfo()
		Debug.printDebug(str("1st Child: ", self.findFirstChildControl(), " — History: ", navigationStack), self)
	return result


func onBackButton_pressed() -> void:
	goBack()


func goBack() -> void:
	# GODOT: Why is there no pop_back() for PackedArrays??

	# Have to have at least 2 nodes to be able to go back in history.
	# NOTE: Do not store the size because it will change.
	if navigationStack.size() <= 1: return

	# Remove the currently displayed node
	navigationStack.remove_at(navigationStack.size() - 1)

	# Pop again to get the previous node
	var previousDestination: String = navigationStack[navigationStack.size() - 1]
	navigationStack.remove_at(navigationStack.size() - 1)
	# It will be appended to [navigationStack] again in displayNavigationDestination()

	self.displayNavigationDestination(previousDestination)


func updateBackButton() -> void:
	if not is_instance_valid(backButton): return
	# Show the button if there is more than 1 node in the history.
	backButton.visible = navigationStack.size() > 1


func showDebugInfo() -> void:
	if not shouldShowDebugInfo: return
	Debug.watchList.firstChild = self.findFirstChildControl()
	Debug.watchList.navigationStack = "\n⬆ ".join(self.navigationStack)
