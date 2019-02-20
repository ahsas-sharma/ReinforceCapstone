//
//  Utility.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 17/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation



public func formatQueryString(_ queryString: String) -> String {
    var query = queryString

    // Remove double whitespaces and replace remaining with '+'
    query = query.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
    query = query.replacingOccurrences(of: " ", with: "&")

    // Apply a regex pattern
    let pattern = "[^A-Za-z+]+"
    query = query.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
    query = query.lowercased()
    return query
}


// Source : https://stackoverflow.com/a/52404009
extension UIButton {

    /// Sets the background color to use for the specified button state.
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {

        let minimumSize: CGSize = CGSize(width: 1.0, height: 1.0)

        UIGraphicsBeginImageContext(minimumSize)

        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: minimumSize))
        }

        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.clipsToBounds = true
        self.setBackgroundImage(colorImage, for: forState)
    }

}
