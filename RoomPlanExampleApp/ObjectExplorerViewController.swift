/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view controller that explores the objects in a CapturedRoom.
*/

import RealityKit
import RoomPlan
import simd
import UIKit

final class ObjectExplorerViewController: UIViewController {
    private struct ObjectItem {
        let object: CapturedRoom.Object
        var editedCategory: CapturedRoom.Object.Category

        var id: UUID { object.identifier }
    }

    private struct ObjectSection {
        let category: CapturedRoom.Object.Category
        let items: [ObjectItem]
    }

    private static let editableCategories: [CapturedRoom.Object.Category] = [
        .bed, .chair, .table, .storage
    ]

    private var capturedRoom: CapturedRoom?
    private var visibleItems: [ObjectItem] = []
    private var selectedObjectID: UUID?

    private var sections: [ObjectSection] {
        Dictionary(grouping: visibleItems, by: \.editedCategory)
            .map { ObjectSection(category: $0.key, items: $0.value) }
            .sorted { $0.category.displayName < $1.category.displayName }
    }

    private let statusLabel = UILabel()
    private let overviewContainerView = UIView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let categoryButton = UIButton(type: .system)
    private let removeButton = UIButton(type: .system)

    private var arView: ARView!
    private let roomRoot = Entity()
    private let structureRoot = Entity()
    private let objectRoot = Entity()
    private let camera = PerspectiveCamera()
    private var entityByID: [UUID: ModelEntity] = [:]

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

        guard let capturedRoom else {
            statusLabel.text = "CapturedRoom is unavailable."
            return
        }

        // STUDY: Keep the immutable RoomPlan object and the app's editable category together.
        visibleItems = capturedRoom.objects.map {
            ObjectItem(object: $0, editedCategory: $0.category)
        }

        setupRealityView()
        renderRoomStructure(from: capturedRoom)
        renderBoxes()
        refreshInterface()
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

