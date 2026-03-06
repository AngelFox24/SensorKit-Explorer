import SwiftUI

struct PermisionView: View {
    @State private var viewModel: PermisionViewModel
    @Binding var viewStatus: ViewStatus
    let viewType: ViewsWithPermisions
    init(for viewType: ViewsWithPermisions, viewStatus: Binding<ViewStatus>, container: DIContainer) {
        self.viewType = viewType
        self._viewStatus = viewStatus
        self._viewModel = State(initialValue: PermisionViewModelBuilder.getViewModel(for: viewType, container: container))
    }
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image(systemName: viewModel.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                Text(viewModel.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(viewModel.message)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                if let buttonInfo = viewModel.buttonInfo {
                    Button {
                        viewModel.mainButtonAction(for: buttonInfo)
                    } label: {
                        Text(buttonInfo.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)

                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
                }
            }
            .padding()
        }
        .onChange(of: viewModel.viewStatus) { _, newValue in
            self.viewStatus = newValue
        }
        .task(id: viewModel.pendingPermissionsCount) {
            await self.viewModel.startRequestPermisions()
        }
    }
}
