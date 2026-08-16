//
//  DelegateSpy.swift
//  Interview
//
//  Created by Thiago Monteiro on 8/16/26.
//  Copyright © 2026 PicPay. All rights reserved.
//

import Interview

final class DelegateSpy: ViewModelDelegate {
    private(set) var isLegacyCalled: Bool = false
    private(set) var isLegacyCount: Int = 0
    var expectedName: String?

    private(set) var notNotLegacy: Bool = false
    private(set) var notNotLegacyCount: Int = 0
    var notNotLegacyName: String?

    func isLegacy(name: String) {
        isLegacyCalled = true
        isLegacyCount += 1
        expectedName = name
    }

    func notNotLegacy(name: String) {
        notNotLegacy = true
        notNotLegacyCount += 1
        notNotLegacyName = name
    }
}
