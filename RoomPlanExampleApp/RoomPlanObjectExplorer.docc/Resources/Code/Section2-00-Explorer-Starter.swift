/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view controller that explores the objects in a CapturedRoom.
*/

import RealityKit
import RoomPlan
import simd
import UIKit

private struct ObjectSection {
    let category: CapturedRoom.Object.Category
    let objects: [CapturedRoom.Object]
}

final class ObjectExplorerViewController: UIViewController {
    // MARK: - Part 2 — Captured Objects

    // Empty tutorial state keeps the Starter buildable. Part 2 connects it to room.objects.
    private var objects: [CapturedRoom.Object] = []
    private var objectSections: [ObjectSection] = []

    private func loadObjects(from room: CapturedRoom) {
        // Part 2: Read room.objects, group with object.category, then refresh the list.
    }

    private func configureObjectCell(
        _ cell: UITableViewCell,
        for object: CapturedRoom.Object,
        number: Int
    ) {
        // Part 2: Read object.category and object.dimensions for the visible row.
    }

    // MARK: - Part 3 — Object Selection

    private func isObjectSelected(_ object: CapturedRoom.Object) -> Bool {
        // Part 3: Compare object.identifier with selectedObjectID.
        false
    }

    private func selectObject(at indexPath: IndexPath) {
        // Part 3: Store object.identifier, refresh the checkmark, and update the status.
    }

    // MARK: - Part 4 — 3D Visualization

    private func renderObjectBoxes() {
        // Part 4: Create one Entity from each object's dimensions and transform.
    }

    private func updateHighlight() {
        // Part 4: Use selectedObjectID to change the matching Entity material.
    }

    // MARK: - Starter-provided State and Lifecycle

    private var capturedRoom: CapturedRoom?

    private let statusLabel = UILabel()
    private let overviewContainerView = UIView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var arView: ARView!
    private let roomRoot = Entity()
    private let structureRoot = Entity()
    private let objectRoot = Entity()
    private let camera = PerspectiveCamera()

