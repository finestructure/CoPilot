//
//  Diff.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 19/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation

import FeinstrukturUtils
import CryptoSwift


enum ErrorCodes: Int {
    case ApplyFailed = 100
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
            let success = reduce(results, true) { (res, elem) in res && (elem as! NSNumber).boolValue }
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
        switch apply(source.text, changeSet.patches) {
        case .Success(let value):
            let target = Document(value.unbox)
            assert(target.hash == changeSet.targetRev)
            return Result(target)
        case .Failure(let error):
            return Result(error)
        }
    } else {
        // we have local changes
        // try applying this but it might fail
        let res = apply(source.text, changeSet.patches)
        return map(res) { Document($0) }
    }
}


extension Patch {

    subscript(index: Int) -> Diff {
        return self.diffs[index] as! Diff
    }
    
}


extension Patch: SequenceType {
    
    public func generate() -> GeneratorOf<Diff> {
        var next = 0
        return GeneratorOf<Diff> {
            if (next == self.diffs.count) {
                return nil
            }
            return self[next++]
        }
    }
    
}


extension Operation: Printable {
    
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


typealias Position = UInt


func adjustPos(position: Position, patch: Patch) -> Position {
    if position < patch.start1 {
        return position
    } else {
        var x = position
        var diffPointer = 0
        for diff in patch {
            let posPointer = Int(x - patch.start1)
            if diffPointer < posPointer {
                x = adjustPos(x, diff)
            }
            if diff.operation == .DiffEqual {
                diffPointer += (diff.text as NSString).length
            }
        }
        return x
    }
}


func adjustPos(position: Position, diff: Diff) -> Position {
    let diffSize = (diff.text as NSString).length
    
    switch diff.operation {
    case .DiffEqual:
        return position
    case .DiffDelete:
        return Position( max(Int(position) - diffSize, 0) )
    case .DiffInsert:
        return position + Position(diffSize)
    }
}


func newPosition(currentPos: Position, patches: [Patch]) -> Position {
    var x = currentPos
    for patch in patches {
        x = adjustPos(x, patch)
    }
    return x
}

