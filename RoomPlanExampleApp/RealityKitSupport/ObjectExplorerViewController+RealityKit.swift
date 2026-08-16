/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Starter-provided non-AR RealityKit room context and camera framing.
*/

import RealityKit
import RoomPlan
import simd
import UIKit

extension ObjectExplorerViewController {
    func setupRealityView() {
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

    func renderRoomStructure(from capturedRoom: CapturedRoom) {
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

        addSurfaces(capturedRoom.walls, name: "Wall", thickness: 0.025, color: .systemGray2, opacity: 0.12)
        addSurfaces(capturedRoom.doors, name: "Door", thickness: 0.055, color: .systemOrange, opacity: 0.45)
        addSurfaces(capturedRoom.windows, name: "Window", thickness: 0.055, color: .systemBlue, opacity: 0.38)
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

    func boxMaterial(isSelected: Bool) -> UnlitMaterial {
        var material = UnlitMaterial(color: isSelected ? .systemPink : .systemTeal)
        if !isSelected {
            material.blending = .transparent(opacity: 0.15)
        }
        return material
    }

    func frameRoom() {
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
