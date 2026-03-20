import SwiftUI

struct ToastOverlay: View {
    @Environment(AppState.self)
    private var appState

    private var currentToast: Toast? { appState.toastQueue.first }

    var body: some View {
        VStack {
            if let toast = currentToast {
                toastCard(toast)
                    .id(toast.id)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture {
                        if let url = toast.url {
                            NSWorkspace.shared.open(url)
                        }
                        appState.dismissCurrentToast()
                    }
                    .task(id: toast.id) {
                        let duration: Duration = toast.url != nil ? .seconds(10) : .seconds(4)
                        try? await Task.sleep(for: duration)
                        guard !Task.isCancelled else { return }
                        appState.dismissCurrentToast()
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentToast?.id)
        .padding(.top, PoirotTheme.Spacing.md)
        .allowsHitTesting(currentToast != nil)
    }

    private func toastCard(_ toast: Toast) -> some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: toast.icon ?? toast.style.defaultIcon)
                .font(PoirotTheme.Typography.body)
                .foregroundStyle(toast.style.color)
                .symbolEffect(.rotate, isActive: toast.animateIcon)
                .symbolEffect(.bounce, value: toast.animateIcon ? "" : toast.id.uuidString)

            Text(toast.message)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, PoirotTheme.Spacing.lg)
        .padding(.vertical, PoirotTheme.Spacing.md)
        .background {
            GlassBackground(in: .capsule)
            Capsule().fill(toast.style.color.opacity(0.15))
        }
        .overlay {
            Capsule()
                .stroke(toast.style.color.opacity(0.3), lineWidth: 0.5)
        }
    }
}
