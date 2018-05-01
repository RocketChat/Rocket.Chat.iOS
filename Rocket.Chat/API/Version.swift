//
//  Version.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

struct Version {
    let major: Int
    let minor: Int
    let patch: Int

    let identifier: String?
    let metadata: String?

    static let zero: Version = Version(0, 0, 0)

    init(_ major: Int = 0, _ minor: Int = 0, _ patch: Int = 0, _ identifier: String? = nil, _ metadata: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.identifier = identifier
        self.metadata = metadata
    }

    init?(_ versionRepresentation: VersionRepresentable) {
        guard let version = versionRepresentation.version() else {
            return nil
        }

        self = version
    }
}

extension Version: CustomStringConvertible {
    var description: String {
        return String(self)
    }
}

extension Version: Comparable {
    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                return lhs.patch < rhs.patch
            } else {
                return lhs.minor < rhs.minor
            }
        } else {
            return lhs.major < rhs.major
        }
    }

    static func == (lhs: Version, rhs: Version) -> Bool {
        return
            lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch
    }
}

protocol VersionInitializable {
    init(_ version: Version)
}

protocol VersionRepresentable {
    func version() -> Version?
}

typealias VersionConvertible = VersionInitializable & VersionRepresentable

extension String: VersionConvertible {
    init(_ version: Version) {
        var string = "\(version.major).\(version.minor).\(version.patch)"
        if let identifier = version.identifier {
            string.append("-\(identifier)")
        }

        if let metadata = version.metadata {
            string.append("+\(metadata)")
        }
        self = string
    }

    func version() -> Version? {
        let hifenComponents = self.components(separatedBy: "-")
        let dotComponents = hifenComponents[0].components(separatedBy: ".")

        // we have at least major.min.patch
        guard
            dotComponents.count >= 3,
            let major = Int(dotComponents[0]),
            let minor = Int(dotComponents[1]),
            let patch = Int(dotComponents[2])
        else {
            return nil
        }

        let identifier: String?
        if hifenComponents.count == 2 {
            let plusComponents = hifenComponents[1].components(separatedBy: "+")
            identifier = plusComponents[0]
        } else {
            identifier = nil
        }

        let metadata: String?
        let plusComponents = self.components(separatedBy: "+")
        if plusComponents.count == 2 {
            metadata = plusComponents[1]
        } else {
            metadata = nil
        }

        return Version(major, minor, patch, identifier, metadata)
    }
}
