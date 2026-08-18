/*
Abstract:
Starter-provided loading, fitting, and asset-axis correction support for a
USDZ file that the learner adds to the app target.
*/

import Combine
import Foundation
import RealityKit
import RoomPlan
import simd

enum FurnitureModelProviderError: LocalizedError {
    case assetMissing(String)
    case emptyAsset(String)
    case invalidTargetDimensions
    case invalidBounds(String)

    var errorDescription: String? {
        switch self {
        case .assetMissing(let name):
            return "The \(name).usdz resource could not be found in the app bundle."
        case .emptyAsset(let name):
            return "The \(name).usdz resource did not produce a RealityKit entity."
        case .invalidTargetDimensions:
            return "RoomPlan did not provide usable dimensions for this object."
        case .invalidBounds(let name):
            return "The \(name).usdz resource does not contain usable geometry."
        }
    }
}

@MainActor
final class FurnitureModelProvider {
    private var templateByAssetName: [String: Entity] = [:]

    func makeModel(
        _ furnitureAsset: FurnitureAsset,
        fitting targetDimensions: SIMD3<Float>
    ) async throws -> Entity {
        try Task.checkCancellation()

        guard targetDimensions.x.isFinite,
              targetDimensions.y.isFinite,
              targetDimensions.z.isFinite,
              targetDimensions.x > 0,
              targetDimensions.y > 0,
              targetDimensions.z > 0 else {
            throw FurnitureModelProviderError.invalidTargetDimensions
        }

        let assetName = furnitureAsset.resourceName
        let asset = try await modelTemplate(named: assetName).clone(recursive: true)
        try Task.checkCancellation()
        let correctionRadians = furnitureAsset.yawCorrectionDegrees * .pi / 180
        let assetOrientationCorrection = simd_quatf(
            angle: correctionRadians,
            axis: [0, 1, 0]
        )

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
            throw FurnitureModelProviderError.invalidBounds(assetName)
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
        placementRoot.name = "\(assetName) Replacement"
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
            throw FurnitureModelProviderError.assetMissing(assetName)
        }

        var iterator = Entity.loadAsync(contentsOf: assetURL)
            .values
            .makeAsyncIterator()
        guard let template = try await iterator.next() else {
            throw FurnitureModelProviderError.emptyAsset(assetName)
        }

        templateByAssetName[assetName] = template
        return template
    }
}
