/*
The project-original Chair model was created procedurally for this tutorial
and is released under CC0-1.0. See Chair-LICENSE.md and Chair-SOURCE.md in the
source tree for provenance.

Abstract:
Starter-provided loading, fitting, and asset-axis correction support.
*/

import Combine
import Foundation
import RealityKit
import RoomPlan
import simd

enum FurnitureModelProviderError: LocalizedError {
    case assetMissing
    case emptyAsset
    case unsupportedCategory
    case invalidTargetDimensions
    case invalidBounds

    var errorDescription: String? {
        switch self {
        case .assetMissing:
            return "The bundled Chair.usdz resource could not be found."
        case .emptyAsset:
            return "The bundled Chair model did not produce a RealityKit entity."
        case .unsupportedCategory:
            return "A bundled 3D model is currently available only for chairs."
        case .invalidTargetDimensions:
            return "RoomPlan did not provide usable dimensions for this object."
        case .invalidBounds:
            return "The bundled Chair model does not contain usable geometry."
        }
    }
}

@MainActor
final class FurnitureModelProvider {
    private var templateByAssetName: [String: Entity] = [:]

    func makeModel(
        for category: CapturedRoom.Object.Category,
        fitting targetDimensions: SIMD3<Float>
    ) async throws -> Entity {
        guard category == .chair else {
            throw FurnitureModelProviderError.unsupportedCategory
        }
        guard targetDimensions.x.isFinite,
              targetDimensions.y.isFinite,
              targetDimensions.z.isFinite,
              targetDimensions.x > 0,
              targetDimensions.y > 0,
              targetDimensions.z > 0 else {
            throw FurnitureModelProviderError.invalidTargetDimensions
        }

        let asset = try await modelTemplate(named: "Chair").clone(recursive: true)
        let assetOrientationCorrection = simd_quatf(angle: 0, axis: [0, 1, 0])

        let assetAdjustmentRoot = Entity()
        let orientationRoot = Entity()
        orientationRoot.orientation = assetOrientationCorrection
        orientationRoot.addChild(asset)
        assetAdjustmentRoot.addChild(orientationRoot)

        let correctedBounds = assetAdjustmentRoot.visualBounds(
            recursive: true,
            relativeTo: assetAdjustmentRoot,
            excludeInactive: false
        )
        let sourceBounds = correctedBounds.extents
        guard sourceBounds.x.isFinite,
              sourceBounds.y.isFinite,
              sourceBounds.z.isFinite,
              sourceBounds.x > 0.0001,
              sourceBounds.y > 0.0001,
              sourceBounds.z > 0.0001 else {
            throw FurnitureModelProviderError.invalidBounds
        }

        let uniformScale = min(
            targetDimensions.x / sourceBounds.x,
            targetDimensions.y / sourceBounds.y,
            targetDimensions.z / sourceBounds.z
        )
        assetAdjustmentRoot.scale = SIMD3<Float>(repeating: uniformScale)
        assetAdjustmentRoot.position = SIMD3<Float>(
            -correctedBounds.center.x * uniformScale,
            -targetDimensions.y / 2 - correctedBounds.min.y * uniformScale,
            -correctedBounds.center.z * uniformScale
        )

        let placementRoot = Entity()
        placementRoot.name = "Chair Replacement"
        placementRoot.addChild(assetAdjustmentRoot)
        return placementRoot
    }

    private func modelTemplate(named assetName: String) async throws -> Entity {
        if let cachedTemplate = templateByAssetName[assetName] {
            return cachedTemplate
        }

        guard let assetURL = Bundle.main.url(
            forResource: assetName,
            withExtension: "usdz"
        ) else {
            throw FurnitureModelProviderError.assetMissing
        }

        var iterator = Entity.loadAsync(contentsOf: assetURL)
            .values
            .makeAsyncIterator()
        guard let template = try await iterator.next() else {
            throw FurnitureModelProviderError.emptyAsset
        }

        templateByAssetName[assetName] = template
        return template
    }
}
