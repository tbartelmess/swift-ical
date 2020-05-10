//
//  Utilities.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-10.
//

import Foundation

extension String {
    var extraNewline: String {
        return self + "\n"
    }
    var withCRLFLineEnding: String {
        replacingOccurrences(of: "\n", with: "\r\n")
    }

    var icalFormatted: String {
        return extraNewline.withCRLFLineEnding
    }
}

