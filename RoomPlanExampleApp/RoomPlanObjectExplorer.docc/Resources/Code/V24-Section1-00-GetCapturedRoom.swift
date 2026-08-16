    // MARK: - Tutorial — Get a CapturedRoom

    @IBAction func showSampleRoom(_ sender: UIButton) {
        // Part 1: Decode the supplied Room.json as CapturedRoom, then call
        // presentExplorer(with:). The Starter remains safe to run before that.
        showAlert(
            title: "Start Part 1",
            message: "Load the supplied Room.json as a CapturedRoom."
        )
    }
