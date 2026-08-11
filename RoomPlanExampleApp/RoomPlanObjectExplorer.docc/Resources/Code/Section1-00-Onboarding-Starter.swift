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
        // Part 1: Load Room.json, decode CapturedRoom, and call presentExplorer(with:).
        showAlert(
            title: "Start Part 1",
            message: "Load the Sample CapturedRoom before opening the Object Explorer."
        )
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
