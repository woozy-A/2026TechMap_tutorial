/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view controller for the app's first screen that explains what to do.
*/

import RoomPlan
import UIKit

class OnboardingViewController: UIViewController {
    // MARK: - Part 1 — Get a CapturedRoom

    @IBAction func showSampleRoom(_ sender: UIButton) {
        guard let roomURL = Bundle.main.url(
            forResource: "Room",
            withExtension: "json"
        ) else {
            showAlert(title: "Sample Room Unavailable", message: "Room.json is missing.")
            return
        }

        do {
            let roomData = try Data(contentsOf: roomURL)
            let capturedRoom = try JSONDecoder().decode(CapturedRoom.self, from: roomData)
            presentExplorer(with: capturedRoom)
        } catch {
            print("Unable to load Room.json: \(error)")
            showAlert(title: "Sample Room Unavailable", message: "Room.json could not be decoded.")
        }
    }

    // MARK: - Starter-provided Navigation and Error Handling

    @IBAction func startScan(_ sender: UIButton) {
        guard RoomCaptureSession.isSupported else {
            showAlert(
                title: "LiDAR Required",
                message: "Scan Your Own Room requires a LiDAR-equipped iPhone or iPad. You can still explore the Sample Room."
            )
            return
        }

        if let viewController = self.storyboard?.instantiateViewController(
            withIdentifier: "RoomCaptureViewNavigationController") {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }

    private func presentExplorer(with capturedRoom: CapturedRoom) {
        guard let explorer = storyboard?.instantiateViewController(
            withIdentifier: "ObjectExplorerViewController"
        ) as? ObjectExplorerViewController else {
            showAlert(title: "Unable to Open Explorer", message: "The Explorer scene is not configured.")
            return
        }

        explorer.configure(with: capturedRoom)

        let navigationController = UINavigationController(rootViewController: explorer)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
