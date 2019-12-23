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
    var dependecyFiles = [String]()
}
let pkgtest = Package()
var templateJson = String(data: try JSONEncoder().encode(pkgtest), encoding: .utf8)
extension CommandLine {
    static var commands: [String] {
        get {
            var args = CommandLine.arguments
            guard args.count > 1 else {return ["NOCOMMAND"]}
            args.removeFirst()
            return args
        }
    }
}
func get(_ pkg: String)  throws {
  if Folder.home.containsSubfolder(named: "Winery") {
      print("Updating 🍷🍷🍷🍷🍷")
      try shellOut(to: ["git fetch", "git pull"], at: "~/Winery")
      
  } else {
      print("Cloning 🍷🍷🍷🍷🍷")
      try shellOut(to: .gitClone(url: URL(string: "https://github.com/jakobneufeld/Winery.git")!),at: "~/")
      
  }
  print("Done Updating packages! 🍷🍷🍷🍷🍷")
  print("Getting Package \(pkg)🍷🍷🍷🍷🍷")
  
  do {
      let dir = try Folder.home.subfolder(named: "Winery").subfolder(named: pkg)
      print("Found Package 🍷🍷🍷🍷🍷")
      install(package: extractWineFile(dir))
      
  } catch {
      print("Wine is sour. Package does not exist 🍷🍷🍷🍷🍷")
      exit(1)
  }
}
func extractWineFile(_ currentDir: Folder = Folder.current) -> Package {

    var jsonFile: File
    var json: String
    var jsonData: Data
    do {
        print("Found Winefile")
        jsonFile = try currentDir.file(named: "Wine")
        json = try jsonFile.readAsString()
        jsonData = json.data(using: .utf8)!
        
    } catch {
            print(" Wine is SOUR No Wine File ❌❌")
            exit(1)
    }
    do {
        let decoder = JSONDecoder()
        print("Parsing Winefile")
        return try decoder.decode(Package.self, from: jsonData)
    } catch {
        print("Invalid Json")
        exit(1)
    }
}

func install(package pkg: Package)  {
        do {
            if !Folder.home.containsSubfolder(named: "Cave") {
                try Folder.home.createSubfolder(named: "Cave")
            }
            if try Folder.home.subfolder(named: "Cave").containsSubfolder(named: pkg.name) {
                print("Package \(pkg.name) already exists 🍷🍷🍷🍷🍷")
                return
            }
            print("Cloning 🍷🍷🍷🍷🍷")
            try shellOut(to: .gitClone(url: URL(string: pkg.source)^^), at: "~/Cave")
            var installtionCommands = ["cd \(pkg.name)"]
            installtionCommands.append(contentsOf: pkg.installationCommands)
            print("Installing 🍷🍷🍷🍷🍷🍷🍷🍷🍷")
            try shellOut(to: installtionCommands, at: "~/Cave")
            if !pkg.dependecyFiles.isEmpty {
                print("Cloning Dependencies 🍷🍷🍷🍷🍷🍷 ")
                for urlStr in pkg.dependecyFiles {
                    let index = urlStr.lastIndex(of: "/")
                    let subStr = urlStr[(urlStr.index(after: index!))...urlStr.index(before: urlStr.endIndex)]
                    let gitUrl = subStr.prefix {
                        $0 != "."
                    }
                    if try Folder.home.subfolder(named: "Cave").containsSubfolder(named: String(gitUrl)) {
                                print("Package \(gitUrl) already exists")
                        continue
                        }
                    try shellOut(to: .gitClone(url: URL(string: urlStr)^^),at: "~/Cave")
                  
                    var pkgPath = try Folder.home.subfolder(named: "Cave").path
                    pkgPath.append(contentsOf: "\(gitUrl)")
                    let pkg = extractWineFile(try Folder(path: pkgPath))
                     var commands = ["cd \(pkgPath)"]
                    commands.append(contentsOf: pkg.installationCommands)
                    try shellOut(to: commands)
                    print("Resolved \(pkg.name)")
                    
                    
                }
            }
            print("Done 🍷🍷🍷!!!")
            
        } catch {
            print("Wine is sour!! \(error)")
        }
}

func test(package pkg: Package) {
    print("Testing 🍷🍷🍷🍷🍷🍷🍷🍷🍷")
    var commands = [String]()
    commands.append(contentsOf: pkg.testCommands)
    do {
        try shellOut(to: commands)
    } catch {
        print(" Wine is SOUR! Test Failed. Exact error is \(error)   ❌")
    }
    print("Test Complete 🍷🍷🍷🍷🍷🍷🍷🍷🍷 ✅")
}

func build(package pkg: Package) {
        print("Building 🍷🍷🍷🍷🍷🍷🍷🍷🍷")
        var commands = [String]()
        commands.append(contentsOf: pkg.installationCommands)
        do {
            try shellOut(to: commands)
        } catch {
            print(" Wine is SOUR! Buld Failed. Exact error is \(error)   ❌")
            exit(1)
        }
        print("Build Complted🍷🍷🍷🍷🍷🍷🍷🍷🍷 ✅")
}


// MARK: Action!!
print("Winery. At your service! 🍷🍷🍷🍷🍷🍷🍷🍷🍷 version 1")
if CommandLine.commands[0] == "install" {
         print("Starting Installlation 🍷🍷🍷🍷🍷 ")
        let pkg = extractWineFile()
        install(package: pkg)
} else if CommandLine.commands[0] == "new" {
    print("Creating File🍷🍷🍷🍷🍷🍷🍷🍷🍷")
    let dir = Folder.current
    let file = try dir.createFile(named: "Wine")
    try file.write(templateJson^^)
} else if CommandLine.commands[0] == "test" {
    let pkg = extractWineFile()
    test(package: pkg)
} else if CommandLine.commands[0] == "build" {
    let pkg = extractWineFile()
    build(package: pkg)
} else if  CommandLine.commands[0] == "get"{
    guard CommandLine.commands.count > 1 else {
        print("Missing one argument 🍷🍷🍷🍷🍷")
        exit(1)
    }
    try get(CommandLine.commands[1])
} else {
    print("""
Wine, A package manager
--------------------------
Here are the commands:
build: Builds and runs the installation commands. Does not build the dependecies.
install: Same thing as build but clones the git repo first. Unlike the other comands. it also installs all its dependecies.
test: Same thing as build but runs the test commands not the installation commands.
new: Creates a wine file for you with the template.
get: Gets a package from the WInery
To create a package your self, use the `new` command.
Synopsis:
wine [command] [arg].
Use the command `vinager` to uninstall any Package!

Jakob Neufeld

"""
    )
}



