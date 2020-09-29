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
import XCTest

final class LifecycleTests: XCTestCase {
    func testBind() {
        let lifecylceOwner = TestLifecycleOwner()

        lifecylceOwner.scopeLifecycle.activate()

        XCTAssertEqual(lifecylceOwner.scopeLifecycle.owner as? TestLifecycleOwner, lifecylceOwner)
    }

    func testAddChild() {
        let parent = TestLifecycleOwner()
        let child = TestLifecycleOwner()

        XCTAssertFalse(child.isActive)

        XCTAssertTrue(parent.attachChild(child))

        XCTAssertEqual(parent.children as! [TestLifecycleOwner], [child])
        XCTAssertFalse(parent.isActive)
        XCTAssertFalse(child.isActive)
        XCTAssertEqual(child.didLoadCount, 0)
        XCTAssertEqual(child.didBecomeActiveCount, 0)
        XCTAssertEqual(child.didBecomeInactiveCount, 0)

        parent.scopeLifecycle.activate()

        XCTAssertEqual(parent.children as! [TestLifecycleOwner], [child])
        XCTAssertTrue(parent.isActive)
        XCTAssertTrue(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 1)
        XCTAssertEqual(child.didBecomeInactiveCount, 0)

        XCTAssertFalse(parent.attachChild(child))

        XCTAssertEqual(parent.children as! [TestLifecycleOwner], [child])
        XCTAssertTrue(parent.isActive)
        XCTAssertTrue(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 1)
        XCTAssertEqual(child.didBecomeInactiveCount, 0)

        parent.scopeLifecycle.deactivate()

        XCTAssertEqual(parent.children as! [TestLifecycleOwner], [child])
        XCTAssertFalse(parent.isActive)
        XCTAssertFalse(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 1)
        XCTAssertEqual(child.didBecomeInactiveCount, 1)

        parent.scopeLifecycle.activate()

        XCTAssertEqual(parent.children as! [TestLifecycleOwner], [child])
        XCTAssertTrue(parent.isActive)
        XCTAssertTrue(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 2)
        XCTAssertEqual(child.didBecomeInactiveCount, 1)

        parent.detachChild(child)

        XCTAssertEqual(parent.children as! [TestLifecycleOwner], [])
        XCTAssertTrue(parent.isActive)
        XCTAssertFalse(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 2)
        XCTAssertEqual(child.didBecomeInactiveCount, 2)
    }

    func testAddParentAsChild_asserts() {
        let parent = TestLifecycleOwner()

        expectAssert {
            parent.attachChild(parent)
        }
    }

    func testAddChildAsChild_asserts() {
        let parent = TestLifecycleOwner()
        let child = TestLifecycleOwner()

        XCTAssertTrue(parent.attachChild(child))

        let parent2 = TestLifecycleOwner()

        expectAssert(passes: true) {
            expectAssert {
                parent2.attachChild(child)
            }
        }
    }

    func testDuplicateOwner_asserts() {
        let scopeLifecycle = ScopeLifecycle()
        let owner = TestLifecycleOwner(scopeLifecycle: scopeLifecycle)

        expectAssertionFailure {
            _ = TestLifecycleOwner(scopeLifecycle: scopeLifecycle)
        }

        XCTAssertNotNil(owner)
    }

    func testReleasedOwner() {
        let scopeLifecycle = ScopeLifecycle()

        autoreleasepool {
            let owner = TestLifecycleOwner(scopeLifecycle: scopeLifecycle)
            XCTAssertEqual(owner, scopeLifecycle.owner as! TestLifecycleOwner)
        }

        let owner = TestLifecycleOwner(scopeLifecycle: scopeLifecycle)

        XCTAssertEqual(owner, scopeLifecycle.owner as! TestLifecycleOwner)
    }

    func testBindAgain_asserts() {
        let parent = TestLifecycleOwner()
        expectAssertionFailure {
            parent.subscribe(parent.scopeLifecycle)
        }
    }

    func testScopeLifecycleDependent() {
        let weakLifecycleOwner = ScopeLifecycleDependent(scopeLifecycle: ScopeLifecycle())

        XCTAssertNil(weakLifecycleOwner.scopeLifecycle)
        XCTAssertFalse(weakLifecycleOwner.attachChild(TestLifecycleOwner()))
    }
}

final class TestLifecycleOwner: BaseLifecycleOwner {

    var didLoadCount: Int = 0
    override func didLoad(_ lifecyclePublisher: LifecyclePublisher) {
        didLoadCount += 1
    }

    var didBecomeActiveCount: Int = 0
    override func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {
        didBecomeActiveCount += 1
    }

    var didBecomeInactiveCount: Int = 0
    override func didBecomeInactive() {
        didBecomeInactiveCount += 1
    }
}
