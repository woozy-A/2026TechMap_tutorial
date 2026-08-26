// MARK: - Tutorial — Visualize Objects

var boxEntityByID: [UUID: ModelEntity] = [:]
var displayedEntityByID: [UUID: Entity] = [:]

func renderObjectBoxes() {
    objectRoot.children.removeAll()
    boxEntityByID.removeAll()
    displayedEntityByID.removeAll()

    for object in objects {
        let mesh = MeshResource.generateBox(size: object.dimensions)
        let box = ModelEntity(
            mesh: mesh,
            materials: [boxMaterial(isSelected: false)]
        )
        box.name = object.identifier.uuidString
        box.transform = Transform(matrix: object.transform)

        objectRoot.addChild(box)
        boxEntityByID[object.identifier] = box
        displayedEntityByID[object.identifier] = box
    }
}

func updateHighlight() {
    for (identifier, box) in boxEntityByID {
        box.model?.materials = [
            boxMaterial(isSelected: identifier == selectedObjectID)
        ]
    }
}
