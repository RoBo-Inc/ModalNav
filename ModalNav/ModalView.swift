import ComposableArchitecture
import SwiftUI
import TCAExtras

@Reducer
struct Modal {
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Alert.Action>?
    }
    
    enum Action {
        case showAlertButtonPressed(Alert)
        case alert(PresentationAction<Alert.Action>)
    }
    
    enum Alert: CaseIterable {
        case closeModal
        case doSmthElse
        
        @CasePathable
        enum Action {
            case closeModalButtonPressed
            case doSmthElseButtonPressed
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showAlertButtonPressed(let alert):
                state.alert = .init(alert)
                return .none
            case .alert(let action):
                switch action {
                case .presented(.closeModalButtonPressed):
                    return .run { _ in
                        @Dependency(\.dismiss) var dismiss
                        await dismiss()
                    }
                case .presented(.doSmthElseButtonPressed):
                    // do something else here
                    return .none
                case .dismiss:
                    return .none
                }
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension Modal.Alert: AlertStateConvertible {
    var title: String {
        switch self {
        case .closeModal: "Close Model Alert"
        case .doSmthElse: "Do Smth Else Alert"
        }
    }
}

extension Modal.Alert.Action: AlertAction {
    var buttonLabel: String {
        switch self {
        case .closeModalButtonPressed: "Close modal"
        case .doSmthElseButtonPressed: "Do smth else"
        }
    }
}

struct ModalView: View {
    @Bindable var store: StoreOf<Modal>
    
    var body: some View {
        VStack {
            Button("Show Close Model Alert") {
                store.send(.showAlertButtonPressed(.closeModal))
            }
            Button("Show Do Smth Else Alert") {
                store.send(.showAlertButtonPressed(.doSmthElse))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cyan)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    ModalView(
        store: .init(initialState: .init()) {
            Modal()
        }
    )
}

