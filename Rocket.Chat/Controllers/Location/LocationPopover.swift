//
//  LocationPopover.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 29/01/2019.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

class MyCustomButton: UIButton {

    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.init(displayP3Red: 240/255, green: 240/255, blue: 240/255, alpha: 0.8) : UIColor.clear
        }
    }
}

class LocationPopover: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var spinnerWidth: NSLayoutConstraint!
    @IBOutlet weak var spinnerLeading: NSLayoutConstraint!
    @IBOutlet weak var sendLocationButton: MyCustomButton!

    weak var locationViewController: LocationViewController?
    var address: Address?

    override func viewDidLoad() {
        super.viewDidLoad()

        acceptButton.setTitle(localized("location.send_location"), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        spinner.startAnimating()
        setup(for: nil, stopLoad: false)

    }

    func setup(for address: Address?, stopLoad: Bool = true) {
        self.address = address
        addressLabel.text = address?.shortAddress ?? localized("location.loading")

        if stopLoad {
            spinner.stopAnimating()
            spinnerWidth.constant = 0
            spinnerLeading.constant = 0
            spinner.isHidden = true
        }

        let minWidth = acceptButton.frame.size.width + 24

        var calculatedWidth = estimateFrameForText(width: 500, text: addressLabel.text ?? "", font: UIFont.systemFont(ofSize: 13.0)).width
        if !stopLoad {
            calculatedWidth = 220
        } else {
            calculatedWidth = (calculatedWidth < minWidth) ? minWidth : calculatedWidth + 20
        }

        self.preferredContentSize = CGSize(width: calculatedWidth + 20, height: 49)
    }

    @IBAction func acceptPressed(_ sender: Any) {
        locationViewController?.locationSelected(address: address)
    }
}

func estimateFrameForText(width: CGFloat, text: String, font: UIFont) -> CGRect {
    let size = CGSize(width: width, height: 30)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
}
