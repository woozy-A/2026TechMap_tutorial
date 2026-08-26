// MARK: - Tutorial — Replace with 3D Model

let furnitureAssetsByCategory: [
    CapturedRoom.Object.Category: FurnitureAsset
] = [
    .chair: FurnitureAsset(resourceName: "Chair")
]

var selectedObject: CapturedRoom.Object? {
    guard let selectedObjectID else { return nil }
    return objects.first { $0.identifier == selectedObjectID }
}

var canReplaceSelectedObject: Bool {
    guard let selectedObject else { return false }
    return furnitureAssetsByCategory[selectedObject.category] != nil
        && !replacedObjectIDs.contains(selectedObject.identifier)
}

func replaceSelectedObject() async throws {
    guard let selectedObject,
          let furnitureAsset = furnitureAssetsByCategory[selectedObject.category],
          canReplaceSelectedObject else { return }

    let identifier = selectedObject.identifier
    let replacement = try await furnitureModelProvider.makeModel(
        furnitureAsset,
        fitting: selectedObject.dimensions
    )
    guard selectedObjectID == identifier else { return }

    replacement.transform = Transform(matrix: selectedObject.transform)
    displayedEntityByID[identifier]?.removeFromParent()
    objectRoot.addChild(replacement)
    displayedEntityByID[identifier] = replacement
    boxEntityByID.removeValue(forKey: identifier)
    replacedObjectIDs.insert(identifier)

    updateStatus()
    frameRoom()
}
