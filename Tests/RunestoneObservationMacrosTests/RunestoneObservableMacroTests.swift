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
    func testItGeneratesGeneratesObservableConformance() throws {
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

                private let _observableRegistry = RunestoneObservationMacro.ObservableRegistry<ViewModel>()

                func registerObserver<T>(
                    _ observer: some RunestoneObservationMacro.Observer,
                    observing keyPath: KeyPath<ViewModel, T>,
                    receiving changeType: RunestoneObservationMacro.PropertyChangeType,
                    options: RunestoneObservationMacro.ObservationOptions = [],
                    handler: @escaping RunestoneObservationMacro.ObservationChangeHandler<T>
                ) -> RunestoneObservationMacro.ObservationId {
                    return _observableRegistry.registerObserver(
                        observer,
                        observing: keyPath,
                        on: self,
                        receiving: changeType,
                        options: options,
                        handler: handler
                    )
                }

                func cancelObservation(withId observationId: RunestoneObservationMacro.ObservationId) {
                    _observableRegistry.cancelObservation(withId: observationId)
                }
            }

            extension ViewModel: RunestoneObservationMacro.Observable {
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testItSkipsTrackingPropertiesAnnotetedWithIgnoringMacro() throws {
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

                private let _observableRegistry = RunestoneObservationMacro.ObservableRegistry<ViewModel>()

                func registerObserver<T>(
                    _ observer: some RunestoneObservationMacro.Observer,
                    observing keyPath: KeyPath<ViewModel, T>,
                    receiving changeType: RunestoneObservationMacro.PropertyChangeType,
                    options: RunestoneObservationMacro.ObservationOptions = [],
                    handler: @escaping RunestoneObservationMacro.ObservationChangeHandler<T>
                ) -> RunestoneObservationMacro.ObservationId {
                    return _observableRegistry.registerObserver(
                        observer,
                        observing: keyPath,
                        on: self,
                        receiving: changeType,
                        options: options,
                        handler: handler
                    )
                }

                func cancelObservation(withId observationId: RunestoneObservationMacro.ObservationId) {
                    _observableRegistry.cancelObservation(withId: observationId)
                }
            }

            extension ViewModel: RunestoneObservationMacro.Observable {
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

    func testItSkipsTrackingPropertiesThatAreAlreadyTracked() throws {
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

                private let _observableRegistry = RunestoneObservationMacro.ObservableRegistry<ViewModel>()

                func registerObserver<T>(
                    _ observer: some RunestoneObservationMacro.Observer,
                    observing keyPath: KeyPath<ViewModel, T>,
                    receiving changeType: RunestoneObservationMacro.PropertyChangeType,
                    options: RunestoneObservationMacro.ObservationOptions = [],
                    handler: @escaping RunestoneObservationMacro.ObservationChangeHandler<T>
                ) -> RunestoneObservationMacro.ObservationId {
                    return _observableRegistry.registerObserver(
                        observer,
                        observing: keyPath,
                        on: self,
                        receiving: changeType,
                        options: options,
                        handler: handler
                    )
                }

                func cancelObservation(withId observationId: RunestoneObservationMacro.ObservationId) {
                    _observableRegistry.cancelObservation(withId: observationId)
                }
            }

            extension ViewModel: RunestoneObservationMacro.Observable {
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
