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

/// Creates an active lifecycle that deactivates when released.
final class ReferenceLifecycleOwner: ObjectIdentifiable, LifecycleOwner, LifecycleOwnerRouting {
    public let scopeLifecycle: ScopeLifecycle = ScopeLifecycle()
    deinit {
        scopeLifecycle.deactivate()
    }
}

/// Type erased `View`.
public protocol Viewable: AnyObject {
    /// Wraps in `AnyView`.
    var asAnyView: AnyView { get }
}

public final class ViewProvider<Content: View>: Viewable {
    public let asAnyView: AnyView

    public init(view: Content) {
        self.asAnyView = view.asAnyView
    }
}

extension View {
    public var asAnyView: AnyView {
        return AnyView(self)
    }

    public var asViewProvider: ViewProvider<Self> {
        return ViewProvider(view: self)
    }
}

#if os(iOS) || os(tvOS)
    extension View {
        public var asUIViewController: UIViewController {
            return UIHostingController(rootView: self)
        }
    }

    extension Viewable {
        public var asUIViewController: UIViewController {
            return UIHostingController(rootView: asAnyView)
        }
    }
#endif

/// Lifecycle active as long as the view is referenced. Lazily loads when `asAnyView` is accessed.
public final class LifecycleOwnerViewProvider<Content: View>: Viewable {
    public lazy var asAnyView: AnyView = {
        let lifecycleView = LifecycleView(body: viewBuilder())
        lifecycleView.lifecycle.attachChild(childLifecycle)
        lifecycleView.lifecycle.activate()
        return lifecycleView.asAnyView
    }()

    private lazy var childLifecycle: LifecycleOwner = childLifecycleBuilder()

    private let viewBuilder: () -> Content
    private let childLifecycleBuilder: () -> LifecycleOwner

    public init(view: @autoclosure @escaping () -> Content,
                childLifecycle: @autoclosure @escaping () -> LifecycleOwner) {
        viewBuilder = view
        childLifecycleBuilder = childLifecycle
    }

    struct LifecycleView<Content: View>: View {
        let lifecycle: ReferenceLifecycleOwner = ReferenceLifecycleOwner()
        let body: Content
    }
}

public struct LazyView<Content: View>: View {
    private let build: () -> Content

    public init(view: @autoclosure @escaping () -> Content) {
        self.build = view
    }

    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    public var body: Content {
        build()
    }
}
