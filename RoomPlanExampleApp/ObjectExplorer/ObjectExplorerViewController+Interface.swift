/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Starter-provided layout, actions, and status support for Object Explorer.
*/

import UIKit

extension ObjectExplorerViewController {
    func setupInterface() {
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

        configureReplaceButton()
        actionStackView.addArrangedSubview(replaceModelButton)
        configureRotateButton()
        actionStackView.addArrangedSubview(rotateModelButton)
        actionStackView.axis = .vertical
        actionStackView.spacing = 8

        let content = UIStackView(arrangedSubviews: [
            statusLabel,
            overviewContainerView,
            tableView,
            actionStackView
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
                multiplier: 0.34
            )
        ])
    }

    private func configureReplaceButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Replace with 3D Chair"
        replaceModelButton.configuration = configuration
        replaceModelButton.accessibilityIdentifier = "replaceModelButton"
        replaceModelButton.addAction(
            UIAction { [weak self] _ in
                guard let self, replacementTask == nil else { return }
                replacementTask = Task { @MainActor [weak self] in
                    guard let self else { return }
                    defer { replacementTask = nil }
                    await runModelReplacement()
                }
            },
            for: .touchUpInside
        )
    }

    private func configureRotateButton() {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "Rotate 90°"
        rotateModelButton.configuration = configuration
        rotateModelButton.isHidden = true
        rotateModelButton.accessibilityIdentifier = "rotateModelButton"
        rotateModelButton.addAction(
            UIAction { [weak self] _ in
                self?.rotateSelectedObject()
            },
            for: .touchUpInside
        )
    }

    private func runModelReplacement() async {
        guard !isReplacingModel else { return }

        let requestedObjectID = selectedObjectID
        isReplacingModel = true
        updateControls()

        defer {
            isReplacingModel = false
            updateControls()
        }

        do {
            try await replaceSelectedObject()
        } catch is CancellationError {
            return
        } catch {
            if selectedObjectID == requestedObjectID {
                presentModelReplacementError(error)
            }
        }
    }

    func updateControls() {
        replaceModelButton.isEnabled = canReplaceSelectedObject && !isReplacingModel
        rotateModelButton.isHidden = !canRotateSelectedObject
        rotateModelButton.isEnabled = canRotateSelectedObject && !isReplacingModel
    }

    func updateStatus() {
        guard let selectedObjectID,
              let selectedName = objectDisplayName(for: selectedObjectID) else {
            statusLabel.text = "\(objects.count) Objects Detected"
            return
        }

        if let quarterTurns = rotationQuarterTurnsByID[selectedObjectID],
           quarterTurns > 0 {
            statusLabel.text = "\(selectedName) Rotated \(quarterTurns * 90)°"
        } else if replacedObjectIDs.contains(selectedObjectID) {
            statusLabel.text = "\(selectedName) Replaced with 3D Chair"
        } else {
            statusLabel.text = "\(selectedName) Selected"
        }
    }

    func presentModelReplacementError(_ error: Error) {
        let alert = UIAlertController(
            title: "Unable to Replace Object",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
