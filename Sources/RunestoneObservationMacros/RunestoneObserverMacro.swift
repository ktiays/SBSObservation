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
            try makeObserverRegistrarVariable(),
            try makeObserveFunction()
        ]
    }
}

private extension RunestoneObserverMacro {
    private static func makeObserverRegistrarVariable() throws -> DeclSyntax {
        let syntax = try VariableDeclSyntax(
           """
           private let _observerRegistrar = RunestoneObservation.ObserverRegistrar()
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
               _observerRegistrar.registerObserver(
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
