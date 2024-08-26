## Description

class_name TestAmmoUpgradePayload
extends UpgradePayload


static func onUpgrade_didAcquireOrLevelUp(upgrade: Upgrade, entity: Entity) -> bool:
	super.onUpgrade_didAcquireOrLevelUp(upgrade, entity)
	var ammo: Stat = entity.getComponent(StatsComponent).getStat(&"testAmmo")
	ammo.max += 10; ammo.setToMax()
	return false


static func onUpgrade_willDiscard(upgrade: Upgrade, entity: Entity) -> bool:
	super.onUpgrade_willDiscard(upgrade, entity)
	return false

