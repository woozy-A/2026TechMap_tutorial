private func isObjectSelected(_ object: CapturedRoom.Object) -> Bool {
    object.identifier == selectedObjectID
}

private func selectObject(at indexPath: IndexPath) {
    let object = objectSections[indexPath.section].objects[indexPath.row]
    selectedObjectID = object.identifier

    refreshListSelection()
    statusLabel.text = "\(objectDisplayName(at: indexPath)) Selected"
}
