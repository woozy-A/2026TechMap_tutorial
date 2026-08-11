private func renderObjectBoxes() {
    objectRoot.children.removeAll()

    for object in objects {
        let mesh = MeshResource.generateBox(size: object.dimensions)
        let entity = ModelEntity(
            mesh: mesh,
            materials: [boxMaterial(isSelected: false)]
        )

        objectRoot.addChild(entity)
    }
}
