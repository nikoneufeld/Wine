//
//  main.swift
//  Winery
//
//  Created by Niko Neufeld on 10.12.19.
//  Copyright © 2019 Niko Neufeld. All rights reserved.
//
enum OptionalError: Error {
    case containsNil
}
postfix operator ^^
postfix func ^^<T>(rhs: Optional<T>) throws -> T {
    guard let wrapped = rhs else {
        throw OptionalError.containsNil
    }
    return wrapped
}

import Foundation
import Files
import ShellOut
struct Package: Codable {
    var name: String = ""
    var installationCommands = [String]()
    var source = String()
    var testCommands = [String]()
    var dependecyFiles = [String()]
}
let pkgtest = Package()
var templateJson = String(data: try JSONEncoder().encode(pkgtest), encoding: .utf8)
extension CommandLine {
    static var commands: [String] {
        get {
            var args = CommandLine.arguments
            args.removeFirst()
            return args
        }
    }
}
func extractWineFile(_ currentDir: Folder = Folder.current) -> Package {

    var jsonFile: File
    var json: String
    var jsonData: Data
    do {
        jsonFile = try currentDir.file(named: "Wine")
        json = try jsonFile.readAsString()
        jsonData = json.data(using: .utf8)!
        
    } catch {
            print("No Wine File")
            exit(1)
    }
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(Package.self, from: jsonData)
    } catch {
        print("Invalid Json")
        exit(1)
    }
}

func install(package pkg: Package)  {
        do {
            print("Cloning 🍷🍷🍷🍷🍷")
        try shellOut(to: .gitClone(url: URL(string: pkg.source)^^))
            var installtionCommands = ["cd \(pkg.name)"]
            installtionCommands.append(contentsOf: pkg.installationCommands)
            print("Installing 🍷🍷🍷🍷🍷🍷🍷🍷🍷")
            try shellOut(to: installtionCommands)
            if !pkg.dependecyFiles.isEmpty {
                print("Cloning Dependencies 🍷🍷🍷🍷🍷🍷 ")
                for urlStr in pkg.dependecyFiles {
                    let index = urlStr.lastIndex(of: "/")
                    let subStr = urlStr[(urlStr.index(after: index!))...urlStr.index(before: urlStr.endIndex)]
                    let gitUrl = subStr.prefix {
                        $0 != "."
                    }
                    try shellOut(to: .gitClone(url: URL(string: urlStr)^^))
                    var commands = ["cd \(String(gitUrl))"]
                    var pkgPath = Folder.current.path
                    pkgPath.append(contentsOf: "\(gitUrl)")
                    print(pkgPath)
                    let pkg = extractWineFile(try Folder(path: pkgPath))
                    commands.append(contentsOf: pkg.installationCommands)
                    try shellOut(to: commands)
                    print("Resolved \(pkg.name)")
                    
                    
                }
            }
            print("Done 🍷🍷🍷!!!")
            
        } catch {
            print("Error occured \(error.localizedDescription)")
        }
}

func test(package pkg: Package) {
    print("Testing 🍷🍷🍷🍷🍷🍷🍷🍷🍷")
}
// MARK: Action!!
print("Winery. At your service! 🍷🍷🍷🍷🍷🍷🍷🍷🍷 version 6")
if CommandLine.commands[0] == "install" {
         print("Starting Installlation 🍷🍷🍷🍷🍷 ")
        let pkg = extractWineFile()
        install(package: pkg)
} else if CommandLine.commands[0] == "new" {
    print("Creating File🍷🍷🍷🍷🍷🍷🍷🍷🍷")
    var dir = Folder.current
    var file = try dir.createFile(named: "Wine")
    try file.write(templateJson^^)
} else if CommandLine.commands[0].count != 1  {
    print("Usgae Blalalala")
}




