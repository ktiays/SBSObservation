//import Foundation
//import ProxyMacro
//
//protocol IsEnabledStore: AnyObject {
//    var isEnabled: Bool { get }
//}
//
//protocol IsSelectableStore: AnyObject {
//    var isSelectable: Bool { get }
//}
//
//protocol SelectedRangeStore: AnyObject {
//    var selectedRange: NSRange? { get }
//}
//
//public final class TextView {
//    private final class StateStore: IsEnabledStore, IsSelectableStore, SelectedRangeStore, RunestoneObservable {
//        var isEnabled = true {
//            willSet {
//                if newValue != isEnabled {
//                    observableRegistry.publishChange(
//                        ofType: .willSet,
//                        changing: \.isEnabled,
//                        on: self,
//                        from: isEnabled,
//                        to: newValue
//                    )
//                }
//            }
//            didSet {
//                if isEnabled != oldValue {
//                    observableRegistry.publishChange(
//                        ofType: .didSet,
//                        changing: \.isEnabled,
//                        on: self,
//                        from: oldValue,
//                        to: isEnabled
//                    )
//                }
//            }
//        }
//        var isSelectable = true
//        var selectedRange: NSRange?
//
//        private let observableRegistry = ObservableRegistry(for: StateStore.self)
//
//        func registerObserver<ObserverType, T>(
//            _ observer: ObserverType,
//            observing keyPath: KeyPath<TextView.StateStore, T>,
//            receiving changeType: ObservationChangeType,
//            handler: @escaping ObservationChangeHandler<T>
//        ) {
//
//        }
//
//        func deregisterObserver<ObserverType: RunestoneObserver>(_ observer: ObserverType) {
//            observableRegistry.deregisterObserver(observer)
//        }
//    }
//
//    @Proxy(\TextView.stateStore.isEnabled)
//    public var isEnabled: Bool
//    @Proxy(\TextView.stateStore.isSelectable)
//    public var isSelectable: Bool
//    @Proxy(\TextView.stateStore.selectedRange)
//    public var selectedRange: NSRange?
//
//    private let stateStore = StateStore()
//    private let childA: ChildA<StateStore>
//
//    public init() {
//        childA = ChildA(stateStore: stateStore)
//    }
//}
//
//final class ChildA<StateStore: IsEnabledStore & IsSelectableStore & RunestoneObservable> {
//    let stateStore: StateStore
//
//    private let observerRegistry = ObserverRegistry()
//
//    init(stateStore: StateStore) {
//        self.stateStore = stateStore
//    }
//
//    func observe<T: RunestoneObservable, U>(
//        of keyPath: KeyPath<T, U>,
//        on observable: T,
//        receiving changeType: ObservationChangeType = .didSet,
//        handler: @escaping ObservationChangeHandler<U>
//    ) {
//
//    }
//}
