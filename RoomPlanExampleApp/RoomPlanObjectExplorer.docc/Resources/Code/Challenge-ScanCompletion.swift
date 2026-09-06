    @IBAction func doneScanning(_ sender: UIBarButtonItem) {
        guard isScanning else { return }

        sender.isEnabled = false
        stopSession()
        self.activityIndicator?.startAnimating()
    }

    private func stopSession() {
        isScanning = false
        roomCaptureView?.captureSession.stop()

        setCompleteNavBar()
    }

    // Decide to post-process and show the final results.
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }
