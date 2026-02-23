@testable import Poirot
import Testing

@Suite("UpdateChecker")
struct UpdateCheckerTests {
    // MARK: - isNewer

    @Test
    func isNewer_higherMajor_returnsTrue() {
        #expect(UpdateChecker.isNewer(remote: "2.0.0", current: "1.0.0"))
    }

    @Test
    func isNewer_higherMinor_returnsTrue() {
        #expect(UpdateChecker.isNewer(remote: "1.1.0", current: "1.0.0"))
    }

    @Test
    func isNewer_higherPatch_returnsTrue() {
        #expect(UpdateChecker.isNewer(remote: "1.0.1", current: "1.0.0"))
    }

    @Test
    func isNewer_sameVersion_returnsFalse() {
        #expect(!UpdateChecker.isNewer(remote: "1.0.0", current: "1.0.0"))
    }

    @Test
    func isNewer_lowerVersion_returnsFalse() {
        #expect(!UpdateChecker.isNewer(remote: "1.0.0", current: "2.0.0"))
    }

    @Test
    func isNewer_lowerMinor_returnsFalse() {
        #expect(!UpdateChecker.isNewer(remote: "1.0.0", current: "1.1.0"))
    }

    @Test
    func isNewer_differentLengths_handledCorrectly() {
        #expect(UpdateChecker.isNewer(remote: "1.0.1", current: "1.0"))
        #expect(!UpdateChecker.isNewer(remote: "1.0", current: "1.0.1"))
    }

    @Test
    func isNewer_singleComponent_works() {
        #expect(UpdateChecker.isNewer(remote: "2", current: "1"))
        #expect(!UpdateChecker.isNewer(remote: "1", current: "2"))
    }

    @Test
    func isNewer_emptyStrings_returnsFalse() {
        #expect(!UpdateChecker.isNewer(remote: "", current: ""))
        #expect(!UpdateChecker.isNewer(remote: "", current: "1.0.0"))
    }

    @Test
    func isNewer_largeVersionNumbers_works() {
        #expect(UpdateChecker.isNewer(remote: "10.20.30", current: "10.20.29"))
        #expect(!UpdateChecker.isNewer(remote: "10.20.30", current: "10.20.31"))
    }
}
