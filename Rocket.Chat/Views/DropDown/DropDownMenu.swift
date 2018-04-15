//
//  DropDownMenu.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 15.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

@IBDesignable public class DropDownMenu: UIView {
    public var didSelectItem: ((_ index: Int) -> Void)?

    public var options = [String]() {
        didSet {
            reload()
        }
    }

    public var parentView: UIView {
        return (superview?.superview?.superview)! // TODO: set proper parentView
    }

    private var xPosition: CGFloat {
        return (parentView.frame.size.width - self.frame.size.width) / 2
    }

    private var yPosition: CGFloat {
        return (parentView.frame.size.height - menuHeight) / 2
    }

    public var menuHeight: CGFloat {
        return CGFloat(options.count) * rowHeight
    }

    @IBInspectable public var placeholder: String? {
        didSet {
            valueField.placeholder = placeholder
        }
    }

    @IBInspectable public var defaultValue: String? {
        didSet {
            valueField.text = defaultValue
        }
    }

    @IBInspectable public var textColor: UIColor = .black {
        didSet {
            valueField.textColor = textColor
        }
    }

    public var font: UIFont? {
        didSet {
            valueField.font = font
        }
    }

    private var valueField: UITextField!

    private lazy var dropDownTableView: UITableView = {
        let xPosition = (parentView.frame.size.width - self.frame.size.width) / 2
        let yPosition = (parentView.frame.size.height - menuHeight) / 2
        let frame = CGRect(x: xPosition, y: yPosition, width: self.frame.size.width, height: 0)

        let table = UITableView(frame: frame, style: .plain)
        table.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        table.dataSource = self
        table.delegate = self
        table.layer.borderColor = UIColor.lightGray.cgColor
        table.layer.borderWidth = 0.5

        parentView.addSubview(table)

        table.register(UITableViewCell.self, forCellReuseIdentifier: "dropDownCell")

        return table
    }()

    private let rowHeight: CGFloat = 20
    private var isShown = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        valueField = UITextField(frame: .zero)
        valueField.delegate = self
        addSubview(valueField)

        font = UIFont.systemFont(ofSize: 14)
    }

    @objc func showOrHide() {
        let xPosition = (parentView.frame.size.width - self.frame.size.width) / 2
        let yPosition = (parentView.frame.size.height - menuHeight) / 2

        if isShown {
            UIView.animate(withDuration: 0.3, animations: {
                self.dropDownTableView.frame = CGRect(x: xPosition, y: yPosition, width: self.frame.size.width, height: 0)
            }, completion: { _ in
                self.isShown = false
            })
        } else {
            dropDownTableView.reloadData()

            UIView.animate(withDuration: 0.3, animations: {
                self.dropDownTableView.frame = CGRect(x: xPosition, y: yPosition, width: self.frame.size.width, height: self.menuHeight)
            }, completion: { _ in
                self.isShown = true
            })
        }
    }

    func reload() {
        guard isShown else {
            return
        }

        let xPosition = (parentView.frame.size.width - self.frame.size.width) / 2
        let yPosition = (parentView.frame.size.height - menuHeight) / 2

        dropDownTableView.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.dropDownTableView.frame = CGRect(x: xPosition, y: yPosition, width: self.frame.size.width, height: self.menuHeight)
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        valueField.frame = CGRect(x: 0, y: 0, width: frame.size.width - 50, height: frame.size.height)
    }
}

extension DropDownMenu: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showOrHide()

        return false
    }
}

extension DropDownMenu: UITableViewDelegate, UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dropDownCell", for: indexPath)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        return cell
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = font
        cell.textLabel?.textColor = textColor
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        valueField.text = options[indexPath.row]
        didSelectItem?(indexPath.row)

        showOrHide()
    }
}
