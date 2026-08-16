    // MARK: - Tutorial — Selection

    var selectedObjectID: UUID?

    func selectObject(_ object: CapturedRoom.Object) {
        selectedObjectID = object.identifier
        refreshListSelection()
        updateStatus()
    }

    // MARK: - Tutorial — Visualize Objects
