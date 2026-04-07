import SwiftUI
import AppKit
import Foundation

@main
struct CodexClipboardControlApp: App {
    @StateObject private var model = ClipboardControlModel()

    var body: some Scene {
        WindowGroup("Codex Clipboard Control") {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 720, idealWidth: 760, maxWidth: 840,
                       minHeight: 560, idealHeight: 620, maxHeight: 760)
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @EnvironmentObject private var model: ClipboardControlModel
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("codexClipboardThemeMode") private var themeModeRaw = ThemeMode.system.rawValue
    @State private var showAdvanced = false

    private var themeMode: ThemeMode {
        ThemeMode(rawValue: themeModeRaw) ?? .system
    }

    private var effectiveColorScheme: ColorScheme {
        themeMode.colorScheme ?? systemColorScheme
    }

    private var palette: ThemePalette {
        ThemePalette(colorScheme: effectiveColorScheme)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                quickStartCard
                howToCard
                advancedCard
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [
                    palette.backgroundStart,
                    palette.backgroundEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .preferredColorScheme(themeMode.colorScheme)
        .onAppear {
            model.start()
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(palette.iconPanel)
                    .frame(width: 72, height: 72)
                Image(systemName: "paperclip.circle.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(palette.iconSymbol)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Codex Clipboard Control")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText)
                Text("这是截图粘贴助手的总开关。你日常只需要看它是不是运行中。")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 12) {
                statusPill
                Picker("主题", selection: $themeModeRaw) {
                    ForEach(ThemeMode.allCases) { mode in
                        Text(mode.title).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 250)
            }
        }
    }

    private var statusPill: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(model.isRunning ? palette.statusOn : palette.statusOff)
                .frame(width: 10, height: 10)
            Text(model.statusLabel)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(palette.pillText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(palette.pillBackground)
        )
    }

