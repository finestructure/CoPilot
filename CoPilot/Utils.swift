//
//  Utils.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 06/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


func observe(name: String?, object: AnyObject? = nil, block: (NSNotification!) -> Void) -> NSObjectProtocol {
    let nc = NSNotificationCenter.defaultCenter()
    let queue = NSOperationQueue.mainQueue()
    return nc.addObserverForName(name, object: object, queue: queue, usingBlock: block)
}


typealias DocumentProvider = (Void -> Document)


func fileProvider(path: String) -> (Void -> String) {
    return {
        var result: NSString?
        if let error = `try`({ error in
            result = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: error)
            return
        }) {
            if error.code == 260 { // does not exist
                result = ""
                let res = `try`({ error in
                    result?.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: error)
                })
                if res.failed {
                    let reason = "could not create file: \(res.error!.localizedDescription)"
                    NSException(name: "fileProvider", reason: reason, userInfo: nil).raise()
                }
            } else {
                let reason = "failed to load test file: \(error.localizedDescription)"
                NSException(name: "fileProvider", reason: reason, userInfo: nil).raise()
            }
        }
        return result! as String
    }
}


func documentProvider(path: String) -> DocumentProvider {
    let fp = fileProvider(path)
    return { Document(fp()) }
}


extension NSTextStorage {

    public func replaceAll(text: String) {
        let range = NSRange(location: 0, length: self.length)
        self.replaceCharactersInRange(range, withAttributedString: NSAttributedString(string: text))
    }

}


extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
}


extension NSTextView {

    func rectForRange(range: NSRange) -> NSRect? {
        if let l = self.layoutManager {
            let rect = l.boundingRectForGlyphRange(range, inTextContainer: self.textContainer!)
            return NSOffsetRect(rect, self.textContainerOrigin.x, self.textContainerOrigin.y)
        } else {
            return nil
        }
    }

}