    // STUDY: Layout and RealityKit setup are Starter-provided so the tutorial can focus on RoomPlan data.
    private func setupInterface() {
        view.backgroundColor = .systemBackground

        statusLabel.font = .preferredFont(forTextStyle: .subheadline)
        statusLabel.textColor = .secondaryLabel
        statusLabel.adjustsFontForContentSizeCategory = true

        overviewContainerView.backgroundColor = .secondarySystemBackground
        overviewContainerView.layer.cornerRadius = 16
        overviewContainerView.clipsToBounds = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ObjectCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "objectList"

        var categoryConfiguration = UIButton.Configuration.tinted()
        categoryConfiguration.title = "Change Category"
        categoryButton.configuration = categoryConfiguration
        categoryButton.isEnabled = false
        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.accessibilityIdentifier = "categoryButton"

        var removeConfiguration = UIButton.Configuration.filled()
        removeConfiguration.title = "Remove"
        removeConfiguration.baseBackgroundColor = .systemRed
        removeButton.configuration = removeConfiguration
        removeButton.isEnabled = false
        removeButton.accessibilityIdentifier = "removeButton"
        removeButton.addAction(
            UIAction { [weak self] _ in self?.removeSelectedObject() },
            for: .touchUpInside
        )

        let controls = UIStackView(arrangedSubviews: [categoryButton, removeButton])
        controls.axis = .horizontal
        controls.distribution = .fillEqually
        controls.spacing = 12

        let content = UIStackView(arrangedSubviews: [
            statusLabel,
            overviewContainerView,
            tableView,
            controls
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
            overviewContainerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.38),
            controls.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

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

    // STUDY: Room surfaces are Starter-provided context; learners focus on object data below.
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

    private func renderBoxes() {
        objectRoot.children.removeAll()
        entityByID.removeAll()

        for item in visibleItems {
            // STUDY: dimensions creates the box size; transform supplies its room-space pose.
            let mesh = MeshResource.generateBox(size: item.object.dimensions)
            let entity = ModelEntity(mesh: mesh, materials: [boxMaterial(isSelected: false)])
            entity.name = item.id.uuidString
            entity.transform = Transform(matrix: item.object.transform)
            objectRoot.addChild(entity)
            entityByID[item.id] = entity
        }
    }

    private func refreshInterface() {
        tableView.reloadData()

        if let selectedObjectID, let selectedIndexPath = indexPath(for: selectedObjectID) {
            tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
        }

        updateHighlight()
        updateControls()
        updateStatus()
    }

    private func updateHighlight() {
        for (id, entity) in entityByID {
            entity.model?.materials = [boxMaterial(isSelected: id == selectedObjectID)]
        }
    }

    private func updateControls() {
        let hasSelection = selectedObjectID != nil
        categoryButton.isEnabled = hasSelection
        removeButton.isEnabled = hasSelection
        categoryButton.menu = hasSelection ? makeCategoryMenu() : nil
    }

    private func updateStatus() {
        guard let selectedObjectID,
              let selectedName = displayName(for: selectedObjectID) else {
            statusLabel.text = "\(visibleItems.count) Objects Detected"
            return
        }

        statusLabel.text = "\(selectedName) Selected"
    }

    private func makeCategoryMenu() -> UIMenu {
        let currentCategory = selectedObjectID.flatMap { selectedID in
            visibleItems.first { $0.id == selectedID }?.editedCategory
        }

        let actions = Self.editableCategories.map { category in
            UIAction(
                title: category.displayName,
                state: category == currentCategory ? .on : .off
            ) { [weak self] _ in
                self?.changeSelectedCategory(to: category)
            }
        }

        return UIMenu(title: "Correct Category", children: actions)
    }

    private func changeSelectedCategory(to category: CapturedRoom.Object.Category) {
        guard let selectedObjectID,
              let itemIndex = visibleItems.firstIndex(where: { $0.id == selectedObjectID }),
              visibleItems[itemIndex].editedCategory != category else { return }

        // Move the corrected item to the end of its new category, then derive fresh display numbers.
        var item = visibleItems.remove(at: itemIndex)
        item.editedCategory = category
        visibleItems.append(item)

        refreshInterface()
    }

    private func removeSelectedObject() {
        guard let selectedObjectID,
              let itemIndex = visibleItems.firstIndex(where: { $0.id == selectedObjectID }) else { return }

        visibleItems.remove(at: itemIndex)
        entityByID.removeValue(forKey: selectedObjectID)?.removeFromParent()
        self.selectedObjectID = nil

        refreshInterface()
        frameRoom()
    }

    private func indexPath(for id: UUID) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            if let row = section.items.firstIndex(where: { $0.id == id }) {
                return IndexPath(row: row, section: sectionIndex)
            }
        }
        return nil
    }

    private func displayName(for id: UUID) -> String? {
        guard let indexPath = indexPath(for: id) else { return nil }
        let section = sections[indexPath.section]
        return "\(section.category.displayName) \(indexPath.row + 1)"
    }

    private func boxMaterial(isSelected: Bool) -> UnlitMaterial {
        var material = UnlitMaterial(color: isSelected ? .systemYellow : .systemTeal)
        if !isSelected {
            material.blending = .transparent(opacity: 0.15)
        }
        return material
    }

    // Camera framing is Starter-provided RealityKit boilerplate, not a RoomPlan learning step.
    private func frameRoom() {
        guard arView != nil, arView.bounds.width > 0, arView.bounds.height > 0 else { return }

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

extension ObjectExplorerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let objectSection = sections[section]
        return "\(objectSection.category.displayName) (\(objectSection.items.count))"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath)
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        let dimensions = item.object.dimensions

        var content = cell.defaultContentConfiguration()
        content.text = "\(section.category.displayName) \(indexPath.row + 1)"
        content.secondaryText = String(
            format: "%.2f × %.2f × %.2f m",
            dimensions.x,
            dimensions.y,
            dimensions.z
        )
        cell.contentConfiguration = content
        cell.accessoryType = item.id == selectedObjectID ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedObjectID = sections[indexPath.section].items[indexPath.row].id
        refreshInterface()
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
