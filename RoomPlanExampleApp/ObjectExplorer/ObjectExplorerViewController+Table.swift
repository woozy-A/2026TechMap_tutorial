/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Starter-provided UIKit list support for Object Explorer.
*/

import RoomPlan
import UIKit

extension ObjectExplorerViewController {
    func makeObjectSections(from objects: [CapturedRoom.Object]) -> [ObjectSection] {
        let groupedObjects = Dictionary(grouping: objects, by: \CapturedRoom.Object.category)
        return groupedObjects
            .map { ObjectSection(category: $0.key, objects: $0.value) }
            .sorted { $0.category.displayName < $1.category.displayName }
    }

    func refreshListSelection() {
        tableView.reloadData()

        guard let selectedObjectID,
              let selectedIndexPath = indexPath(for: selectedObjectID) else { return }

        tableView.selectRow(
            at: selectedIndexPath,
            animated: false,
            scrollPosition: .none
        )
    }

    func indexPath(for identifier: UUID) -> IndexPath? {
        for (sectionIndex, section) in objectSections.enumerated() {
            if let row = section.objects.firstIndex(where: {
                $0.identifier == identifier
            }) {
                return IndexPath(row: row, section: sectionIndex)
            }
        }
        return nil
    }

    func objectDisplayName(for identifier: UUID) -> String? {
        guard let indexPath = indexPath(for: identifier) else { return nil }
        let section = objectSections[indexPath.section]
        return "\(section.category.displayName) \(indexPath.row + 1)"
    }

}

extension ObjectExplorerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        objectSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        objectSections[section].objects.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = objectSections[section]
        return "\(section.category.displayName) (\(section.objects.count))"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath)
        let section = objectSections[indexPath.section]
        let object = section.objects[indexPath.row]
        let dimensions = object.dimensions

        var content = cell.defaultContentConfiguration()
        content.text = "\(section.category.displayName) \(indexPath.row + 1)"
        content.secondaryText = String(
            format: "%.2f × %.2f × %.2f m",
            dimensions.x,
            dimensions.y,
            dimensions.z
        )
        cell.contentConfiguration = content
        cell.accessoryType = object.identifier == selectedObjectID ? .checkmark : .none
        cell.accessibilityIdentifier = "object-\(object.identifier.uuidString)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = objectSections[indexPath.section].objects[indexPath.row]
        selectObject(object)
        updateHighlight()
        updateControls()
    }
}
