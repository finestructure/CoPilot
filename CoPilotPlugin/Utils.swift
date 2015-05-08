//
//  Utils.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 06/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Foundation
import FeinstrukturUtils


func fileProvider(path: String) -> (Void -> String) {
    return {
        var result: NSString?
        if let error = try({ error in
            result = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: error)
            return
        }) {
            if error.code == 260 { // does not exist
                result = ""
                let res = try({ error in
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


func documentProvider(path: String) -> (Void -> Document) {
    let fp = fileProvider(path)
    return { Document(fp()) }
}
