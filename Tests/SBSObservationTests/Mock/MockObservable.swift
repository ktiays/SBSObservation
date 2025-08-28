@testable import SBSObservation

struct MyEquatableType: Equatable {
    let str: String

    init(_ str: String) {
        self.str = str
    }
}

struct MyNonEquatableType {
    let str: String

    init(_ str: String) {
        self.str = str
    }
}

@SBSObservable
final class MockObservable {
    var str = "foo"
    let equatableObj = MyEquatableType("foo")
    let nonEquatableObj = MyNonEquatableType("foo")
}
