//
//  Typealiases.swift
//  CoPilot
//
//  Created by Sven Schmidt on 29/06/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation

typealias DisplayName = String
typealias Hash = String
typealias Position = UInt

typealias CursorUpdate = (Selection -> Void)
typealias DocumentProvider = (Void -> Document)
typealias DocumentUpdate = (Document -> Void)
typealias MessageHandler = (Message -> Void)
typealias ResolutionHandler = (WebSocket -> Void)
typealias ErrorHandler = (NSError -> Void)

