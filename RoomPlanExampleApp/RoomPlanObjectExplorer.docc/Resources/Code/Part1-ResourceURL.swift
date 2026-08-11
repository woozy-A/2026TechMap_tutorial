guard let roomURL = Bundle.main.url(
    forResource: "Room",
    withExtension: "json"
) else {
    showAlert(title: "Sample Room Unavailable", message: "Room.json is missing.")
    return
}
