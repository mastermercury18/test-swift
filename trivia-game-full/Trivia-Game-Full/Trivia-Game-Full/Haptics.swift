//
//  Haptics.swift
//  Trivia-Game-Full
//
//  Created by Neha Chandran on 8/13/25.
//

// Haptics.swift
#if canImport(UIKit)
import UIKit
enum Haptics {
    static func feedback(success: Bool) {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(success ? .success : .error)
    }
}
#else
import Foundation
enum Haptics {
    static func feedback(success: Bool) { /* no-op on non-iOS */ }
}
#endif
