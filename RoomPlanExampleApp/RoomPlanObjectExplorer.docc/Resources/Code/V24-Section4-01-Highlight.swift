    func updateHighlight() {
        for (identifier, box) in boxEntityByID {
            box.model?.materials = [
                boxMaterial(isSelected: identifier == selectedObjectID)
            ]
        }
    }

    // MARK: - Tutorial — Replace with 3D Model
