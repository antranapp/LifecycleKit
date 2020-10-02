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

import Combine
import Foundation
@testable import Lifecycle
@testable import SPIR
import SwiftUI
import XCTest

final class PresenterTests: XCTestCase {
    private let viewLifecycle = ViewLifecycle()

    func testPresenter() {
        testPresenterBinding(presenter: TestPresenter(viewLifecycle: viewLifecycle))
    }

    func testInteractablePresenter() {
        let interactablePresenter = TestInteractablePresenter(viewLifecycle: viewLifecycle)
        testPresenterBinding(presenter: interactablePresenter)
        XCTAssertTrue(viewLifecycle.scopeLifecycle === interactablePresenter.scopeLifecycle)
    }

    private func testPresenterBinding<PresenterType: Presenting & ViewPresentable>(presenter: PresenterType) {
        XCTAssertEqual(presenter.viewLifecycle, viewLifecycle)
        XCTAssertTrue(viewLifecycle.subscribers.contains(presenter))
        XCTAssertTrue(presenter.viewable is AnyView)
    }
}

final class TestPresenter: Presenter<TestView<TestPresenter>>, ViewPresentable, LifecycleSubscriber {
    func didLoad(_ lifecyclePublisher: LifecyclePublisher) {}

    func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {}

    func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher) {}
}

final class TestInteractablePresenter: InteractablePresenter<TestView<TestInteractablePresenter>>, ViewPresentable, PresentableInteractable {}
