## A container for a `Callable` function to execute when a [CollectibleComponent] is processed by a [CollectorComponent].
## This must be subclassed and the subclass MUST override the [method onCollectible_didCollect] method.
## TIP: Use the `Templates/Scripts/Resource/CollectiblePayloadTemplate.gd` template.

class_name CollectiblePayload
extends Resource


## A function to execute when a [CollectorComponent] picks up a [CollectibleComponent].
## May optionally return any value.
static func onCollectible_didCollect(collectorEntity: Entity, collectorComponent: CollectorComponent, collectibleComponent: CollectibleComponent) -> Variant:
	Debug.printWarning(str("onCollectible_didCollect() not implemented! collectorEntity: ", collectorEntity, ", collectorComponent: ", collectorComponent), str(collectibleComponent))
	return null