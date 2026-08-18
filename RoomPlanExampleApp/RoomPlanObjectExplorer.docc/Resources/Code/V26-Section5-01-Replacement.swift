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
