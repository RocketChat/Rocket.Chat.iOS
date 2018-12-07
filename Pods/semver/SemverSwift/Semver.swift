//
//  Semver.swift
//  Semver
//
//  Created by di wu on 1/20/15.
//  Copyright (c) 2015 di wu. All rights reserved.
//

import Foundation

struct Regex {
    var pattern: String {
        didSet {
            updateRegex()
        }
    }
    var expressionOptions: NSRegularExpression.Options {
        didSet {
            updateRegex()
        }
    }
    var matchingOptions: NSRegularExpression.MatchingOptions
    
    var regex: NSRegularExpression?
    
    init(pattern: String, expressionOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions) {
        self.pattern = pattern
        self.expressionOptions = expressionOptions
        self.matchingOptions = matchingOptions
        updateRegex()
    }
    
    init(pattern: String) {
        self.pattern = pattern
        expressionOptions = NSRegularExpression.Options.caseInsensitive
        matchingOptions = NSRegularExpression.MatchingOptions.reportProgress
        updateRegex()
    }
    
    mutating func updateRegex() {
        do {
            regex = try NSRegularExpression(pattern: pattern, options: expressionOptions)
        } catch {
            print(error)
        }
    }
}

extension String {
    func matchRegex(_ pattern: Regex) -> Bool {
        let range: NSRange = NSMakeRange(0, count)
        if pattern.regex != nil {
            let matches: [AnyObject] = pattern.regex!.matches(in: self, options: pattern.matchingOptions, range: range)
            return matches.count > 0
        }
        return false
    }
    
    func match(_ patternString: String) -> Bool {
        return self.matchRegex(Regex(pattern: patternString))
    }
    
    func replaceRegex(_ pattern: Regex, template: String) -> String {
        if self.matchRegex(pattern) {
            let range: NSRange = NSMakeRange(0, count)
            if pattern.regex != nil {
                return pattern.regex!.stringByReplacingMatches(in: self, options: pattern.matchingOptions, range: range, withTemplate: template)
            }
        }
        return self
    }
    
    func replace(_ pattern: String, template: String) -> String {
        return self.replaceRegex(Regex(pattern: pattern), template: template)
    }
}


open class Semver {
    
    let SemVerRegexp = "\\A(\\d+\\.\\d+\\.\\d+)(-([0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*))?(\\+([0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*))?\\Z"
    
    var major: String = ""
    var minor: String = ""
    var patch: String = ""
    var pre: String = ""
    var build: String = ""
    var versionStr: String = ""
    
    let BUILD_DELIMITER: String = "+"
    let PRERELEASE_DELIMITER: String = "-"
    let VERSION_DELIMITER: String  = "."
    let IGNORE_PREFIX: String = "v"
    let IGNORE_EQ: String = "="
    
    required public init(){
        
    }
    
    open class func version() -> String{
        return "1.0.0"
    }
    
    convenience init(version: String!){
        self.init()
        self.versionStr = version
        if valid(){
            var v = versionStr.components(separatedBy: VERSION_DELIMITER) as Array
            major = v[0]
            minor = v[1]
            patch = v[2]
            
            var prerelease = versionStr.components(separatedBy: PRERELEASE_DELIMITER) as Array
            if (prerelease.count > 1) {
                pre = prerelease[1]
            }
            
            var buildVersion = versionStr.components(separatedBy: BUILD_DELIMITER) as Array
            if (buildVersion.count > 1) {
                build = buildVersion[1]
            }
        }
    }
    
    func diff(_ version2: String) -> Int{
        let version = Semver(version: version2)
        if (major.compare(version.major) != .orderedSame){
            return major.compare(version.major).rawValue
        }
        
        if (minor.compare(version.minor) != .orderedSame){
            return minor.compare(version.minor).rawValue
        }
        
        if (patch.compare(version.patch) != .orderedSame){
            return patch.compare(version.patch, options: NSString.CompareOptions.numeric).rawValue
        }
        
        return 0
    }
    
    open class func valid(_ version: String) -> Bool{
        return Semver(version: version).valid()
    }
    
    func valid() -> Bool{
        if let _ = versionStr.range(of: SemVerRegexp, options: .regularExpression){
            return true
        }
        return false
    }
    
    open class func clean(_ version: String) -> String{
        return Semver(version: version).clean()
    }
    
    func clean() -> String{
        versionStr = versionStr.trimmingCharacters(in: CharacterSet.whitespaces)
        return versionStr.replace("^[=v]+", template: "")
    }
    
    open class func gt(_ version1: String, _ v: String) -> Bool{
        return Semver(version: version1).diff(v) > 0
    }
    
    open class func lt(_ version1: String, _ v: String) -> Bool{
        return Semver(version: version1).diff(v) < 0
    }
    
    open class func gte(_ version1: String, _ v: String) -> Bool{
        return Semver(version: version1).diff(v) >= 0
    }
    
    open class func lte(_ version1: String, _ v: String) -> Bool{
        return Semver(version: version1).diff(v) <= 0
    }
    
    open class func eq(_ version1: String, _ v: String) -> Bool{
        return Semver(version: version1).diff(v) == 0
    }
}
