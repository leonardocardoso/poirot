import Foundation

/// Monitors a directory for file system changes using GCD dispatch sources.
/// Triggers a callback when files are created, modified, or deleted.
@Observable
final class FileWatcher {
    private(set) var lastChangeDate: Date?

    private var source: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1
    private var debounceTask: Task<Void, Never>?
    private let debounceInterval: Duration
    private let onChange: @MainActor () -> Void

    init(debounceInterval: Duration = .seconds(1), onChange: @escaping @MainActor () -> Void) {
        self.debounceInterval = debounceInterval
        self.onChange = onChange
    }

    /// Starts monitoring the given directory path for changes.
    func start(path: String) {
        stop()

        let fd = open(path, O_EVTONLY)
        guard fd >= 0 else { return }
        fileDescriptor = fd

        let src = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .rename, .delete, .extend],
            queue: .global(qos: .utility)
        )

        src.setEventHandler { @Sendable [weak self] in
            Task { @MainActor [weak self] in
                self?.handleChange()
            }
        }

        src.setCancelHandler { @Sendable in
            close(fd)
        }

        source = src
        src.resume()
    }

    /// Stops monitoring.
    func stop() {
        debounceTask?.cancel()
        debounceTask = nil
        source?.cancel()
        source = nil
        fileDescriptor = -1
    }

    private func handleChange() {
        debounceTask?.cancel()

        debounceTask = Task {
            try? await Task.sleep(for: debounceInterval)
            guard !Task.isCancelled else { return }
            lastChangeDate = Date()
            onChange()
        }
    }
}
