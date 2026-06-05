import SwiftUI

#if canImport(PakFitCore)
import PakFitCore
#endif

@main
struct PakFitIOSApp: App {
    var body: some Scene {
        WindowGroup {
            PakFitRootView()
        }
    }
}
