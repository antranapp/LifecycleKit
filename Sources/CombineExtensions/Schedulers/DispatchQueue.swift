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

public struct DispatchQueue: QueueContextEquatable, Scheduler {
    /// `DispatchQueue.main` underlying queue.
    public static let main = DispatchQueue(backingQueue: Foundation.DispatchQueue.main)

    /// `DispatchQueue.global(qos: .userInteractive)` underlying queue.
    public static let `default` = DispatchQueue(backingQueue: Foundation.DispatchQueue.global(qos: .default))

    /// `DispatchQueue.global(qos: .userInteractive)` underlying queue.
    public static let userInteractive = DispatchQueue(backingQueue: Foundation.DispatchQueue.global(qos: .userInteractive))

    /// `DispatchQueue.global(qos: .userInitiated)` underlying queue.
    public static let userInitiated = DispatchQueue(backingQueue: Foundation.DispatchQueue.global(qos: .userInitiated))

    /// `DispatchQueue.global(qos: .utility)` underlying queue.
    public static let utility = DispatchQueue(backingQueue: Foundation.DispatchQueue.global(qos: .utility))

    public enum QualityOfService {
        case `default`
        case userInteractive
        case userInitiated
        case utility

        fileprivate var asDispatchQoS: DispatchQoS {
            switch self {
            case .default: return .default
            case .userInteractive: return .userInteractive
            case .userInitiated: return .userInitiated
            case .utility: return .utility
            }
        }
    }

    public var now: Foundation.DispatchQueue.SchedulerTimeType {
        return backingQueue.now
    }

    public var minimumTolerance: Foundation.DispatchQueue.SchedulerTimeType.Stride {
        return backingQueue.minimumTolerance
    }

    public var isCurrentExecutionContext: Bool {
        return queueContextEquatable.isCurrentExecutionContext
    }

    private let backingQueue: Foundation.DispatchQueue
    private let queueContextEquatable: QueueContextEquatable

    /// A new `DispatchQueue` from a `Foundation.DispatchQueue` instance.
    /// - warning: The `context` instance must be retained for the life of the `backingQueue` for unique pointer comparison.
    /// - parameter backingQueue: The underlying queue this instance dispatches to.
    /// - parameter context: The `QueueContext` that will `setSpecitif(key:value:)` to the `backingQueue`.
    public init<ContextValue: Equatable>(backingQueue: Foundation.DispatchQueue,
                                         context: QueueContext<ContextValue>) {
        self.backingQueue = backingQueue
        self.queueContextEquatable = context
        backingQueue.setSpecific(key: context.key, value: context.value)
    }

    /// A new `DispatchQueue` from a `Foundation.DispatchQueue` instance.
    /// A `DefaultQueueContext` will `setSpecitif(key:value:)` to the `backingQueue`.
    /// - warning: The `DefaultQueueContext` instance interanlly set must be retained for the life of the `backingQueue` for unique pointer comparison.
    public init(backingQueue: Foundation.DispatchQueue) {
        self.init(backingQueue: backingQueue,
                  context: DefaultQueueContext())
    }

    /// A new `DispatchQueue`.
    /// - parameter label: A string label to attach to the queue to uniquely identify it in debugging tools such as Instruments, sample, stackshots, and crash reports.
    ///                    Because applications, libraries, and frameworks can all create their own dispatch queues, a reverse-DNS naming style (com.example.myqueue) is recommended.
    /// - parameter qualityOfService: The quality-of-service level to associate with the queue. This value determines the priority at which the system schedules tasks for execution.
    /// - parameter concurrent: If `true` creates a dispatch queue that executes tasks concurrently. Defaults to executing tasks serially.
    /// - parameter context: The `QueueContext` that will `setSpecitif(key:value:)` to the `backingQueue`.
    public init<ContextValue: Equatable>(label: String,
                                         qualityOfService: QualityOfService,
                                         concurrent: Bool = false,
                                         context: QueueContext<ContextValue>)
    {
        self.backingQueue = Foundation.DispatchQueue(label: label,
                                                     qos: qualityOfService.asDispatchQoS,
                                                     attributes: concurrent ? .concurrent : [])
        self.queueContextEquatable = context
        backingQueue.setSpecific(key: context.key, value: context.value)
    }

