//
//  LocalizationManager.swift
//  Places
//
//  Created by Алексей Воронов on 04/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation

extension String {
    func localize() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
