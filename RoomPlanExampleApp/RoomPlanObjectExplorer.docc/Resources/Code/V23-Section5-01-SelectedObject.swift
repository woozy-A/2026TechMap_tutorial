/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The learner-facing RoomPlan object exploration flow.
*/

import RealityKit
import RoomPlan
import simd
import UIKit

final class ObjectExplorerViewController: UIViewController {
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

    // MARK: - Tutorial — Selection

    var selectedObjectID: UUID?

    func selectObject(_ object: CapturedRoom.Object) {
        selectedObjectID = object.identifier
        refreshListSelection()
        updateHighlight()
        updateControls()
        updateStatus()
    }

    // MARK: - Tutorial — Visualize Objects

    var boxEntityByID: [UUID: ModelEntity] = [:]
    var displayedEntityByID: [UUID: Entity] = [:]

    func renderObjectBoxes() {
        objectRoot.children.removeAll()
        boxEntityByID.removeAll()
        displayedEntityByID.removeAll()

        for object in objects {
            let mesh = MeshResource.generateBox(size: object.dimensions)
            let box = ModelEntity(
                mesh: mesh,
                materials: [boxMaterial(isSelected: false)]
            )
            box.name = object.identifier.uuidString
            box.transform = Transform(matrix: object.transform)

            objectRoot.addChild(box)
            boxEntityByID[object.identifier] = box
            displayedEntityByID[object.identifier] = box
        }
    }

    func updateHighlight() {
        for (identifier, box) in boxEntityByID {
            box.model?.materials = [
                boxMaterial(isSelected: identifier == selectedObjectID)
            ]
        }
    }

    // MARK: - Tutorial — Replace with 3D Model

    var selectedObject: CapturedRoom.Object? {
        guard let selectedObjectID else { return nil }
        return objects.first { $0.identifier == selectedObjectID }
    }

    var canReplaceSelectedObject: Bool {
        guard let selectedObject else { return false }
        return selectedObject.category == .chair
            && !replacedObjectIDs.contains(selectedObject.identifier)
    }

    func replaceSelectedObject() async throws {
        // Part 5: Fit with dimensions, place with transform, and replace by ID.
    }

    // MARK: - Tutorial — Rotate the 3D Model

    var canRotateSelectedObject: Bool {
        // Part 6: Allow rotation only after a replacement Entity exists.
        false
    }

    func rotateSelectedObject() {
        // Part 6: Add a local Y-axis rotation to the scanned transform.
    }

    // MARK: - Starter-provided State

    var objectSections: [ObjectSection] = []
    var replacedObjectIDs: Set<UUID> = []
    var rotationQuarterTurnsByID: [UUID: Int] = [:]
    var replacementTask: Task<Void, Never>?
    var isReplacingModel = false
    let furnitureModelProvider = FurnitureModelProvider()

    let statusLabel = UILabel()
    let overviewContainerView = UIView()
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let actionStackView = UIStackView()
    let replaceModelButton = UIButton(type: .system)
    let rotateModelButton = UIButton(type: .system)

    var arView: ARView!
    let roomRoot = Entity()
    let structureRoot = Entity()
    let objectRoot = Entity()
    let camera = PerspectiveCamera()

    // MARK: - Starter-provided Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Object Explorer"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            }
        )

        setupInterface()
        setupRealityView()

        guard let capturedRoom else {
            statusLabel.text = "CapturedRoom is unavailable."
            return
        }

        renderRoomStructure(from: capturedRoom)
        loadObjects(from: capturedRoom)
        renderObjectBoxes()
        updateHighlight()
        updateControls()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overviewContainerView.layoutIfNeeded()
        frameRoom()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        overviewContainerView.layoutIfNeeded()
        frameRoom()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        replacementTask?.cancel()
    }
}
