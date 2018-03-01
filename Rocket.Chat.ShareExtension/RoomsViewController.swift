//
//  RoomsViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Social

class RoomsViewController: UIViewController {
    let model = RoomsViewModel(sections: [
        RoomsSection(type: .favorites, roomCells: [
            RoomCell(title: "@matheus.cardoso"),
            RoomCell(title: "#general"),
            RoomCell(title: "#important")
        ]),
        RoomsSection(type: .channels, roomCells: [
            RoomCell(title: "#general")
        ]),
        RoomsSection(type: .groups, roomCells: [
            RoomCell(title: "#ios-dev-internal"),
            RoomCell(title: "#important")
        ]),
        RoomsSection(type: .directMessages, roomCells: [
            RoomCell(title: "@matheus.cardoso"),
            RoomCell(title: "@rafael.kellermann"),
            RoomCell(title: "@filipe.alvarenga"),
            RoomCell(title: "@rocket.chat")
        ])
    ])

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
}

extension RoomsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = model.cellForRowAt(indexPath)

        let cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCellDefault")

        cell.textLabel?.text = room.title

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.titleForHeaderInSection(section)
    }
}
