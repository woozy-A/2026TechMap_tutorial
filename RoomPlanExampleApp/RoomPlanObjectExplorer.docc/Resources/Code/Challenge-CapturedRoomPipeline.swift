    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        self.activityIndicator?.stopAnimating()

        if let error {
            print("RoomPlan processing warning: \(error)")
        }

        guard let explorer = storyboard?.instantiateViewController(
            withIdentifier: "ObjectExplorerViewController"
        ) as? ObjectExplorerViewController else {
            print("ObjectExplorerViewController is not configured in Main.storyboard.")
            return
        }

        // STUDY: Live Scan joins the same pipeline as Room.json once CapturedRoom exists.
        explorer.configure(with: processedResult)
        navigationController?.setViewControllers([explorer], animated: true)
    }
