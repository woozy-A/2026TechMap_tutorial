private struct ObjectItem {
    let object: CapturedRoom.Object
    var editedCategory: CapturedRoom.Object.Category

    var id: UUID { object.identifier }
}
