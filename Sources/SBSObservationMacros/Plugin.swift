import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SBSObservableMacro.self,
        SBSObservationTrackedMacro.self,
        SBSObservationIgnoredMacro.self,
        SBSObserverMacro.self
    ]
}
