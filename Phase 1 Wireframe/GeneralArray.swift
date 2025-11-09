//
//  GeneralNSArray.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/31/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/**
 `GeneralArray.swift` is an extension on the Array class that defines a function that allows an array to split into two pieces. This functionality is used when retrieving user data from the database and assigning it to the equalizer bands when the user opens the `EqualizerViewController`.
 */
extension Array {
    /// This function returns a tuple containing two arrays which are the first and second halves of the original array: (1st half, 2nd half). This method is generalized to the `Element` datatype since arrays can contain anything from Doubles, Ints, and Floats, to complex `NSObjects`. 
    func split() -> (left: [Element], right: [Element]) {
        let ct = self.count
        let half = ct / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< ct]
        return (left: Array(leftSplit), right: Array(rightSplit))
    }
}
