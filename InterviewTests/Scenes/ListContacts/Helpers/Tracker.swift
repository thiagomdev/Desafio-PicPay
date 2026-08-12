//
//  Tracker.swift
//  Interview
//
//  Created by Thiago Monteiro on 8/8/26.
//  Copyright © 2026 PicPay. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(for instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        let instanceTypeName = String(describing: type(of: instance))
        addTeardownBlock { [weak instance, testName = self.name] in
            XCTAssertNil(
                instance,
                "Instance \(instanceTypeName) should have been deallocated. Potential memory leak in \(testName)",
                file: file,
                line: line
            )
        }
    }
}
