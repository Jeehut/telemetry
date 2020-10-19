//
//  File.swift
//  
//
//  Created by Daniel Jilg on 18.10.20.
//

import Foundation

extension String {
    var escaped: String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted)
    }
}