    private var quickStartCard: some View {
        Card(title: "一眼看懂", palette: palette) {
            VStack(alignment: .leading, spacing: 18) {
                Text(model.isRunning ? "现在可以直接用了" : "现在还没开启")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText)

                Text(model.isRunning ? "你现在可以在终端/Codex 里直接截图，然后按 `Cmd+V`。" : "点下面这个大按钮启用监听器，启用后就能在终端里直接截图粘贴。")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryText)

                HStack(spacing: 14) {
                    ActionButton(
                        title: model.isRunning ? "重启并保持可用" : "立即启用",
                        systemImage: model.isRunning ? "arrow.clockwise.circle.fill" : "play.circle.fill",
                        tint: Color(red: 0.18, green: 0.56, blue: 0.35)
                    ) {
                        model.enableOrRestart()
                    }

                    ActionButton(
                        title: "暂时关闭",
                        systemImage: "pause.circle.fill",
                        tint: Color(red: 0.78, green: 0.27, blue: 0.21)
                    ) {
                        model.disable()
                    }
                }

                HStack(spacing: 12) {
                    SimpleBadge(label: "后台监听器", value: model.isRunning ? "运行中" : "未运行", palette: palette)
                    SimpleBadge(label: "缓存截图", value: "\(model.cacheCount) 张", palette: palette)
                    SimpleBadge(label: "最近刷新", value: model.lastRefreshText, palette: palette)
                }

                if let errorMessage = model.lastError, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.errorText)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(palette.errorBackground)
                        )
                }
            }
        }
    }

    private var howToCard: some View {
        Card(title: "怎么用", palette: palette) {
            VStack(alignment: .leading, spacing: 16) {
                StepRow(number: "1", title: "确认是运行中", detail: "打开这个面板时，只要顶部显示“运行中”就行。", palette: palette)
                StepRow(number: "2", title: "在终端里正常截图", detail: "用 iShot 或你原来的截图方式都可以，不需要额外按钮。", palette: palette)
                StepRow(number: "3", title: "回到 Codex 直接 `Cmd+V`", detail: "在终端/Codex 里会粘贴成图片路径，去微信/飞书又会恢复成图片。", palette: palette)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(palette.softBackground)
                    .overlay(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("什么时候需要打开这个面板？")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(palette.primaryText)
                            Text("只有两种情况：功能失效时点“重启并保持可用”，或者你想临时停掉它。平时不用一直盯着。")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(palette.detailText)
                        }
                        .padding(16)
                    }
                    .frame(height: 92)
            }
        }
    }

    private var advancedCard: some View {
        Card(title: "高级工具箱", palette: palette) {
            DisclosureGroup(isExpanded: $showAdvanced) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        ActionButton(title: "打开缓存目录",
                                     systemImage: "folder.fill",
                                     tint: Color(red: 0.88, green: 0.56, blue: 0.18)) {
                            model.openCacheDirectory()
                        }

                        ActionButton(title: "打开日志",
                                     systemImage: "doc.text.fill",
                                     tint: Color(red: 0.30, green: 0.42, blue: 0.82)) {
                            model.openLogFile()
                        }
                    }

                    HStack(spacing: 12) {
                        ActionButton(title: "清空缓存截图",
                                     systemImage: "trash.fill",
                                     tint: Color(red: 0.52, green: 0.32, blue: 0.78)) {
                            model.clearCache()
                        }

                        ActionButton(title: "清空日志",
                                     systemImage: "eraser.fill",
                                     tint: Color(red: 0.17, green: 0.60, blue: 0.72)) {
                            model.clearLogs()
                        }
                    }

                    Button {
                        model.refresh()
                    } label: {
                        Label("立即刷新状态", systemImage: "arrow.triangle.2.circlepath")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(palette.primaryText)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 14) {
                        metricRow(label: "缓存大小", value: model.cacheSizeText)
                        metricRow(label: "最近截图", value: model.latestCaptureName)
                        metricRow(label: "控制面板", value: model.appBundlePath)
                        metricRow(label: "缓存目录", value: model.cacheDirectoryPath)
                        metricRow(label: "主日志", value: model.logPath)

                        if let message = model.statusMessage, !message.isEmpty {
                            Text(message)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(palette.tertiaryText)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(palette.logBackground)
                                )
                        }
                    }

                    ScrollView {
                        Text(model.logTail)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(palette.monospaceText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(14)
                    }
                    .frame(minHeight: 180)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(palette.logBackground)
                    )
                }
                .padding(.top, 14)
            } label: {
                HStack {
                    Text(showAdvanced ? "收起高级内容" : "展开高级内容")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.primaryText)
                    Spacer()
                    Text("日志、路径、清理")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.mutedText)
                }
            }
        }
    }

    private func metricRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(palette.mutedText)
                .frame(width: 88, alignment: .leading)
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
}

struct Card<Content: View>: View {
    let title: String
    let palette: ThemePalette
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(palette.primaryText)
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(palette.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(palette.cardBorder, lineWidth: 1)
        )
        .shadow(color: palette.shadowColor, radius: 16, x: 0, y: 12)
    }
}

struct ActionButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .bold))
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tint)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SimpleBadge: View {
    let label: String
    let value: String
    let palette: ThemePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(palette.mutedText)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(palette.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.softBackground)
        )
    }
}

struct StepRow: View {
    let number: String
    let title: String
    let detail: String
    let palette: ThemePalette

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(palette.stepCircle)
                    .frame(width: 34, height: 34)
                Text(number)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText)
                Text(detail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.detailText)
            }
        }
    }
}

