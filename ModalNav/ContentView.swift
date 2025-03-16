import ComposableArchitecture
import SwiftUI

@Reducer
struct Content {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case showButtonPressed
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    enum Destination {
        case modal(Modal)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showButtonPressed:
                state.destination = .modal(.init())
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Content.Destination.State: Equatable {}

struct ContentView: View {
    @Bindable var store: StoreOf<Content>
    
    var body: some View {
        Button("Show") {
            store.send(.showButtonPressed)
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.modal, action: \.destination.modal),
            content: ModalView.init
        )
    }
}

#Preview {
    ContentView(
        store: .init(initialState: .init()) {
            Content()
        }
    )
}
