    // MARK: - Tutorial — Get a CapturedRoom

    @IBAction func showSampleRoom(_ sender: UIButton) {
        do {
            guard let roomURL = Bundle.main.url(forResource: "Room", withExtension: "json") else {
                throw SampleRoomError.resourceMissing
            }

            let roomData = try Data(contentsOf: roomURL)
            let capturedRoom = try JSONDecoder().decode(CapturedRoom.self, from: roomData)
            presentExplorer(with: capturedRoom)
        } catch {
            print("Unable to load Room.json: \(error)")
            showAlert(
                title: "Sample Room Unavailable",
                message: "Room.json could not be loaded. Check the Xcode console for the decoding error."
            )
        }
    }
