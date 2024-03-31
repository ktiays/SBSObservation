@attached(member, names: named(_observableRegistrar), named(registerObserver), named(cancelObservation))
@attached(memberAttribute)
@attached(extension, conformances: Observable)
public macro RunestoneObservable() = #externalMacro(
    module: "RunestoneObservationMacros",
    type: "RunestoneObservableMacro"
)

@attached(accessor, names: named(willSet))
public macro RunestoneObservationIgnored() = #externalMacro(
    module: "RunestoneObservationMacros",
    type: "RunestoneObservationIgnoredMacro"
)

@attached(accessor, names: named(init), named(get), named(set))
@attached(peer, names: prefixed(`_`))
public macro RunestoneObservationTracked() = #externalMacro(
    module: "RunestoneObservationMacros",
    type: "RunestoneObservationTrackedMacro"
)


@attached(member, names: named(_observerRegistrar), named(observe))
public macro RunestoneObserver() = #externalMacro(
    module: "RunestoneObservationMacros",
    type: "RunestoneObserverMacro"
)
