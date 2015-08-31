//
//  Diff.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 19/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation

import FeinstrukturUtils


enum ErrorCodes: Int {
    case ApplyFailed = 100
    case LocalChanges = 200
}


func computeDiff(a: String?, b: String?, checklines: Bool = true, deadline: NSTimeInterval = 1) -> [Diff] {
    let dmp = DiffMatchPatch()
    if let diffs = dmp.diff_mainOfOldString(a, andNewString: b, checkLines: checklines, deadline: deadline) {
        return NSArray(array: diffs) as! [Diff]
    } else {
        return [Diff]()
    }
}


func computePatches(diffs: [Diff]) -> [Patch] {
    let dmp = DiffMatchPatch()
    if let patches = dmp.patch_makeFromDiffs(NSMutableArray(array: diffs)) {
        return NSArray(array: patches) as! [Patch]
    } else {
        return [Patch]()
    }
}


func computePatches(a: String?, b: String?) -> [Patch] {
    let dmp = DiffMatchPatch()
    if let res = dmp.patch_makeFromOldString(a, andNewString: b) {
        return NSArray(array: res) as! [Patch]
    } else {
        return [Patch]()
    }
}


func apply(source: String, patches: [Patch]) -> Result<String> {
    let dmp = DiffMatchPatch()
    if let res = dmp.patch_apply(NSArray(array: patches) as [AnyObject], toString: source) {
        assert(res.count == 2, "results array must have two entries: (text, results)")
        if let target = res[0] as? String {
            let results = res[1] as! NSArray
            let success = results.reduce(true) { (res, elem) in res && (elem as! NSNumber).boolValue }
            if success {
                return Result(target)
            }
        }
    }
    let info = ["NSLocalizedDescriptionKey": "failed to apply patches"]
    return Result(NSError(domain: "Diff", code: ErrorCodes.ApplyFailed.rawValue, userInfo: info))
}


func apply(source: Document, changeSet: Changeset) -> Result<Document> {
    if source.hash == changeSet.baseRev {
        // this should apply cleanly
        switch apply(source.text, patches: changeSet.patches) {
        case .Success(let value):
            let target = Document(value)
            assert(target.hash == changeSet.targetRev)
            return Result(target)
        case .Failure(let error):
            return Result(error)
        }
    } else {
        let info = ["NSLocalizedDescriptionKey": "cannot apply patches due to local changes"]
        return Result(NSError(domain: "Diff", code: ErrorCodes.LocalChanges.rawValue, userInfo: info))
    }
}


extension Patch {

    subscript(index: Int) -> Diff {
        return self.diffs[index] as! Diff
    }
    
}


extension Patch: SequenceType {
    
    public func generate() -> AnyGenerator<Diff> {
        var next = 0
        return anyGenerator {
            if (next == self.diffs.count) {
                return nil
            }
            return self[next++]
        }
    }
    
}


extension Operation: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .DiffDelete:
            return "Delete"
        case .DiffInsert:
            return "Insert"
        case .DiffEqual:
            return "Equal"
        }
    }
    
}


func adjustPos(position: Position, patch: Patch) -> Position {
    if patch.start1 > position {
        return position
    } else {
        var posInPatch = position - patch.start1
        var diffPointer: Position = 0
        for diff in patch {
            let diffSize = Position((diff.text as NSString).length)

            switch diff.operation {
            case .DiffEqual:
                diffPointer += diffSize
                if diffPointer > posInPatch {
                    return patch.start1 + posInPatch
                }
            case .DiffDelete:
                posInPatch -= Position(min(diffSize, posInPatch))
            case .DiffInsert:
                posInPatch += diffSize
            }
        }
        return patch.start1 + posInPatch
    }
}



func newPosition(currentPos: Position, patches: [Patch]) -> Position {
    var x = currentPos
    for patch in patches {
        x = adjustPos(x, patch: patch)
    }
    return x
}


func writeTemp(content: String) -> NSURL? {
    do {
        let url = tempUrl()
        try content.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
        return url
    } catch {
        return nil
    }
}


func tempUrl() -> NSURL {
    let id = NSProcessInfo.processInfo().globallyUniqueString
    let temp = NSURL(fileURLWithPath: NSTemporaryDirectory())
    return temp.URLByAppendingPathComponent(id)
}


func diff3(mine: NSURL, ancestor: NSURL, yours: NSURL) -> String? {
    let pipe = NSPipe()
    let file = pipe.fileHandleForReading

    let task = NSTask()
    task.launchPath = "/usr/bin/diff3"
    task.arguments = [mine.path!, ancestor.path!, yours.path!, "-m"]
    task.standardOutput = pipe
    task.launch()

    let data = file.readDataToEndOfFile()
    file.closeFile()
    let output = NSString(data: data, encoding: NSUTF8StringEncoding)
    return output as String?
}


func merge(mine: String, ancestor: String, yours: String) -> String? {
    let m = writeTemp(mine)!
    let a = writeTemp(ancestor)!
    let y = writeTemp(yours)!

    if let res = diff3(m, ancestor: a, yours: y) {
        if res.contains("<<<<<<<") && res.contains("=======") && res.contains(">>>>>>>") {
            // merge conflict
            return nil
        } else {
            return res
        }
    } else {
        return nil
    }
}

