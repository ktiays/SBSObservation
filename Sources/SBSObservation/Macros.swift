@attached(member, names: named(_observableRegistrar))
@attached(memberAttribute)
public macro SBSObservable() = #externalMacro(
    module: "SBSObservationMacros",
    type: "SBSObservableMacro"
)

@attached(accessor, names: named(willSet))
public macro SBSObservationIgnored() = #externalMacro(
    module: "SBSObservationMacros",
    type: "SBSObservationIgnoredMacro"
)

@attached(accessor, names: named(init), named(get), named(set))
@attached(peer, names: prefixed(`_`))
public macro SBSObservationTracked() = #externalMacro(
    module: "SBSObservationMacros",
    type: "SBSObservationTrackedMacro"
)


@attached(member, names: named(_observerRegistrar), named(observe), named(cancelObservation))
public macro SBSObserver() = #externalMacro(
    module: "SBSObservationMacros",
    type: "SBSObserverMacro"
)