enum ThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "跟随系统"
        case .light: "浅色"
        case .dark: "深色"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct ThemePalette {
    let backgroundStart: Color
    let backgroundEnd: Color
    let iconPanel: Color
    let iconSymbol: Color
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color
    let detailText: Color
    let mutedText: Color
    let monospaceText: Color
    let pillBackground: Color
    let pillText: Color
    let cardBackground: Color
    let cardBorder: Color
    let softBackground: Color
    let logBackground: Color
    let errorBackground: Color
    let errorText: Color
    let shadowColor: Color
    let statusOn: Color
    let statusOff: Color
    let stepCircle: Color

    init(colorScheme: ColorScheme) {
        if colorScheme == .dark {
            backgroundStart = Color(red: 0.10, green: 0.12, blue: 0.16)
            backgroundEnd = Color(red: 0.06, green: 0.08, blue: 0.11)
            iconPanel = Color(red: 0.16, green: 0.22, blue: 0.20)
            iconSymbol = Color(red: 0.75, green: 0.96, blue: 0.60)
            primaryText = Color.white.opacity(0.92)
            secondaryText = Color.white.opacity(0.72)
            tertiaryText = Color.white.opacity(0.62)
            detailText = Color.white.opacity(0.68)
            mutedText = Color.white.opacity(0.52)
            monospaceText = Color.white.opacity(0.80)
            pillBackground = Color.white.opacity(0.10)
            pillText = Color.white.opacity(0.88)
            cardBackground = Color.white.opacity(0.07)
            cardBorder = Color.white.opacity(0.10)
            softBackground = Color.white.opacity(0.08)
            logBackground = Color.white.opacity(0.09)
            errorBackground = Color(red: 0.34, green: 0.11, blue: 0.10)
            errorText = Color(red: 1.0, green: 0.73, blue: 0.70)
            shadowColor = Color.black.opacity(0.30)
            statusOn = Color(red: 0.40, green: 0.84, blue: 0.45)
            statusOff = Color(red: 0.96, green: 0.68, blue: 0.27)
            stepCircle = Color(red: 0.20, green: 0.30, blue: 0.27)
        } else {
            backgroundStart = Color(red: 0.95, green: 0.97, blue: 0.94)
            backgroundEnd = Color(red: 0.90, green: 0.94, blue: 0.98)
            iconPanel = Color(red: 0.12, green: 0.18, blue: 0.16)
            iconSymbol = Color(red: 0.75, green: 0.96, blue: 0.60)
            primaryText = Color.black.opacity(0.84)
            secondaryText = Color.black.opacity(0.65)
            tertiaryText = Color.black.opacity(0.60)
            detailText = Color.black.opacity(0.68)
            mutedText = Color.black.opacity(0.50)
            monospaceText = Color.black.opacity(0.75)
            pillBackground = Color.white.opacity(0.85)
            pillText = Color.black.opacity(0.82)
            cardBackground = Color.white.opacity(0.62)
            cardBorder = Color.white.opacity(0.55)
            softBackground = Color.white.opacity(0.78)
            logBackground = Color.white.opacity(0.78)
            errorBackground = Color(red: 1.0, green: 0.93, blue: 0.91)
            errorText = Color(red: 0.72, green: 0.18, blue: 0.15)
            shadowColor = Color.black.opacity(0.05)
            statusOn = Color.green
            statusOff = Color.orange
            stepCircle = Color(red: 0.15, green: 0.23, blue: 0.21)
        }
    }
}

@MainActor
final class ClipboardControlModel: ObservableObject {
    @Published var isRunning = false
    @Published var statusLabel = "检查中"
    @Published var statusMessage: String?
    @Published var lastError: String?
    @Published var logTail = "暂无日志"
    @Published var cacheCount = 0
    @Published var cacheSizeText = "0 B"
    @Published var latestCaptureName = "暂无"
    @Published var lastRefreshText = "尚未刷新"

    private let homeDirectory = NSHomeDirectory()
    let appBundlePath: String
    let launchAgentPath: String
    let cacheDirectoryPath = "/tmp/codex-clipboard-media"
    let logPath = "/tmp/codex-auto-paste.log"
    let stderrLogPath = "/tmp/codex-auto-paste.stderr.log"

    private let label = "com.codex.clipboard-auto-paste"
    private let refreshInterval: TimeInterval = 2.5
    private var timer: Timer?

    init() {
        appBundlePath = (homeDirectory as NSString).appendingPathComponent("Applications/Codex Clipboard Control.app")
        launchAgentPath = (homeDirectory as NSString).appendingPathComponent("Library/LaunchAgents/\(label).plist")
    }

