import SwiftSyntax
import SwiftCompilerPluginMessageHandling
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct RunestoneObservableMacro {}

extension RunestoneObservableMacro: MemberAttributeMacro {
    private static let trackedMacroName = "RunestoneObservationTracked"
    private static let ignoredMacroName = "RunestoneObservationIgnored"

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let variableDecl = member.as(VariableDeclSyntax.self) else {
            return []
        }
        guard variableDecl.isValidForObservation else {
            return []
        }
        guard !variableDecl.hasMacroApplication(trackedMacroName) else {
            return []
        }
        guard !variableDecl.hasMacroApplication(ignoredMacroName) else {
            return []
        }
        return [
            AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier(trackedMacroName)))
        ]
    }
}

extension RunestoneObservableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let identified = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }
        guard identified.is(ClassDeclSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: declaration,
                    message: RunestoneMacroDiagnostic.onlyApplicableToClass
                )
            ])
        }
        let typeName = identified.name.text
        return [
            try makeObservableRegistrarVariable(forTypeNamed: typeName),
//            try makeRegisterObserverFunction(forTypeNamed: typeName),
//            try makeCancelObservationFunction()
        ]
    }
}

extension RunestoneObservableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            let diagnostic = Diagnostic(
                node: declaration,
                message: RunestoneMacroDiagnostic.onlyApplicableToClass
            )
            context.diagnose(diagnostic)
            return []
        }
        let className = classDecl.name.text
        return [
            try ExtensionDeclSyntax(
               """
               extension \(raw: className): RunestoneObservation.Observable {}
               """
            )
        ]
    }
}

private extension RunestoneObservableMacro {
    private static func makeObservableRegistrarVariable(forTypeNamed typeName: String) throws -> DeclSyntax {
        let syntax = try VariableDeclSyntax(
           """
           private let _observableRegistrar = RunestoneObservation.ObservableRegistrar()
           """
        )
        return DeclSyntax(syntax)
    }

    private static func makeRegisterObserverFunction(forTypeNamed typeName: String) throws -> DeclSyntax {
        let syntax = try FunctionDeclSyntax(
           """
           func registerObserver<T>(
               _ observer: some RunestoneObservation.Observer,
               observing keyPath: KeyPath<\(raw: typeName), T>,
               receiving changeType: RunestoneObservation.PropertyChangeType,
               options: RunestoneObservation.ObservationOptions = [],
               handler: @escaping RunestoneObservation.ObservationChangeHandler<T>
           ) -> RunestoneObservation.ObservationId {
               _observableRegistrar.registerObserver(
                   observer,
                   observing: keyPath,
                   on: self,
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
           func cancelObservation(withId observationId: RunestoneObservation.ObservationId) {
               _observableRegistrar.cancelObservation(withId: observationId)
           }
           """
        )
        return DeclSyntax(syntax)
    }
}
