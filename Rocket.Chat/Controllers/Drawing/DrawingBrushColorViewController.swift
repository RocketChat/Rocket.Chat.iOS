//
//  DrawingBrushColorViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 11.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class DrawingBrushColorViewController: UIViewController {
    weak var delegate: DrawingBrushColorDelegate?
    private let viewModel = DrawingBrushColorViewModel()

    private var color = UIColor.black

    func setCurrentColor(_ color: UIColor) {
        self.color = color
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