    func start() {
        guard timer == nil else {
            refresh()
            return
        }

        refresh()

        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func refresh() {
        do {
            let result = try launchctl(["print", launchTarget])
            isRunning = result.contains("state = running")
            statusLabel = isRunning ? "运行中" : "未运行"
            statusMessage = parseStatusMessage(from: result)
            lastError = nil
        } catch {
            isRunning = false
            statusLabel = "未运行"
            statusMessage = "LaunchAgent 当前未载入，或 `launchctl print` 没拿到运行状态。"
            lastError = nil
        }

        readCacheSummary()
        readLogs()
        lastRefreshText = Self.timestampFormatter.string(from: Date())
    }

    func enableOrRestart() {
        do {
            if isRunning {
                _ = try launchctl(["kickstart", "-k", launchTarget])
            } else {
                _ = try? launchctl(["bootout", launchDomain, launchAgentPath])
                _ = try launchctl(["bootstrap", launchDomain, launchAgentPath])
            }
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }

        refresh()
    }

    func disable() {
        do {
            _ = try launchctl(["bootout", launchDomain, launchAgentPath])
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }

        refresh()
    }

    func openCacheDirectory() {
        let url = URL(fileURLWithPath: cacheDirectoryPath)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }

    func openLogFile() {
        let url = URL(fileURLWithPath: logPath)
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "/tmp")
        }
    }

    func clearCache() {
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: cacheDirectoryPath) {
                let contents = try fileManager.contentsOfDirectory(atPath: cacheDirectoryPath)
                for item in contents {
                    try? fileManager.removeItem(atPath: (cacheDirectoryPath as NSString).appendingPathComponent(item))
                }
            }
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }

        refresh()
    }

    func clearLogs() {
        do {
            try "".write(toFile: logPath, atomically: true, encoding: .utf8)
            try "".write(toFile: stderrLogPath, atomically: true, encoding: .utf8)
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }

        refresh()
    }

    private var launchDomain: String {
        "gui/\(getuid())"
    }

    private var launchTarget: String {
        "\(launchDomain)/\(label)"
    }

    private func launchctl(_ arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()
        process.waitUntilExit()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let stdout = String(decoding: stdoutData, as: UTF8.self)
        let stderr = String(decoding: stderrData, as: UTF8.self)

        if process.terminationStatus != 0 {
            throw NSError(
                domain: "CodexClipboardControl",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: stderr.isEmpty ? stdout : stderr]
            )
        }

        return stdout
    }

    private func readCacheSummary() {
        let fileManager = FileManager.default
        let cacheURL = URL(fileURLWithPath: cacheDirectoryPath, isDirectory: true)

        guard let enumerator = fileManager.enumerator(
            at: cacheURL,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            cacheCount = 0
            cacheSizeText = "0 B"
            latestCaptureName = "暂无"
            return
        }

        var totalSize = 0
        var count = 0
        var latestURL: URL?
        var latestDate = Date.distantPast

        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey, .contentModificationDateKey]),
                  values.isRegularFile == true
            else {
                continue
            }

            count += 1
            totalSize += values.fileSize ?? 0

            if let modified = values.contentModificationDate, modified > latestDate {
                latestDate = modified
                latestURL = fileURL
            }
        }

        cacheCount = count
        cacheSizeText = Self.byteFormatter.string(fromByteCount: Int64(totalSize))
        latestCaptureName = latestURL?.lastPathComponent ?? "暂无"
    }

    private func readLogs() {
        let logURL = URL(fileURLWithPath: logPath)
        guard let data = try? Data(contentsOf: logURL),
              let text = String(data: data, encoding: .utf8),
              !text.isEmpty
        else {
            logTail = "暂无日志"
            return
        }

        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        logTail = lines.suffix(18).joined(separator: "\n")
    }

    private func parseStatusMessage(from launchctlOutput: String) -> String? {
        let interestingLines = launchctlOutput
            .split(separator: "\n")
            .filter { line in
                line.contains("pid =") ||
                line.contains("runs =") ||
                line.contains("last exit code =") ||
                line.contains("state =")
            }

        guard !interestingLines.isEmpty else {
            return nil
        }

        return interestingLines.joined(separator: "\n")
    }

    private static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter
    }()

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
