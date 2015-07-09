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




func documentProvider(path: String) -> DocumentProvider {
    let fp: (Void -> String) = {
        do {
            return try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            return ""
        }
    }
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

    subscript (idx: Int) -> String {
        get {
            return self[idx..<idx+1]
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

