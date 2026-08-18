/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Small presentation types used by Object Explorer.
*/

import RoomPlan

struct ObjectSection {
    let category: CapturedRoom.Object.Category
    let objects: [CapturedRoom.Object]
}

struct FurnitureAsset {
    let resourceName: String
    var yawCorrectionDegrees: Float = 0
}

extension CapturedRoom.Object.Category {
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
