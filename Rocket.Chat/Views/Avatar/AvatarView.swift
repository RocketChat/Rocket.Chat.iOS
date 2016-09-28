//
//  AvatarView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/09/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

let avatarColors: [UInt] = [
    0xF44336, 0xE91E63, 0x9C27B0, 0x673AB7, 0x3F51B5,
    0x2196F3, 0x03A9F4, 0x00BCD4, 0x009688, 0x4CAF50,
    0x8BC34A, 0xCDDC39, 0xFFC107, 0xFF9800, 0xFF5722,
    0x795548, 0x9E9E9E, 0x607D8B]

class AvatarView: UIView {
    
    var user: User! {
        didSet {
            updateAvatar()
        }
    }
    
    @IBOutlet weak var labelInitials: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private func userAvatarURL() -> URL? {
        guard let username = user.username else { return nil }
        guard let auth = AuthManager.isAuthenticated() else { return nil }
        guard let serverURL = NSURL(string: auth.serverURL) else { return nil }
        return URL(string: "http://\(serverURL.host!)/avatar/\(username).jpg")!
    }
    
    private func updateAvatar() {
        if let imageURL = userAvatarURL() {
            imageView.sd_setImage(with: imageURL, completed: { [unowned self] (image, error, cache, url) in
                if error != nil {
                    self.setAvatarWithInitials()
                } else {
                    self.labelInitials.text = ""
                }
            })
        } else {
            setAvatarWithInitials()
        }
    }
    
    private func setAvatarWithInitials() {
        let username = user.username ?? "?"

        var initials = ""
        var color: UInt = 0x000000
        
        if username == "?" {
            initials = username
            color = 0x000000
        } else {
            let position = username.characters.count % avatarColors.count
            color = avatarColors[position]
        
        }
        
        labelInitials.text = initials
        backgroundColor = UIColor(rgb: color, alphaVal: 1)
    }
    
}
