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
    query = query.replacingOccurrences(of: " ", with: "+")

    // Apply a regex pattern
    let pattern = "[^A-Za-z+]+"
    query = query.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
    query = query.lowercased()
    return query
}

/// Handles visibility of network activity indicator
public func setNetworkActivityIndicatorVisibility(_ visible: Bool) {
    DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = visible
    }
}
