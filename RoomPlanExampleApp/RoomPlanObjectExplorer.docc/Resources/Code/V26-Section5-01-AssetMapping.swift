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
