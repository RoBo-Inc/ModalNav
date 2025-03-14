import SwiftUI

@main
struct ModalNavApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: .init(initialState: .init()) {
                    Content()
                }
            )
        }
    }
}
