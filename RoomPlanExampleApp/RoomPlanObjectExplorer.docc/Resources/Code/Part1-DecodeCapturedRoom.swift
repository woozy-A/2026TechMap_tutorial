do {
    let roomData = try Data(contentsOf: roomURL)
    let capturedRoom = try JSONDecoder().decode(CapturedRoom.self, from: roomData)
    presentExplorer(with: capturedRoom)
} catch {
    print("Unable to load Room.json: \(error)")
    showAlert(title: "Sample Room Unavailable", message: "Room.json could not be decoded.")
}
