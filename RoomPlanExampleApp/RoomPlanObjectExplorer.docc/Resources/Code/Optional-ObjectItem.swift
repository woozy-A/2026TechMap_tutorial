import RoomPlan

// Final Example-only state. CapturedRoom.Object remains unchanged.
var editedCategoryByID: [UUID: CapturedRoom.Object.Category] = [:]

func effectiveCategory(
    for object: CapturedRoom.Object
) -> CapturedRoom.Object.Category {
    editedCategoryByID[object.identifier] ?? object.category
}

private func removeSelectedObject() {
    guard let selectedObjectID else { return }

    objects.removeAll { $0.identifier == selectedObjectID }
    displayedEntityByID.removeValue(forKey: selectedObjectID)?.removeFromParent()
    boxEntityByID.removeValue(forKey: selectedObjectID)
    replacedObjectIDs.remove(selectedObjectID)
    rotationQuarterTurnsByID.removeValue(forKey: selectedObjectID)
    editedCategoryByID.removeValue(forKey: selectedObjectID)
    self.selectedObjectID = nil
}
