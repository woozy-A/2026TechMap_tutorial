    // MARK: - Tutorial — Explore Objects

    private var capturedRoom: CapturedRoom?
    var objects: [CapturedRoom.Object] = []

    func configure(with capturedRoom: CapturedRoom) {
        self.capturedRoom = capturedRoom
    }

    func loadObjects(from room: CapturedRoom) {
        objects = room.objects
        objectSections = makeObjectSections(from: objects)
        statusLabel.text = "\(objects.count) Objects Detected"
        tableView.reloadData()
    }

    func configureObjectCell(
        _ cell: UITableViewCell,
        for object: CapturedRoom.Object,
        number: Int
    ) {
        let dimensions = object.dimensions
        var content = cell.defaultContentConfiguration()
        content.text = "\(object.category.displayName) \(number)"
        content.secondaryText = String(
            format: "%.2f × %.2f × %.2f m",
            dimensions.x,
            dimensions.y,
            dimensions.z
        )
        cell.contentConfiguration = content
    }
