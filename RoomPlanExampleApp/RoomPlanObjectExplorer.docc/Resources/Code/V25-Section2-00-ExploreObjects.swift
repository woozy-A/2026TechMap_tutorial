    // MARK: - Tutorial — Explore Objects

    private var capturedRoom: CapturedRoom?
    var objects: [CapturedRoom.Object] = []

    func configure(with capturedRoom: CapturedRoom) {
        self.capturedRoom = capturedRoom
    }

    func loadObjects(from room: CapturedRoom) {
        // Part 2: Read room.objects and refresh the supplied table UI.
        statusLabel.text = "Sample Room Loaded"
    }

    func configureObjectCell(
        _ cell: UITableViewCell,
        for object: CapturedRoom.Object,
        number: Int
    ) {
        // Part 2: Show object.category and object.dimensions in the supplied cell.
    }
