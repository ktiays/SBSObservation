import SwiftSyntax
import SwiftCompilerPluginMessageHandling
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct RunestoneObserverMacro {}

extension RunestoneObserverMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else {
            let diagnostic = Diagnostic(
                node: declaration,
                message: RunestoneMacroDiagnostic.onlyApplicableToClass
            )
            context.diagnose(diagnostic)
            return []
        }
        return [
            try makeObservationRegistrarVariable(),
            try makeObserveFunction()
        ]
    }
}

private extension RunestoneObserverMacro {
    private static func makeObservationRegistrarVariable() throws -> DeclSyntax {
        let syntax = try VariableDeclSyntax(
           """
           private let _observationRegistrar = RunestoneObservation.ObservationRegistrar()
           """
        )
        return DeclSyntax(syntax)
    }

    private static func makeObserveFunction() throws -> DeclSyntax {
        let syntax = try FunctionDeclSyntax(
           """
           func observe<T>(
               _ tracker: @autoclosure () -> T,
               receiving changeType: RunestoneObservation.PropertyChangeType = .didSet,
               options: RunestoneObservation.ObservationOptions = [],
               handler: @escaping RunestoneObservation.ObservationChangeHandler<T>
           ) {
               _observationRegistrar.registerObserver(
                   tracking: tracker(),
                   receiving: changeType,
                   options: options,
                   handler: handler
               )
           }
           """
        )
        return DeclSyntax(syntax)
    }
}
