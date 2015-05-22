//
//  Cursor.swift
//  CoPilotPlugin
//
//  Created by Sven A. Schmidt on 22/05/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import FeinstrukturUtils


let Duration: NSTimeInterval = 0.6


class Cursor: NSObject {

    let view = NSView()
    var anim = NSViewAnimation(duration: Duration/2, animationCurve: .EaseInOut)
    let textView: NSTextView
    var timer: Timer! = nil
    var effect = NSViewAnimationFadeInEffect

    var selection: Selection? {
        didSet {
            if let sel = self.selection,
               let rect = self.textView.rectForRange(sel.range) {
                self.view.frame = rect.withPadding(x: 0.5, y: 1)
            }
        }
    }


    init(color: NSColor, textView: NSTextView) {
        self.textView = textView
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = color.CGColor
        self.textView.addSubview(self.view)

        super.init()

        self.timer = Timer(interval: Duration) {
            self.blink()
        }
        self.anim.animationBlockingMode = .Nonblocking
    }


    func blink() {
        var animInfo: [String: AnyObject] = [
            NSViewAnimationTargetKey: self.view,
            NSViewAnimationEffectKey: (self.view.hidden ? NSViewAnimationFadeInEffect : NSViewAnimationFadeOutEffect)
        ]
        self.anim.viewAnimations = [animInfo]
        self.anim.startAnimation()
    }

}

