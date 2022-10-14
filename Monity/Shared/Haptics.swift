//
//  Haptics.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import UIKit

class Haptics {
    static let shared = Haptics()
    
    private init() {}
    
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
