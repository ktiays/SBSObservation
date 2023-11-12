import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
#if canImport(RunestoneObservationMacros)
import RunestoneObservationMacros

private let testMacros: [String: Macro.Type] = [
    "RunestoneObservationTracked": RunestoneObservationTrackedMacro.self
]
#endif

final class RunestoneObservationTrackedMacroTests: XCTestCase {
    func testItExpandsRunestoneObservationTracked() throws {
        #if canImport(RunestoneObservationMacros)
        assertMacroExpansion(
            """
            final class ViewModel {
                @RunestoneObservationTracked
                var foo: String = ""
            }
            """,
            expandedSource: """
            final class ViewModel {
                var foo: String = "" {
                    willSet {
                        if newValue != foo {
                            _observableRegistry.publishChange(
                                ofType: .willSet,
                                changing: \\.foo,
                                on: self,
                                from: foo,
                                to: newValue
                            )
                        }
                    }
                    didSet {
                        if foo != oldValue {
                            _observableRegistry.publishChange(
                                ofType: .didSet,
                                changing: \\.foo,
                                on: self,
                                from: oldValue,
                                to: foo
                            )
                        }
                    }
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
