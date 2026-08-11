let mesh = MeshResource.generateBox(size: object.dimensions)
let entity = ModelEntity(
    mesh: mesh,
    materials: [boxMaterial(isSelected: false)]
)
