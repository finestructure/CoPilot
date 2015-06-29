#!/usr/bin/swift

import Cocoa

var prodDir: String {
  get { return NSProcessInfo().environment["BUILT_PRODUCTS_DIR"]! }
}

var projectDir: String {
  get { return NSProcessInfo().environment["PROJECT_DIR"]! }
}

var prodName: String {
  get { return NSProcessInfo().environment["PRODUCT_NAME"]! }
}

func run(command: String, args: [String]) -> String? {
    let pipe = NSPipe()
    let file = pipe.fileHandleForReading

    let task = NSTask()
    task.launchPath = command
    task.currentDirectoryPath = projectDir
    task.arguments = args
    task.standardOutput = pipe
    task.launch()

    let data = file.readDataToEndOfFile()
    file.closeFile()
    let output = NSString(data: data, encoding: NSUTF8StringEncoding)
    return output as String?
}


if let output = run("/usr/bin/git", args: ["describe"]) {

  let newLine = NSCharacterSet.newlineCharacterSet()
  let version = output.stringByTrimmingCharactersInSet(newLine)
  let short = version.componentsSeparatedByString("-")[0]
  let path = "\(prodDir)/\(prodName).xcplugin/Contents/Info.plist"

  if let plist = NSMutableDictionary(contentsOfFile: path) {
    plist.setValue(version, forKey: "CFBundleVersion")
    plist.setValue(short, forKey: "CFBundleShortVersionString")
    plist.writeToFile(path, atomically: true)
    print("Updated '\(path)':")
    print("CFBundleVersion:            \(version)")
    print("CFBundleShortVersionString: \(short)")
  } else {
    print("Failed to read Info.plist from \(path)")
  }

} else {
  print("Failed to obtain version from 'git describe'")
  exit(-1)
}
