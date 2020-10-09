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
import Lifecycle

public typealias LifecycleSubscriber = Lifecycle.LifecycleSubscriber
public typealias LifecycleOwner = Lifecycle.LifecycleOwner
public typealias LifecycleOwnerRouting = Lifecycle.LifecycleOwnerRouting
public typealias LifecyclePublisher = Lifecycle.LifecyclePublisher
public typealias LifecycleState = Lifecycle.LifecycleState
public typealias LifecycleStateOptions = Lifecycle.LifecycleStateOptions
public typealias RootLifecycle = Lifecycle.RootLifecycle
public typealias ScopeLifecycle = Lifecycle.ScopeLifecycle
public typealias ViewLifecycleSubscriber = Lifecycle.ViewLifecycleSubscriber
public typealias ViewLifecycle = Lifecycle.ViewLifecycle

#if canImport(NeedleFoundation)
    import NeedleFoundation

    public typealias EmptyDependency = NeedleFoundation.EmptyDependency
    public typealias BootstrapComponent = NeedleFoundation.BootstrapComponent
    public typealias Dependency = NeedleFoundation.Dependency
    public typealias Component = NeedleFoundation.Component
    public typealias Scope = NeedleFoundation.Scope

    extension NeedleFoundation.Component: LifecycleOwnerComponent {}
#endif