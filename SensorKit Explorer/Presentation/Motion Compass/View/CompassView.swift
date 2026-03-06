import SwiftUI

struct CompassView: View {
    @State private var viewModel: CompassViewModel
    init(container: DIContainer) {
        self._viewModel = State(initialValue: CompassViewModelBuilder.getViewModel(container: container))
    }
    var body: some View {
        VStack {
            Text("|")
            Image("compass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(viewModel.rotationAngle)
        }
        .task {
            await self.viewModel.start()
        }
    }
}

#Preview {
    let container = DIContainer()
    CompassView(container: container)
}
