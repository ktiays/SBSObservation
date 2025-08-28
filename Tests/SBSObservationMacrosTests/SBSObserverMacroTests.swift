import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
#if canImport(SBSObservationMacros)
import SBSObservationMacros

private let testMacros: [String: Macro.Type] = [
    "SBSObserver": SBSObserverMacro.self
]
#endif

final class SBSObserverMacroTests: XCTestCase {
    func test_it_generates_observer_conformance() throws {
        #if canImport(SBSObservationMacros)
        assertMacroExpansion(
            """
            @SBSObserver
            final class ViewModel {

            }
            """,
            expandedSource: """
            final class ViewModel {

                private let _observerRegistrar = SBSObservation.ObserverRegistrar()

                @discardableResult
                private func observe<T>(
                    _ tracker: @autoclosure () -> T,
                    receiving changeType: SBSObservation.PropertyChangeType = .didSet,
                    options: SBSObservation.ObservationOptions = [],
                    handler: @escaping SBSObservation.ObservationChangeHandler<T>
                ) -> SBSObservation.Observation {
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
