## Represents an "special" action, skill or ability that a player or another character may explicitly choose to perform. May have a cost and may require a target to be chosen.
## It may be a special skill/spell such as "Fireball", an innate ability such as "Fly", or a trivial command like "Examine".
## NOTE: In most games this does NOT include the very basic common actions such as movement, jumping, shooting etc.
## NOTE: This is NOT a player input action such as a joystick movement, gamepad button or keyboard keypress.

class_name Action
extends StatDependentResourceBase

# TODO: Limited number of uses
# TODO: Cooldowns
# TBD: A less ambiguous name, like Ability? Because "action" is a Godot term for all input events.


#region Parameters

@export var requiresTarget: bool

## The code to execute when this Action is performed. See [Payload] for explanation and available options.
@export var payload: Payload

@export var shouldShowDebugInfo: bool

#endregion


#region Derived Properties
var logName: String:
	get: return str(self.get_script().get_global_name(), " ", self, " ", self.name)
#endregion


#region Signals

## Emitted if [member requiresTarget] is `true` but a target has not been provided for [method perform]. 
## May be handled by game-specific UI to prompt the player to choose a target for this Action.
## NOTE: If this Action is to be performed via an [ActionsComponent]'s [method ActionsComponent.perform] then this signal will NOT be emitted; ONLY the Component's [signal ActionsComponent.didRequestTarget] is emitted.
signal didRequestTarget(source: Entity)

#endregion


#region Interface

## Returns the result of the [member payload], or `false` if the Payload or [member cost] payment or a required [param target] is missing.
func perform(paymentStat: Stat, source: Entity, target: Entity = null) -> Variant:
	printLog(str("perform() source: ", source, ", target: ", target))

	if not self.payload:
		Debug.printWarning("Missing payload", self)
		return false
	
	# Check for target
	if self.requiresTarget and target == null:
		self.didRequestTarget.emit(source)
		return false

	# Check if the offered Stat can pay for the cost, if there is a cost.
	if self.costStat and self.cost >= 0 and not validateOfferedStat(paymentStat):
		printLog(str("Payment failed! self.costStat: ", self.costStat, ", self.cost: ", self.cost, ", paymentStat: ", paymentStat))
		return false
	
	# Execute the payload!
	var payloadResult: Variant = payload.execute(source, target)

	# IMPORTANT: Deduct the cost from the Stat only if the payload was successfully executed!
	if payloadResult: # Must not be `null` and not `false`
		self.deductCostFromStat(paymentStat) # TBD: Validate even if the `cost` is negative?

	return payloadResult

#endregion


func printLog(message: String) -> void:
	if shouldShowDebugInfo: Debug.printLog(message, str(self.logName), "", "pink")
