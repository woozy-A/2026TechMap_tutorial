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
