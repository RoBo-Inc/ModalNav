import ComposableArchitecture
import SwiftUI

@Reducer
struct Modal {
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case showAlertButtonPressed(AlertState<Action.Alert>)
        case alert(PresentationAction<Action.Alert>)
        
        enum Alert {
            case closeModalButtonPressed
            case doSmthElseButtonPressed
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showAlertButtonPressed(let alertState):
                state.alert = alertState
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

extension AlertState where Action == Modal.Action.Alert {
    static let closeModal: Self = .init {
        TextState("Close Model Alert")
    } actions: {
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
        ButtonState(action: .closeModalButtonPressed) {
            TextState("Close modal")
        }
    }
    
    static let doSmthElse: Self = .init {
        TextState("Do Smth Else Alert")
    } actions: {
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
        ButtonState(action: .doSmthElseButtonPressed) {
            TextState("Do smth else")
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

