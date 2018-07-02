//
//  DrawingBrushColorViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 11.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class DrawingBrushColorViewController: BaseViewController {
    weak var delegate: DrawingBrushColorDelegate?
    private let viewModel = DrawingBrushColorViewModel()
    @IBOutlet private weak var colorPreview: UIView! {
        didSet {
            colorPreview.backgroundColor = color
        }
    }
    @IBOutlet private weak var colorPickerView: ColorPickerView! {
        didSet {
            colorPickerView.delegate = self
        }
    }
    @IBOutlet private weak var selectedColorLabel: UILabel! {
        didSet {
            selectedColorLabel.text = viewModel.selectedColorLabel
        }
    }
    @IBOutlet private weak var othersLabel: UILabel! {
        didSet {
            othersLabel.text = viewModel.othersLabel
        }
    }

    private var color = UIColor.black {
        didSet {
            if colorPreview != nil {
                colorPreview.backgroundColor = color
            }
            delegate?.brushColorPicked(color: color)
        }
    }

    func setCurrentColor(_ color: UIColor) {
        self.color = color
    }
}

extension DrawingBrushColorViewController: ColorPickerDelegate {
    func colorPicker(_ picker: ColorPickerView, didPick color: UIColor) {
        self.color = color
    }
}

extension DrawingBrushColorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.availableColors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellIdentifier, for: indexPath)

        let color = viewModel.availableColors[indexPath.row]
        cell.contentView.backgroundColor = color

        return cell
    }
}

extension DrawingBrushColorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.brushColorPicked(color: viewModel.availableColors[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}
