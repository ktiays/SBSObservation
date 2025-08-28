import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
#if canImport(SBSObservationMacros)
import SBSObservationMacros

private let testMacros: [String: Macro.Type] = [
    "SBSObservable": SBSObservableMacro.self
]
#endif

final class SBSObservableMacroTests: XCTestCase {
    func test_it_generates_observable_conformance() throws {
        #if canImport(SBSObservationMacros)
        assertMacroExpansion(
            """
            @SBSObservable
            final class ViewModel {
                var foo: String = ""
            }
            """,
            expandedSource: """
            final class ViewModel {
                @SBSObservationTracked
                var foo: String = ""

                private let _observableRegistrar = SBSObservation.ObservableRegistrar()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_it_skips_tracking_properties_withSBSObservationignored_annotation() throws {
        #if canImport(SBSObservationMacros)
        assertMacroExpansion(
            """
            @SBSObservable
            final class ViewModel {
                var foo: String = ""
                @SBSObservationIgnored
                var bar: String = ""
            }
            """,
            expandedSource: """
            final class ViewModel {
                @SBSObservationTracked
                var foo: String = ""
                @SBSObservationIgnored
                var bar: String = ""

                private let _observableRegistrar = SBSObservation.ObservableRegistrar()
            }
            """,
            macros: [
                "SBSObservable": SBSObservableMacro.self
            ]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_it_skips_addingSBSObservationtracked_annotation_when_already_added() throws {
        #if canImport(SBSObservationMacros)
        assertMacroExpansion(
            """
            @SBSObservable
            final class ViewModel {
                @SBSObservationTracked
                var foo: String = ""
            }
            """,
            expandedSource: """
            final class ViewModel {
                @SBSObservationTracked
                var foo: String = ""

                private let _observableRegistrar = SBSObservation.ObservableRegistrar()
            }
            """,
            macros: [
                "SBSObservable": SBSObservableMacro.self
            ]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