    /// A new `DispatchQueue`.
    /// - parameter label: A string label to attach to the queue to uniquely identify it in debugging tools such as Instruments, sample, stackshots, and crash reports.
    ///                    Because applications, libraries, and frameworks can all create their own dispatch queues, a reverse-DNS naming style (com.example.myqueue) is recommended.
    /// - parameter qualityOfService: The quality-of-service level to associate with the queue. This value determines the priority at which the system schedules tasks for execution.
    /// - parameter concurrent: If `true` creates a dispatch queue that executes tasks concurrently. Defaults to executing tasks serially.
    public init(label: String,
                qualityOfService: QualityOfService,
                concurrent: Bool = false) {
        self.init(label: label,
                  qualityOfService: qualityOfService,
                  concurrent: concurrent,
                  context: DefaultQueueContext())
    }

    public func async(delay: TimeInterval = 0, execute work: @escaping () -> Void) {
        #if DEBUG
            if let handler = TestingOverrides.asyncHandler {
                handler(work)
            }
        #endif
        if delay == 0 {
            backingQueue.async(execute: work)
        } else {
            backingQueue.asyncAfter(deadline: delay.dispatchTimeSinceNow, execute: work)
        }
    }

    public func async(delay: TimeInterval = 0, execute workItem: DispatchWorkItem) {
        #if DEBUG
            if let handler = TestingOverrides.asyncWorkItemHandler {
                handler(workItem)
            }
        #endif
        if delay == 0 {
            backingQueue.async(execute: workItem)
        } else {
            backingQueue.asyncAfter(deadline: delay.dispatchTimeSinceNow, execute: workItem)
        }
    }

    public func sync<T>(_ closure: () -> T) -> T {
        if isCurrentExecutionContext {
            return closure()
        } else {
            return backingQueue.sync(execute: closure)
        }
    }

    public func asyncBarrier(execute work: @escaping () -> Void) {
        #if DEBUG
            if let handler = TestingOverrides.asyncHandler {
                handler(work)
            }
        #endif
        backingQueue.async(flags: .barrier, execute: work)
    }

    public func waitForQueueToDrain(execute work: @escaping () -> Void = {}) {
        backingQueue.sync(flags: .barrier, execute: work)
    }

    public func suspend() {
        backingQueue.suspend()
    }

    public func resume() {
        backingQueue.resume()
    }

    public func schedule(options: Foundation.DispatchQueue.SchedulerOptions? = nil, _ action: @escaping () -> Void) {
        #if DEBUG
            if TestingOverrides.immediateScheduler {
                action()
                return
            }
        #endif
        backingQueue.schedule(action)
    }

    public func schedule(after date: Foundation.DispatchQueue.SchedulerTimeType,
                         tolerance: Foundation.DispatchQueue.SchedulerTimeType.Stride,
                         options: Foundation.DispatchQueue.SchedulerOptions? = nil,
                         _ action: @escaping () -> Void) {
        #if DEBUG
            if TestingOverrides.immediateScheduler {
                action()
                return
            }
        #endif
        backingQueue.schedule(after: date,
                              tolerance: tolerance,
                              options: nil,
                              action)
    }

    public func schedule(after date: Foundation.DispatchQueue.SchedulerTimeType,
                         interval: Foundation.DispatchQueue.SchedulerTimeType.Stride,
                         tolerance: Foundation.DispatchQueue.SchedulerTimeType.Stride,
                         options: Foundation.DispatchQueue.SchedulerOptions? = nil,
                         _ action: @escaping () -> Void) -> Cancellable {
        #if DEBUG
            if TestingOverrides.immediateScheduler {
                action()
                return AnyCancellable {}
            }
        #endif
        return backingQueue.schedule(after: date,
                                     interval: interval,
                                     tolerance: tolerance,
                                     options: options,
                                     action)
    }

    #if DEBUG
        public struct TestingOverrides {
            public static var asyncHandler: ((_ closure: @escaping () -> Void) -> Void)?
            public static var asyncWorkItemHandler: ((_ workItem: DispatchWorkItem) -> Void)?
            public static var immediateScheduler: Bool = false
        }
    #endif
}

extension TimeInterval {
    fileprivate var dispatchTimeSinceNow: DispatchTime {
        DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(self * 1000))
    }
}
