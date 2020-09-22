//
//  Copyright (c) 2020. Adam Share
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
@testable import SPIR
import XCTest

final class BuilderTests: XCTestCase {
    func testAnyBuilderAutoClosure() {
        var string = ""
        let builder = AnyBuilder { string }
        string = "test"
        XCTAssertEqual(builder.build(), "test")
    }

    func testAnyDynamicBuilder() {
        XCTAssertEqual(AnyDynamicBuilder { test in test }.build("test"), "test")
    }
}
