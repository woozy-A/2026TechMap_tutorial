    // MARK: - Tutorial — Rotate the 3D Model

    var canRotateSelectedObject: Bool {
        guard let selectedObjectID else { return false }
        return replacedObjectIDs.contains(selectedObjectID)
    }
