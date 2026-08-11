private func renderObjectBoxes() {
    objectRoot.children.removeAll()
    entityByID.removeAll()

    for object in objects {
        let mesh = MeshResource.generateBox(size: object.dimensions)
        let entity = ModelEntity(
            mesh: mesh,
            materials: [boxMaterial(isSelected: false)]
        )
        entity.transform = Transform(matrix: object.transform)

        objectRoot.addChild(entity)
        entityByID[object.identifier] = entity
    }
}
