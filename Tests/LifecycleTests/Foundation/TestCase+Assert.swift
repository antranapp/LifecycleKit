//
//  Copyright (c) 2021. Adam Share
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
@testable import Lifecycle
import XCTest

public extension XCTestCase {
    func expectAssertionFailure(timeout: TimeInterval = 0.0, _ execute: () -> Void) {
        let expect = expectation(description: "Assertion failure not called.")

        assertionFailureClosures.append { _, _, _ in
            expect.fulfill()
        }

        execute()

        wait(for: [expect], timeout: timeout)
    }

    func expectAssert(passes: Bool = false, timeout: TimeInterval = 0.0, _ execute: () -> Void) {
        let expect = expectation(description: "Assert was not called.")

        assertClosures.append { condition, _, _, _ in
            if condition() == passes {
                expect.fulfill()
            } else {
                XCTFail("Asssert condition was not \(passes).")
            }
        }

        execute()

        wait(for: [expect], timeout: timeout)
    }
}
