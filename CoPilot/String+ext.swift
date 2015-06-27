//
//  String+ext.swift
//  CoPilot
//
//  Created by Sven Schmidt on 24/06/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


extension String {
    
    func md5() -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.destroy()
        
        return hash as String
    }
    
}
