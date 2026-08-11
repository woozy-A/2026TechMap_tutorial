objects = room.objects
let groupedObjects = Dictionary(grouping: objects) { object in
    object.category
}
objectSections = makeObjectSections(from: groupedObjects)

statusLabel.text = "\(objects.count) Objects Detected"
tableView.reloadData()
