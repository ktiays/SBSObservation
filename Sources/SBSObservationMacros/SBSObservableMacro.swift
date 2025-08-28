import SwiftSyntax
import SwiftCompilerPluginMessageHandling
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct SBSObservableMacro {}

extension SBSObservableMacro: MemberAttributeMacro {
    private static let trackedMacroName = "SBSObservationTracked"
    private static let ignoredMacroName = "SBSObservationIgnored"

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

extension SBSObservableMacro: MemberMacro {
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
                    message: SBSMacroDiagnostic.onlyApplicableToClass
                )
            ])
        }
        let typeName = identified.name.text
        return [
            try makeObservableRegistrarVariable(forTypeNamed: typeName)
        ]
    }
}

private extension SBSObservableMacro {
    private static func makeObservableRegistrarVariable(forTypeNamed typeName: String) throws -> DeclSyntax {
        let syntax = try VariableDeclSyntax(
           """
           private let _observableRegistrar = SBSObservation.ObservableRegistrar()
           """
        )
        return DeclSyntax(syntax)
    }
}
