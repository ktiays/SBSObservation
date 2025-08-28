import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
#if canImport(SBSObservationMacros)
import SBSObservationMacros

private let testMacros: [String: Macro.Type] = [
    "SBSObservationTracked": SBSObservationTrackedMacro.self
]
#endif

final class SBSObservationTrackedMacroTests: XCTestCase {
    func test_it_generates_will_set_and_did_set() throws {
        #if canImport(SBSObservationMacros)
        assertMacroExpansion(
            """
            final class ViewModel {
                @SBSObservationTracked
                var foo: String = ""
            }
            """,
            expandedSource: """
            final class ViewModel {
                var foo: String = "" {
                    @storageRestrictions(initializes: _foo)
                    init(initialValue) {
                        _foo = initialValue
                    }
                    set {
                        _observableRegistrar.withMutation(
                            of: \\.foo,
                            on: self,
                            changingFrom: foo,
                            to: newValue
                        ) {
                            _foo = newValue
                        }
                    }
                    get {
                         _observableRegistrar.access(\\.foo, on: self)
                         return _foo
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
