//
//  AttributedString + conveniences.swift
//
//
//  Created by The Northstar✨ System on 2024-02-17.
//

import Foundation



public extension AttributedString {
    init<Stringish: StringProtocol>(_ stringish: Stringish) {
        if let selfish = stringish as? Self {
            self = selfish
        }
        else if let selfish = stringish as? any AttributedStringProtocol {
            self.init(selfish, including: \.foundation)
        }
        else if let string = stringish as? String {
            self.init(stringLiteral: string)
        }
        else if #available(macOS 13, iOS 16, *),
                let lsr = stringish as? LocalizedStringResource {
            self.init(localized: lsr)
        }
        else {
            self.init(stringLiteral: String(stringish))
        }
    }
}
