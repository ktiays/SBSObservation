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
            try makeObserverRegistryVariable(),
            try makeObserveFunction(),
            try makeCancelObservationFunction()
        ]
    }
}

extension RunestoneObserverMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
           throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: declaration,
                    message: RunestoneMacroDiagnostic.onlyApplicableToClass
                )
            ])
        }
        let className = classDecl.name.text
        let syntax = try ExtensionDeclSyntax(
           """
           extension \(raw: className): RunestoneObservationMacro.Observer {}
           """
        )
        return [syntax]
    }
}

private extension RunestoneObserverMacro {
    private static func makeObserverRegistryVariable() throws -> DeclSyntax {
        let syntax = try VariableDeclSyntax(
           """
           private let _observerRegistry = RunestoneObservationMacro.ObserverRegistry()
           """
        )
        return DeclSyntax(syntax)
    }

    private static func makeObserveFunction() throws -> DeclSyntax {
        let syntax = try FunctionDeclSyntax(
           """
           func observe<T: RunestoneObservationMacro.Observable, U>(
               _ keyPath: KeyPath<T, U>,
               of observable: T,
               receiving changeType: RunestoneObservationMacro.PropertyChangeType = .didSet,
               options: RunestoneObservationMacro.ObservationOptions = [],
               handler: @escaping RunestoneObservationMacro.ObservationChangeHandler<U>
           ) {
               _observerRegistry.registerObserver(
                   observing: keyPath,
                   on: observable,
                   receiving: changeType,
                   options: options,
                   handler: handler
               )
           }
           """
        )
        return DeclSyntax(syntax)
    }

    private static func makeCancelObservationFunction() throws -> DeclSyntax {
        let syntax = try FunctionDeclSyntax(
           """
           func cancelObservation(withId observationId: RunestoneObservationMacro.ObservationId) {
               _observerRegistry.cancelObservation(withId: observationId)
           }
           """
        )
        return DeclSyntax(syntax)
    }
}
