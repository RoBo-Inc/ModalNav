import ComposableArchitecture
import SwiftUI

@Reducer
struct Content {
    @Reducer(state: .equatable)
    enum Destination {
        case modal(Modal)
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    enum Action: BindableAction {
        case showButtonPressed
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showButtonPressed:
                state.destination = .modal(.init())
                return .none
            case .destination(.presented(.modal(.alert(.presented(.closeModalButtonPressed))))):
                state.destination = nil
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        BindingReducer()
    }
}

struct ContentView: View {
    @Bindable var store = StoreOf<Content>(initialState: .init()) {
        Content()
    }
    
    var body: some View {
        Button("Show") {
            store.send(.showButtonPressed)
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.modal,
                action: \.destination.modal
            )
        ) { store in
            ModalView(store: store)
        }
    }
}

#Preview {
    ContentView()
}
