import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
#if canImport(RunestoneObservationMacros)
import RunestoneObservationMacros

private let testMacros: [String: Macro.Type] = [
    "RunestoneObservable": RunestoneObservableMacro.self
]
#endif

final class RunestoneObservableMacroTests: XCTestCase {
    func test_it_generates_observable_conformance() throws {
        #if canImport(RunestoneObservationMacros)
        assertMacroExpansion(
            """
            @RunestoneObservable
            final class ViewModel {
                var foo: String = ""
            }
            """,
            expandedSource: """
            final class ViewModel {
                @RunestoneObservationTracked
                var foo: String = ""

                private let _observableRegistry = RunestoneObservation.ObservableRegistry<ViewModel>()

                func registerObserver<T>(
                    _ observer: some RunestoneObservation.Observer,
                    observing keyPath: KeyPath<ViewModel, T>,
                    receiving changeType: RunestoneObservation.PropertyChangeType,
                    options: RunestoneObservation.ObservationOptions = [],
                    handler: @escaping RunestoneObservation.ObservationChangeHandler<T>
                ) -> RunestoneObservation.ObservationId {
                    return _observableRegistry.registerObserver(
                        observer,
                        observing: keyPath,
                        on: self,
                        receiving: changeType,
                        options: options,
                        handler: handler
                    )
                }

                func cancelObservation(withId observationId: RunestoneObservation.ObservationId) {
                    _observableRegistry.cancelObservation(withId: observationId)
                }
            }

            extension ViewModel: RunestoneObservation.Observable {
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_it_skips_tracking_properties_withRunestoneObservationignored_annotation() throws {
        #if canImport(RunestoneObservationMacros)
        assertMacroExpansion(
            """
            @RunestoneObservable
            final class ViewModel {
                var foo: String = ""
                @RunestoneObservationIgnored
                var bar: String = ""
            }
            """,
            expandedSource: """
            final class ViewModel {
                @RunestoneObservationTracked
                var foo: String = ""
                @RunestoneObservationIgnored
                var bar: String = ""

                private let _observableRegistry = RunestoneObservation.ObservableRegistry<ViewModel>()

                func registerObserver<T>(
                    _ observer: some RunestoneObservation.Observer,
                    observing keyPath: KeyPath<ViewModel, T>,
                    receiving changeType: RunestoneObservation.PropertyChangeType,
                    options: RunestoneObservation.ObservationOptions = [],
                    handler: @escaping RunestoneObservation.ObservationChangeHandler<T>
                ) -> RunestoneObservation.ObservationId {
                    return _observableRegistry.registerObserver(
                        observer,
                        observing: keyPath,
                        on: self,
                        receiving: changeType,
                        options: options,
                        handler: handler
                    )
                }

                func cancelObservation(withId observationId: RunestoneObservation.ObservationId) {
                    _observableRegistry.cancelObservation(withId: observationId)
                }
            }

            extension ViewModel: RunestoneObservation.Observable {
            }
            """,
            macros: [
                "RunestoneObservable": RunestoneObservableMacro.self
            ]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_it_skips_addingRunestoneObservationtracked_annotation_when_already_added() throws {
        #if canImport(RunestoneObservationMacros)
        assertMacroExpansion(
            """
            @RunestoneObservable
            final class ViewModel {
                @RunestoneObservationTracked
                var foo: String = ""
            }
            """,
            expandedSource: """
            final class ViewModel {
                @RunestoneObservationTracked
                var foo: String = ""

                private let _observableRegistry = RunestoneObservation.ObservableRegistry<ViewModel>()

                func registerObserver<T>(
                    _ observer: some RunestoneObservation.Observer,
                    observing keyPath: KeyPath<ViewModel, T>,
                    receiving changeType: RunestoneObservation.PropertyChangeType,
                    options: RunestoneObservation.ObservationOptions = [],
                    handler: @escaping RunestoneObservation.ObservationChangeHandler<T>
                ) -> RunestoneObservation.ObservationId {
                    return _observableRegistry.registerObserver(
                        observer,
                        observing: keyPath,
                        on: self,
                        receiving: changeType,
                        options: options,
                        handler: handler
                    )
                }

                func cancelObservation(withId observationId: RunestoneObservation.ObservationId) {
                    _observableRegistry.cancelObservation(withId: observationId)
                }
            }

            extension ViewModel: RunestoneObservation.Observable {
            }
            """,
            macros: [
                "RunestoneObservable": RunestoneObservableMacro.self
            ]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
