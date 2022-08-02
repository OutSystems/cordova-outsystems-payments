import PassKit

protocol OSPMTWalletAvailabilityDelegate: AnyObject {
    static func isWalletAvailable() -> Bool
}

extension PKPassLibrary: OSPMTWalletAvailabilityDelegate {
    static func isWalletAvailable() -> Bool {
        Self.isPassLibraryAvailable()
    }
}
