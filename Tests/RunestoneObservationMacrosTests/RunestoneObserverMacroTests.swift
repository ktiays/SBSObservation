import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
#if canImport(RunestoneObservationMacros)
import RunestoneObservationMacros

private let testMacros: [String: Macro.Type] = [
    "RunestoneObserver": RunestoneObserverMacro.self
]
#endif

final class RunestoneObserverMacroTests: XCTestCase {
    func test_it_generates_observer_conformance() throws {
        #if canImport(RunestoneObservationMacros)
        assertMacroExpansion(
            """
            @RunestoneObserver
            final class ViewModel {

            }
            """,
            expandedSource: """
            final class ViewModel {

                private let _observerRegistrar = RunestoneObservation.ObserverRegistrar()

                @discardableResult
                private func observe<T>(
                    _ tracker: @autoclosure () -> T,
                    receiving changeType: RunestoneObservation.PropertyChangeType = .didSet,
                    options: RunestoneObservation.ObservationOptions = [],
                    handler: @escaping RunestoneObservation.ObservationChangeHandler<T>
                ) -> RunestoneObservation.Observation {
                    _observerRegistrar.registerObserver(
                        tracking: tracker,
                        receiving: changeType,
                        options: options,
                        handler: handler
                    )
                }

            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