    func configure(with capturedRoom: CapturedRoom) {
        self.capturedRoom = capturedRoom
    }

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
            statusLabel.text = "Complete Part 1 to load a CapturedRoom."
            return
        }

        renderRoomStructure(from: capturedRoom)
        statusLabel.text = "Sample Room Loaded"

        // These hooks are intentionally empty in the Starter.
        loadObjects(from: capturedRoom)
        renderObjectBoxes()
        updateHighlight()
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

    // MARK: - Starter-provided List Support

    private func makeObjectSections(
        from groupedObjects: [CapturedRoom.Object.Category: [CapturedRoom.Object]]
    ) -> [ObjectSection] {
        groupedObjects
            .map { ObjectSection(category: $0.key, objects: $0.value) }
            .sorted { $0.category.displayName < $1.category.displayName }
    }

    private func applyObjectCellContent(
        _ cell: UITableViewCell,
        title: String,
        dimensions: SIMD3<Float>
    ) {
        var content = cell.defaultContentConfiguration()
        content.text = title
        content.secondaryText = String(
            format: "%.2f × %.2f × %.2f m",
            dimensions.x,
            dimensions.y,
            dimensions.z
        )
        cell.contentConfiguration = content
    }

    private func objectDisplayName(at indexPath: IndexPath) -> String {
        let section = objectSections[indexPath.section]
        return "\(section.category.displayName) \(indexPath.row + 1)"
    }

    private func indexPath(for object: CapturedRoom.Object) -> IndexPath? {
        for (sectionIndex, section) in objectSections.enumerated() {
            if let row = section.objects.firstIndex(where: {
                $0.identifier == object.identifier
            }) {
                return IndexPath(row: row, section: sectionIndex)
            }
        }
        return nil
    }

    private func refreshListSelection() {
        tableView.reloadData()

        guard let selectedObject = objects.first(where: isObjectSelected),
              let selectedIndexPath = indexPath(for: selectedObject) else {
            return
        }

        tableView.selectRow(
            at: selectedIndexPath,
            animated: false,
            scrollPosition: .none
        )
    }

    // MARK: - Starter-provided Interface

    private func setupInterface() {
        view.backgroundColor = .systemBackground

        statusLabel.font = .preferredFont(forTextStyle: .subheadline)
        statusLabel.textColor = .secondaryLabel
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.accessibilityIdentifier = "tutorialStatus"

        overviewContainerView.backgroundColor = .secondarySystemBackground
        overviewContainerView.layer.cornerRadius = 16
        overviewContainerView.clipsToBounds = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ObjectCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "objectList"

        let content = UIStackView(arrangedSubviews: [
            statusLabel,
            overviewContainerView,
            tableView
        ])
        content.axis = .vertical
        content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(content)

        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            overviewContainerView.heightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.heightAnchor,
                multiplier: 0.42
            )
        ])
    }

    // MARK: - Starter-provided RealityKit Support

    private func setupRealityView() {
        arView = ARView(
            frame: overviewContainerView.bounds,
            cameraMode: .nonAR,
            automaticallyConfigureSession: false
        )
        arView.environment.background = .color(.secondarySystemBackground)
        arView.translatesAutoresizingMaskIntoConstraints = false
        overviewContainerView.addSubview(arView)

        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: overviewContainerView.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: overviewContainerView.trailingAnchor),
            arView.topAnchor.constraint(equalTo: overviewContainerView.topAnchor),
            arView.bottomAnchor.constraint(equalTo: overviewContainerView.bottomAnchor)
        ])

        let roomAnchor = AnchorEntity(world: .zero)
        roomAnchor.addChild(roomRoot)
        roomRoot.addChild(structureRoot)
        roomRoot.addChild(objectRoot)
        arView.scene.addAnchor(roomAnchor)

        camera.camera = PerspectiveCameraComponent(
            near: 0.01,
            far: 100,
            fieldOfViewInDegrees: 50
        )
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
    }

    private func renderRoomStructure(from capturedRoom: CapturedRoom) {
        structureRoot.children.removeAll()

        if #available(iOS 17.0, *) {
            addSurfaces(
                capturedRoom.floors,
                name: "Floor",
                thickness: 0.025,
                color: .systemGray3,
                opacity: 0.10
            )
        }

        addSurfaces(
            capturedRoom.walls,
            name: "Wall",
            thickness: 0.025,
            color: .systemGray2,
            opacity: 0.12
        )
        addSurfaces(
            capturedRoom.doors,
            name: "Door",
            thickness: 0.055,
            color: .systemOrange,
            opacity: 0.45
        )
        addSurfaces(
            capturedRoom.windows,
            name: "Window",
            thickness: 0.055,
            color: .systemBlue,
            opacity: 0.38
        )
    }

    private func addSurfaces(
        _ surfaces: [CapturedRoom.Surface],
        name: String,
        thickness: Float,
        color: UIColor,
        opacity: Float
    ) {
        let material = surfaceMaterial(color: color, opacity: opacity)

        for (index, surface) in surfaces.enumerated() {
            let size = SIMD3<Float>(
                max(surface.dimensions.x, 0.01),
                max(surface.dimensions.y, 0.01),
                thickness
            )
            let entity = ModelEntity(
                mesh: .generateBox(size: size),
                materials: [material]
            )
            entity.name = "\(name) \(index + 1)"
            entity.transform = Transform(matrix: surface.transform)
            structureRoot.addChild(entity)
        }
    }

    private func surfaceMaterial(color: UIColor, opacity: Float) -> UnlitMaterial {
        var material = UnlitMaterial(color: color)
        material.blending = .transparent(opacity: .init(scale: opacity))
        return material
    }

    private func boxMaterial(isSelected: Bool) -> UnlitMaterial {
        var material = UnlitMaterial(color: isSelected ? .systemYellow : .systemTeal)
        if !isSelected {
            material.blending = .transparent(opacity: 0.15)
        }
        return material
    }

    private func frameRoom() {
        guard arView != nil, arView.bounds.width > 0, arView.bounds.height > 0 else {
            return
        }

        let bounds = roomRoot.visualBounds(recursive: true, relativeTo: nil)
        guard !bounds.isEmpty else { return }

        let verticalFOV = camera.camera.fieldOfViewInDegrees * Float.pi / 180
        let aspect = Float(arView.bounds.width / arView.bounds.height)
        let horizontalFOV = 2 * atan(tan(verticalFOV / 2) * aspect)
        let limitingFOV = min(verticalFOV, horizontalFOV)
        let radius = max(bounds.boundingRadius, 0.5)
        let distance = radius / sin(limitingFOV / 2) * 1.05
        let direction = simd_normalize(SIMD3<Float>(0.7, 2.4, 1))

        camera.look(
            at: bounds.center,
            from: bounds.center + direction * distance,
            relativeTo: nil
        )
    }
}

// MARK: - Starter-provided Table Wiring

extension ObjectExplorerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        objectSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        objectSections[section].objects.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let objectSection = objectSections[section]
        return "\(objectSection.category.displayName) (\(objectSection.objects.count))"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath)
        let object = objectSections[indexPath.section].objects[indexPath.row]

        configureObjectCell(cell, for: object, number: indexPath.row + 1)
        cell.accessoryType = isObjectSelected(object) ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectObject(at: indexPath)
        updateHighlight()
    }
}

private extension CapturedRoom.Object.Category {
    var displayName: String {
        switch self {
        case .storage: return "Storage"
        case .refrigerator: return "Refrigerator"
        case .stove: return "Stove"
        case .bed: return "Bed"
        case .sink: return "Sink"
        case .washerDryer: return "Washer/Dryer"
        case .toilet: return "Toilet"
        case .bathtub: return "Bathtub"
        case .oven: return "Oven"
        case .dishwasher: return "Dishwasher"
        case .table: return "Table"
        case .sofa: return "Sofa"
        case .chair: return "Chair"
        case .fireplace: return "Fireplace"
        case .television: return "Television"
        case .stairs: return "Stairs"
        @unknown default: return "Object"
        }
    }
}
