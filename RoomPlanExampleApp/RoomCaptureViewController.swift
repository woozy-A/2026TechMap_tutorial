/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The sample app's main view controller that manages the scanning process.
*/

import UIKit
import RoomPlan

class RoomCaptureViewController: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {

    @IBOutlet var doneButton: UIBarButtonItem?
    @IBOutlet var cancelButton: UIBarButtonItem?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    
    private var isScanning: Bool = false
    
    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up after loading the view.
        setupRoomCaptureView()
        activityIndicator?.stopAnimating()
    }
    
    private func setupRoomCaptureView() {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        
        view.insertSubview(roomCaptureView, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ flag: Bool) {
        super.viewWillDisappear(flag)
        stopSession()
    }
    
    private func startSession() {
        isScanning = true
        roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
        
        setActiveNavBar()
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
    
    // Access the final post-processed results.
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
    
    @IBAction func doneScanning(_ sender: UIBarButtonItem) {
        guard isScanning else { return }

        sender.isEnabled = false
        stopSession()
        self.activityIndicator?.startAnimating()
    }

    @IBAction func cancelScanning(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
    
    private func setActiveNavBar() {
        doneButton?.isEnabled = true

        self.cancelButton?.tintColor = .white
        self.doneButton?.tintColor = .white
    }

    private func setCompleteNavBar() {
        UIView.animate(withDuration: 1.0) {
            self.cancelButton?.tintColor = .systemBlue
            self.doneButton?.tintColor = .systemBlue
        }
    }
}
