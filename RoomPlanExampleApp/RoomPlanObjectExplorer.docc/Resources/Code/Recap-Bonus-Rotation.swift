// MARK: - Tutorial — Rotate the 3D Model

var canRotateSelectedObject: Bool {
    guard let selectedObjectID else { return false }
    return replacedObjectIDs.contains(selectedObjectID)
}

func rotateSelectedObject() {
    guard let selectedObject,
          canRotateSelectedObject,
          let replacement = displayedEntityByID[selectedObject.identifier] else { return }

    let identifier = selectedObject.identifier
    let quarterTurns = ((rotationQuarterTurnsByID[identifier] ?? 0) + 1) % 4
    rotationQuarterTurnsByID[identifier] = quarterTurns

    var pose = Transform(matrix: selectedObject.transform)
    let yaw = simd_quatf(
        angle: Float(quarterTurns) * .pi / 2,
        axis: [0, 1, 0]
    )
    pose.rotation *= yaw
    replacement.transform = pose

    updateStatus()
}
