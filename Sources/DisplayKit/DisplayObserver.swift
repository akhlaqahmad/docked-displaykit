import AppKit
import AppCore

/// Tracks `NSScreen` connections and emits `onChange` whenever screen parameters change
/// (resolution, arrangement, attach/detach). Used by `DockWindowOrchestrator` to
/// reposition/hide dock panels in response to display configuration changes.
@MainActor
public final class DisplayObserver {
    public var onChange: (() -> Void)?
    private var observer: NSObjectProtocol?

    public init() {}

    public func start() {
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onChange?()
        }
    }

    public func stop() {
        if let observer { NotificationCenter.default.removeObserver(observer) }
        observer = nil
    }

    public var screens: [NSScreen] { NSScreen.screens }

    public func currentIdentifiers() -> [ScreenIdentifier] {
        NSScreen.screens.map { ScreenIdentifier(displayUUID: $0.docked_uuid, localizedName: $0.localizedName) }
    }

    public func screen(for id: ScreenIdentifier?) -> NSScreen? {
        guard let id else { return nil }
        return NSScreen.screens.first { $0.docked_uuid == id.displayUUID }
    }
}

public extension NSScreen {
    /// Stable hardware UUID for this `NSScreen`. Survives reconnects (unlike `displayID`,
    /// which can change), so we persist this rather than the `CGDirectDisplayID`.
    var docked_uuid: String {
        guard let number = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return localizedName
        }
        let displayID = CGDirectDisplayID(number.uint32Value)
        guard let cfUUID = CGDisplayCreateUUIDFromDisplayID(displayID) else {
            return "display-\(number.uint32Value)"
        }
        let uuid = cfUUID.takeRetainedValue()
        if let str = CFUUIDCreateString(nil, uuid) as String? { return str }
        return "display-\(number.uint32Value)"
    }
}
