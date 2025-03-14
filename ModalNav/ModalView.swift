import ComposableArchitecture
import SwiftUI

@Reducer
struct Modal {
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action: BindableAction {
        case showAlertButtonPressed
        case alert(PresentationAction<Action.Alert>)
        case binding(BindingAction<State>)
        
        enum Alert {
            case closeModalButtonPressed
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showAlertButtonPressed:
                state.alert = .init(
                    title: { TextState("Alert") },
                    actions: { ButtonState(action: .closeModalButtonPressed, label: { TextState("Close modal") }) }
                )
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        BindingReducer()
    }
}

struct ModalView: View {
    @Bindable var store: StoreOf<Modal>
    
    var body: some View {
        VStack {
            Button("Show Alert") {
                store.send(.showAlertButtonPressed)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cyan)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
