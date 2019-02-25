//
//  Extensions.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 25/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation
import CoreData

// MARK : - UIButton -
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

// MARK: - NSFetchedResultsController
extension NSFetchedResultsController {
    /// Check whether provided indexPath is valid.
    @objc public func hasObject(at indexPath : IndexPath) -> Bool{
        guard let sections = self.sections, sections.count > indexPath.section else {
            return false
        }
        let sectionInfo = sections[indexPath.section]
        guard sectionInfo.numberOfObjects > indexPath.row else {
            return false
        }
        return true
    }
}

// MARK: - String
// Source : https://stackoverflow.com/a/52865696
extension String {
    func isEmptyOrWhitespace() -> Bool {

        // Check empty string
        if self.isEmpty {
            return true
        }
        // Trim and check empty string
        return (self.trimmingCharacters(in: .whitespaces) == "")
    }
}

// MARK: - Date
extension Date {
    var localDateDescription: String {
        return description(with: NSLocale.current)
    }

    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    func formattedTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        let dateString = formatter.string(from: self)
        return dateString
    }

}
