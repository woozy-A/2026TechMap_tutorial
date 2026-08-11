private func updateHighlight() {
    for (identifier, entity) in entityByID {
        let isSelected = identifier == selectedObjectID
        entity.model?.materials = [boxMaterial(isSelected: isSelected)]
    }
}
