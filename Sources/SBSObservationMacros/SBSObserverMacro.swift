import SwiftSyntax
import SwiftCompilerPluginMessageHandling
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct SBSObserverMacro {}

extension SBSObserverMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else {
            let diagnostic = Diagnostic(
                node: declaration,
                message: SBSMacroDiagnostic.onlyApplicableToClass
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

private extension SBSObserverMacro {
    private static func makeObserverRegistrarVariable() throws -> DeclSyntax {
        let syntax = try VariableDeclSyntax(
           """
           private let _observerRegistrar = SBSObservation.ObserverRegistrar()
           """
        )
        return DeclSyntax(syntax)
    }

    private static func makeObserveFunction() throws -> DeclSyntax {
        let syntax = try FunctionDeclSyntax(
           """
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
           """
        )
        return DeclSyntax(syntax)
    }
}
