    // MARK: - Tutorial — Replace with 3D Model

    var selectedObject: CapturedRoom.Object? {
        guard let selectedObjectID else { return nil }
        return objects.first { $0.identifier == selectedObjectID }
    }

    var canReplaceSelectedObject: Bool {
        guard let selectedObject else { return false }
        return selectedObject.category == .chair
            && !replacedObjectIDs.contains(selectedObject.identifier)
    }
