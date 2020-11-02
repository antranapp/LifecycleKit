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
import CombineExtensions
import Foundation
import SwiftUI

public protocol ViewLifecycleOwner: AnyObject {
    /// View lifecycle tracking.
    var viewLifecycle: ViewLifecycle { get }
}

struct TrackingViewModifier: ViewModifier {
    var viewLifecycleOwner: ViewLifecycleOwner

    init(_ viewLifecycleOwner: ViewLifecycleOwner) {
        viewLifecycleOwner.viewLifecycle.viewDidLoad(with: viewLifecycleOwner)
        self.viewLifecycleOwner = viewLifecycleOwner
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                self.viewLifecycleOwner.viewLifecycle.isDisplayed = true
            }
            .onDisappear {
                self.viewLifecycleOwner.viewLifecycle.isDisplayed = false
            }
    }
}

extension View {
    public func tracked(by viewLifecycleOwner: ViewLifecycleOwner) -> some View {
        ModifiedContent(content: self, modifier: TrackingViewModifier(viewLifecycleOwner))
    }
}

/// Base class to conform to `ViewLifecycleOwner` observing as the owner of a `ViewLifecycle`.
open class BaseViewLifecycleOwner: ObjectIdentifiable, ViewLifecycleOwner, ViewLifecycleSubscriber {
    public let viewLifecycle: ViewLifecycle

    public init(viewLifecycle: ViewLifecycle = ViewLifecycle()) {
        self.viewLifecycle = viewLifecycle
        viewLifecycle.subscribe(self)
    }

    open func viewDidLoad() {}
    open func viewDidAppear() {}
    open func viewDidDisappear() {}
}
