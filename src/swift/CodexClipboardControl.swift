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
                .frame(minWidth: 760, idealWidth: 820, maxWidth: 920,
                       minHeight: 620, idealHeight: 700, maxHeight: 860)
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @EnvironmentObject private var model: ClipboardControlModel
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("codexClipboardThemeMode") private var themeModeRaw = ThemeMode.system.rawValue
    @AppStorage("codexClipboardLanguageMode") private var languageModeRaw = LanguageMode.system.rawValue
    @State private var showAdvanced = false

    private var themeMode: ThemeMode {
        ThemeMode(rawValue: themeModeRaw) ?? .system
    }

    private var languageMode: LanguageMode {
        LanguageMode(rawValue: languageModeRaw) ?? .system
    }

    private var language: InterfaceLanguage {
        languageMode.resolvedLanguage
    }

    private var copy: CopyBook {
        CopyBook(language: language)
    }

    private var effectiveColorScheme: ColorScheme {
        themeMode.colorScheme ?? systemColorScheme
    }

    private var palette: ThemePalette {
        ThemePalette(colorScheme: effectiveColorScheme)
    }

    private let statColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let utilityColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                quickStartCard
                howToCard
                advancedCard
            }
            .padding(24)
        }
        .background(backgroundLayer)
        .preferredColorScheme(themeMode.colorScheme)
        .onAppear {
            model.start()
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [palette.backgroundStart, palette.backgroundEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(palette.heroGlow.opacity(0.34))
                .frame(width: 360, height: 360)
                .blur(radius: 36)
                .offset(x: -240, y: -220)

            Circle()
                .fill(palette.secondaryGlow.opacity(0.25))
                .frame(width: 280, height: 280)
                .blur(radius: 34)
                .offset(x: 280, y: -180)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(palette.iconPanel)
                        .frame(width: 84, height: 84)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(palette.iconPanelBorder, lineWidth: 1)
                        )

                    Image(systemName: "paperclip.circle.fill")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(palette.iconSymbol)
                }
                .shadow(color: palette.shadowColor.opacity(0.35), radius: 20, x: 0, y: 10)

                VStack(alignment: .leading, spacing: 8) {
                    Text(copy.appName)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.primaryText)

                    Text(copy.headerSubtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    statusPill
                }
            }

            Spacer(minLength: 18)

            VStack(alignment: .leading, spacing: 14) {
                ControlPickerCard(
                    title: copy.languageControlTitle,
                    selection: $languageModeRaw,
                    options: LanguageMode.allCases.map { ($0.rawValue, $0.title(in: language)) },
                    palette: palette
                )

                ControlPickerCard(
                    title: copy.themeControlTitle,
                    selection: $themeModeRaw,
                    options: ThemeMode.allCases.map { ($0.rawValue, $0.title(in: language)) },
                    palette: palette
                )
            }
            .frame(width: 320)
        }
    }

    private var statusPill: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(model.isRunning ? palette.statusOn : palette.statusOff)
                .frame(width: 10, height: 10)

            Text(copy.statusLabel(model.isRunning))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(palette.pillText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            Capsule(style: .continuous)
                .fill(palette.pillBackground)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(palette.pillBorder, lineWidth: 1)
                )
        )
    }

    private var quickStartCard: some View {
        Card(
            title: copy.atAGlanceTitle,
            subtitle: copy.atAGlanceSubtitle,
            palette: palette
        ) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(model.isRunning ? copy.readyHeadline : copy.stoppedHeadline)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.primaryText)

                    Text(model.isRunning ? copy.readyBody : copy.stoppedBody)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(palette.softBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(palette.softBackgroundBorder, lineWidth: 1)
                        )
                )

                HStack(spacing: 14) {
                    ActionPanelButton(
                        title: model.isRunning ? copy.restartTitle : copy.enableTitle,
                        subtitle: model.isRunning ? copy.restartSubtitle : copy.enableSubtitle,
                        systemImage: model.isRunning ? "arrow.clockwise.circle.fill" : "play.circle.fill",
                        tone: .primary,
                        size: .large,
                        palette: palette
                    ) {
                        model.enableOrRestart()
                    }

                    ActionPanelButton(
                        title: copy.disableTitle,
                        subtitle: copy.disableSubtitle,
                        systemImage: "pause.circle.fill",
                        tone: .danger,
                        size: .large,
                        palette: palette
                    ) {
                        model.disable()
                    }
                }

                LazyVGrid(columns: statColumns, spacing: 12) {
                    StatusTile(
                        label: copy.agentBadgeLabel,
                        value: copy.statusLabel(model.isRunning),
                        systemImage: "wave.3.right.circle.fill",
                        palette: palette,
                        accent: model.isRunning ? palette.statusOn : palette.statusOff
                    )

                    StatusTile(
                        label: copy.cachedBadgeLabel,
                        value: copy.cacheCountText(model.cacheCount),
                        systemImage: "photo.stack.fill",
                        palette: palette,
                        accent: palette.accentAmber
                    )

                    StatusTile(
                        label: copy.lastRefreshBadgeLabel,
                        value: model.lastRefreshText.isEmpty ? copy.neverText : model.lastRefreshText,
                        systemImage: "clock.arrow.circlepath",
                        palette: palette,
                        accent: palette.accentBlue
                    )
                }

                if let errorMessage = model.lastError, !errorMessage.isEmpty {
                    ErrorBanner(message: errorMessage, palette: palette)
                }
            }
        }
    }

    private var howToCard: some View {
        Card(
            title: copy.howToTitle,
            subtitle: copy.howToSubtitle,
            palette: palette
        ) {
            VStack(alignment: .leading, spacing: 14) {
                StepCard(number: "1", title: copy.stepOneTitle, detail: copy.stepOneDetail, palette: palette)
                StepCard(number: "2", title: copy.stepTwoTitle, detail: copy.stepTwoDetail, palette: palette)
                StepCard(number: "3", title: copy.stepThreeTitle, detail: copy.stepThreeDetail, palette: palette)

                TipCard(
                    title: copy.tipTitle,
                    detail: copy.tipBody,
                    systemImage: "lightbulb.fill",
                    palette: palette
                )
            }
        }
    }

    private var advancedCard: some View {
        Card(
            title: copy.advancedTitle,
            subtitle: copy.advancedSubtitle,
            palette: palette
        ) {
            DisclosureGroup(isExpanded: $showAdvanced) {
                VStack(alignment: .leading, spacing: 18) {
                    LazyVGrid(columns: utilityColumns, spacing: 12) {
                        ActionPanelButton(
                            title: copy.openCacheTitle,
                            subtitle: copy.openCacheSubtitle,
                            systemImage: "folder.fill",
                            tone: .amber,
                            size: .compact,
                            palette: palette
                        ) {
                            model.openCacheDirectory()
                        }

                        ActionPanelButton(
                            title: copy.openLogsTitle,
                            subtitle: copy.openLogsSubtitle,
                            systemImage: "doc.text.fill",
                            tone: .blue,
                            size: .compact,
                            palette: palette
                        ) {
                            model.openLogFile()
                        }

                        ActionPanelButton(
                            title: copy.clearCacheTitle,
                            subtitle: copy.clearCacheSubtitle,
                            systemImage: "trash.fill",
                            tone: .purple,
                            size: .compact,
                            palette: palette
                        ) {
                            model.clearCache()
                        }

                        ActionPanelButton(
                            title: copy.clearLogsTitle,
                            subtitle: copy.clearLogsSubtitle,
                            systemImage: "eraser.fill",
                            tone: .teal,
                            size: .compact,
                            palette: palette
                        ) {
                            model.clearLogs()
                        }
                    }

                    ActionPanelButton(
                        title: copy.refreshTitle,
                        subtitle: copy.refreshSubtitle,
                        systemImage: "arrow.triangle.2.circlepath",
                        tone: .neutral,
                        size: .compact,
                        palette: palette
                    ) {
                        model.refresh()
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        MetricRow(label: copy.cacheSizeLabel, value: model.cacheSizeText, palette: palette)
                        MetricRow(label: copy.latestCaptureLabel, value: model.latestCaptureName.isEmpty ? copy.noneText : model.latestCaptureName, palette: palette)
                        MetricRow(label: copy.appBundleLabel, value: model.appBundlePath, palette: palette)
                        MetricRow(label: copy.cacheFolderLabel, value: model.cacheDirectoryPath, palette: palette)
                        MetricRow(label: copy.mainLogLabel, value: model.logPath, palette: palette)

                        if let message = model.statusMessage, !message.isEmpty {
                            LogBox(text: message, palette: palette)
                        } else if !model.isRunning {
                            LogBox(text: copy.agentMissingMessage, palette: palette)
                        }
                    }

                    ScrollView {
                        Text(model.logTail.isEmpty ? copy.noLogsText : model.logTail)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(palette.monospaceText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(16)
                    }
                    .frame(minHeight: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(palette.logBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(palette.logBorder, lineWidth: 1)
                            )
                    )
                }
                .padding(.top, 14)
            } label: {
                HStack {
                    Text(showAdvanced ? copy.advancedCollapseText : copy.advancedExpandText)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.primaryText)
                    Spacer()
                    Text(copy.advancedSummary)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.mutedText)
                }
                .padding(.vertical, 2)
            }
            .tint(palette.primaryText)
        }
    }
}

struct Card<Content: View>: View {
    let title: String
    let subtitle: String
    let palette: ThemePalette
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryText)
            }

            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(palette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(palette.cardBorder, lineWidth: 1)
                )
        )
        .shadow(color: palette.shadowColor, radius: 22, x: 0, y: 16)
    }
}

struct ControlPickerCard: View {
    let title: String
    @Binding var selection: String
    let options: [(String, String)]
    let palette: ThemePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(palette.mutedText)

            Picker(title, selection: $selection) {
                ForEach(options, id: \.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(palette.controlCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(palette.controlCardBorder, lineWidth: 1)
                )
        )
    }
}

struct StatusTile: View {
    let label: String
    let value: String
    let systemImage: String
    let palette: ThemePalette
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.16))
                        .frame(width: 34, height: 34)
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(accent)
                }

                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.mutedText)
            }

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(palette.primaryText)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 102, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(palette.softBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(palette.softBackgroundBorder, lineWidth: 1)
                )
        )
    }
}

enum ActionButtonSize {
    case large
    case compact

    var cornerRadius: CGFloat {
        switch self {
        case .large: 22
        case .compact: 20
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .large: 42
        case .compact: 34
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .large: 18
        case .compact: 14
        }
    }
}

enum ActionTone {
    case primary
    case danger
    case neutral
    case amber
    case blue
    case purple
    case teal
}

struct ActionPanelButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tone: ActionTone
    let size: ActionButtonSize
    let palette: ThemePalette
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        let colors = palette.colors(for: tone)

        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(colors.iconBackground)
                        .frame(width: size.iconSize, height: size.iconSize)
                    Image(systemName: systemImage)
                        .font(.system(size: size == .large ? 18 : 15, weight: .bold))
                        .foregroundStyle(colors.iconForeground)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: size == .large ? 15 : 14, weight: .bold, design: .rounded))
                        .foregroundStyle(colors.titleText)
                    Text(subtitle)
                        .font(.system(size: size == .large ? 12 : 11, weight: .medium, design: .rounded))
                        .foregroundStyle(colors.subtitleText)
                        .lineLimit(2)
                }

                Spacer(minLength: 10)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(colors.chevronText.opacity(isHovering ? 1 : 0.75))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: .infinity, minHeight: size == .large ? 90 : 72, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                    .fill(colors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                            .stroke(isHovering ? colors.hoverBorder : colors.border, lineWidth: 1)
                    )
            )
            .shadow(color: colors.shadow.opacity(isHovering ? 0.9 : 0.55), radius: isHovering ? 18 : 12, x: 0, y: isHovering ? 12 : 8)
            .scaleEffect(isHovering ? 1.01 : 1.0)
        }
        .buttonStyle(PressableButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                isHovering = hovering
            }
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

struct StepCard: View {
    let number: String
    let title: String
    let detail: String
    let palette: ThemePalette

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(palette.stepCircle)
                    .frame(width: 38, height: 38)
                Text(number)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText)
                Text(detail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.detailText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(palette.softBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(palette.softBackgroundBorder, lineWidth: 1)
                )
        )
    }
}

struct TipCard: View {
    let title: String
    let detail: String
    let systemImage: String
    let palette: ThemePalette

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(palette.tipIconBackground)
                    .frame(width: 44, height: 44)
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(palette.tipIconForeground)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText)
                Text(detail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.detailText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(palette.tipBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(palette.tipBorder, lineWidth: 1)
                )
        )
    }
}

struct ErrorBanner: View {
    let message: String
    let palette: ThemePalette

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(palette.errorText)

            Text(message)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.errorText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(palette.errorBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(palette.errorBorder, lineWidth: 1)
                )
        )
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let palette: ThemePalette

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(palette.mutedText)
                .frame(width: 110, alignment: .leading)

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.primaryText)
                .textSelection(.enabled)
                .multilineTextAlignment(.leading)
        }
    }
}

struct LogBox: View {
    let text: String
    let palette: ThemePalette

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundStyle(palette.monospaceText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(palette.logBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(palette.logBorder, lineWidth: 1)
                    )
            )
    }
}

enum InterfaceLanguage {
    case chinese
    case english
}

enum LanguageMode: String, CaseIterable, Identifiable {
    case system
    case chinese
    case english

    var id: String { rawValue }

    var resolvedLanguage: InterfaceLanguage {
        switch self {
        case .system:
            let preferred = Locale.preferredLanguages.first?.lowercased() ?? ""
            return preferred.hasPrefix("zh") ? .chinese : .english
        case .chinese:
            return .chinese
        case .english:
            return .english
        }
    }

    func title(in language: InterfaceLanguage) -> String {
        switch (self, language) {
        case (.system, .chinese): "跟随系统"
        case (.system, .english): "System"
        case (.chinese, _): "中文"
        case (.english, _): "English"
        }
    }
}

enum ThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    func title(in language: InterfaceLanguage) -> String {
        switch (self, language) {
        case (.system, .chinese): "跟随系统"
        case (.system, .english): "System"
        case (.light, .chinese): "浅色"
        case (.light, .english): "Light"
        case (.dark, .chinese): "深色"
        case (.dark, .english): "Dark"
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

struct CopyBook {
    let language: InterfaceLanguage

    var appName: String { "Codex Clipboard Control" }

    var headerSubtitle: String {
        switch language {
        case .chinese:
            "这是截图粘贴助手的控制中心。平时只要看它是不是运行中，需要时再切主题或语言。"
        case .english:
            "This is the control center for the screenshot paste helper. Most days you only need to know whether it is running."
        }
    }

    var languageControlTitle: String {
        switch language {
        case .chinese: "语言"
        case .english: "Language"
        }
    }

    var themeControlTitle: String {
        switch language {
        case .chinese: "主题"
        case .english: "Theme"
        }
    }

    func statusLabel(_ isRunning: Bool) -> String {
        switch (language, isRunning) {
        case (.chinese, true): "监听器运行中"
        case (.chinese, false): "监听器未运行"
        case (.english, true): "Agent Running"
        case (.english, false): "Agent Stopped"
        }
    }

    var atAGlanceTitle: String {
        switch language {
        case .chinese: "一眼看懂"
        case .english: "At a Glance"
        }
    }

    var atAGlanceSubtitle: String {
        switch language {
        case .chinese: "这里是你日常最常用的区域。确认状态，按下主要按钮，然后继续工作。"
        case .english: "This is the part you will use most often. Check the status, hit the main action, and move on."
        }
    }

    var readyHeadline: String {
        switch language {
        case .chinese: "现在可以直接用了"
        case .english: "You can paste screenshots now"
        }
    }

    var readyBody: String {
        switch language {
        case .chinese: "在终端或 Codex 里正常截图，然后按 Cmd+V。去微信、飞书或浏览器时，剪贴板会恢复成真正的图片。"
        case .english: "Take a screenshot as usual, return to Terminal or Codex, then press Cmd+V. In normal apps, the clipboard will be restored back to a real image."
        }
    }

    var stoppedHeadline: String {
        switch language {
        case .chinese: "现在还没开启"
        case .english: "The helper is currently off"
        }
    }

    var stoppedBody: String {
        switch language {
        case .chinese: "点下面的主按钮启用监听器。启用后，终端里的截图粘贴会自动转成文件路径。"
        case .english: "Use the main button below to enable the background agent. After that, screenshot paste inside Terminal will automatically turn into a file path."
        }
    }

    var enableTitle: String {
        switch language {
        case .chinese: "立即启用"
        case .english: "Enable Now"
        }
    }

    var enableSubtitle: String {
        switch language {
        case .chinese: "载入 LaunchAgent 并开始监听剪贴板"
        case .english: "Load the LaunchAgent and start watching the clipboard"
        }
    }

    var restartTitle: String {
        switch language {
        case .chinese: "重启并保持可用"
        case .english: "Restart and Keep Active"
        }
    }

    var restartSubtitle: String {
        switch language {
        case .chinese: "功能不对劲时点这个，最快恢复"
        case .english: "Use this when behavior looks off and you want a quick reset"
        }
    }

    var disableTitle: String {
        switch language {
        case .chinese: "暂时关闭"
        case .english: "Pause Helper"
        }
    }

    var disableSubtitle: String {
        switch language {
        case .chinese: "停止监听器，恢复成普通系统剪贴板"
        case .english: "Stop the agent and return to normal system clipboard behavior"
        }
    }

    var agentBadgeLabel: String {
        switch language {
        case .chinese: "后台监听器"
        case .english: "Background Agent"
        }
    }

    var cachedBadgeLabel: String {
        switch language {
        case .chinese: "缓存截图"
        case .english: "Cached Captures"
        }
    }

    var lastRefreshBadgeLabel: String {
        switch language {
        case .chinese: "最近刷新"
        case .english: "Last Refresh"
        }
    }

    func cacheCountText(_ count: Int) -> String {
        switch language {
        case .chinese:
            return "\(count) 张"
        case .english:
            return count == 1 ? "1 item" : "\(count) items"
        }
    }

    var howToTitle: String {
        switch language {
        case .chinese: "怎么用"
        case .english: "How It Works"
        }
    }

    var howToSubtitle: String {
        switch language {
        case .chinese: "流程维持最短。截图、回终端、粘贴，其他应用里依然保持正常图片粘贴。"
        case .english: "The workflow stays short: screenshot, return to Terminal, paste. Other apps still get normal image paste behavior."
        }
    }

    var stepOneTitle: String {
        switch language {
        case .chinese: "确认是运行中"
        case .english: "Make sure the agent is running"
        }
    }

    var stepOneDetail: String {
        switch language {
        case .chinese: "打开这个面板时，只要顶部状态显示正在运行就够了。"
        case .english: "Open this panel and confirm the status says the agent is running."
        }
    }

    var stepTwoTitle: String {
        switch language {
        case .chinese: "在终端里正常截图"
        case .english: "Take screenshots the normal way"
        }
    }

    var stepTwoDetail: String {
        switch language {
        case .chinese: "继续用 iShot 或你原来的截图方式，不需要额外点任何按钮。"
        case .english: "Keep using iShot or your current screenshot tool. No extra helper button is required."
        }
    }

    var stepThreeTitle: String {
        switch language {
        case .chinese: "回到 Codex 直接 Cmd+V"
        case .english: "Return to Codex and press Cmd+V"
        }
    }

    var stepThreeDetail: String {
        switch language {
        case .chinese: "在终端或 Codex 中会粘贴成图片路径，切回微信、飞书或浏览器时又会恢复成图片。"
        case .english: "Inside Terminal or Codex the paste becomes an image path. In WeChat, Feishu, or browsers it becomes a real image again."
        }
    }

    var tipTitle: String {
        switch language {
        case .chinese: "什么时候需要打开这个面板？"
        case .english: "When do you actually need this panel?"
        }
    }

    var tipBody: String {
        switch language {
        case .chinese: "通常只有两种情况：功能失效时点重启，或者你想临时停掉它。平时不用一直盯着。"
        case .english: "Usually there are only two reasons: restart the helper when something looks broken, or pause it temporarily. You do not need to keep this window open."
        }
    }

    var advancedTitle: String {
        switch language {
        case .chinese: "高级工具箱"
        case .english: "Advanced Tools"
        }
    }

    var advancedSubtitle: String {
        switch language {
        case .chinese: "这里放诊断、路径和清理操作。日常不用碰，排查问题时再展开。"
        case .english: "This section holds diagnostics, paths, and cleanup actions. Ignore it most of the time and expand it only when troubleshooting."
        }
    }

    var advancedExpandText: String {
        switch language {
        case .chinese: "展开高级内容"
        case .english: "Show advanced details"
        }
    }

    var advancedCollapseText: String {
        switch language {
        case .chinese: "收起高级内容"
        case .english: "Hide advanced details"
        }
    }

    var advancedSummary: String {
        switch language {
        case .chinese: "日志、路径、清理"
        case .english: "Logs, paths, cleanup"
        }
    }

    var openCacheTitle: String {
        switch language {
        case .chinese: "打开缓存目录"
        case .english: "Open Cache Folder"
        }
    }

    var openCacheSubtitle: String {
        switch language {
        case .chinese: "查看自动保存的临时截图"
        case .english: "Inspect the temporary captures saved by the helper"
        }
    }

    var openLogsTitle: String {
        switch language {
        case .chinese: "打开日志"
        case .english: "Open Logs"
        }
    }

    var openLogsSubtitle: String {
        switch language {
        case .chinese: "查看后台 agent 最近输出了什么"
        case .english: "See what the background agent has been writing recently"
        }
    }

    var clearCacheTitle: String {
        switch language {
        case .chinese: "清空缓存截图"
        case .english: "Clear Cached Images"
        }
    }

    var clearCacheSubtitle: String {
        switch language {
        case .chinese: "删除临时目录里的历史截图文件"
        case .english: "Remove previously saved temporary screenshot files"
        }
    }

    var clearLogsTitle: String {
        switch language {
        case .chinese: "清空日志"
        case .english: "Clear Logs"
        }
    }

    var clearLogsSubtitle: String {
        switch language {
        case .chinese: "把主日志和错误日志重置为空"
        case .english: "Reset the main log and stderr log back to empty"
        }
    }

    var refreshTitle: String {
        switch language {
        case .chinese: "立即刷新状态"
        case .english: "Refresh Status"
        }
    }

    var refreshSubtitle: String {
        switch language {
        case .chinese: "重新读取 LaunchAgent、缓存和日志摘要"
        case .english: "Reload LaunchAgent state, cache summary, and log preview"
        }
    }

    var cacheSizeLabel: String {
        switch language {
        case .chinese: "缓存大小"
        case .english: "Cache Size"
        }
    }

    var latestCaptureLabel: String {
        switch language {
        case .chinese: "最近截图"
        case .english: "Latest Capture"
        }
    }

    var appBundleLabel: String {
        switch language {
        case .chinese: "控制面板"
        case .english: "Control Panel"
        }
    }

    var cacheFolderLabel: String {
        switch language {
        case .chinese: "缓存目录"
        case .english: "Cache Folder"
        }
    }

    var mainLogLabel: String {
        switch language {
        case .chinese: "主日志"
        case .english: "Main Log"
        }
    }

    var noneText: String {
        switch language {
        case .chinese: "暂无"
        case .english: "None yet"
        }
    }

    var neverText: String {
        switch language {
        case .chinese: "尚未刷新"
        case .english: "Not refreshed yet"
        }
    }

    var noLogsText: String {
        switch language {
        case .chinese: "暂无日志"
        case .english: "No logs yet"
        }
    }

    var agentMissingMessage: String {
        switch language {
        case .chinese: "LaunchAgent 当前未载入，或者还没有可读的运行信息。"
        case .english: "The LaunchAgent is not loaded right now, or there is no readable runtime information yet."
        }
    }
}

struct ButtonColors {
    let background: LinearGradient
    let border: Color
    let hoverBorder: Color
    let shadow: Color
    let iconBackground: Color
    let iconForeground: Color
    let titleText: Color
    let subtitleText: Color
    let chevronText: Color
}

struct ThemePalette {
    let backgroundStart: Color
    let backgroundEnd: Color
    let heroGlow: Color
    let secondaryGlow: Color
    let iconPanel: LinearGradient
    let iconPanelBorder: Color
    let iconSymbol: Color
    let primaryText: Color
    let secondaryText: Color
    let detailText: Color
    let mutedText: Color
    let monospaceText: Color
    let pillBackground: Color
    let pillBorder: Color
    let pillText: Color
    let cardBackground: Color
    let cardBorder: Color
    let controlCardBackground: Color
    let controlCardBorder: Color
    let softBackground: Color
    let softBackgroundBorder: Color
    let logBackground: Color
    let logBorder: Color
    let errorBackground: Color
    let errorBorder: Color
    let errorText: Color
    let tipBackground: Color
    let tipBorder: Color
    let tipIconBackground: Color
    let tipIconForeground: Color
    let shadowColor: Color
    let statusOn: Color
    let statusOff: Color
    let stepCircle: Color
    let accentAmber: Color
    let accentBlue: Color

    init(colorScheme: ColorScheme) {
        if colorScheme == .dark {
            backgroundStart = Color(red: 0.08, green: 0.10, blue: 0.13)
            backgroundEnd = Color(red: 0.04, green: 0.06, blue: 0.09)
            heroGlow = Color(red: 0.16, green: 0.40, blue: 0.31)
            secondaryGlow = Color(red: 0.22, green: 0.26, blue: 0.46)
            iconPanel = LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.25, blue: 0.22),
                    Color(red: 0.10, green: 0.15, blue: 0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            iconPanelBorder = Color.white.opacity(0.08)
            iconSymbol = Color(red: 0.80, green: 0.96, blue: 0.66)
            primaryText = Color.white.opacity(0.93)
            secondaryText = Color.white.opacity(0.72)
            detailText = Color.white.opacity(0.68)
            mutedText = Color.white.opacity(0.50)
            monospaceText = Color.white.opacity(0.80)
            pillBackground = Color.white.opacity(0.08)
            pillBorder = Color.white.opacity(0.08)
            pillText = Color.white.opacity(0.88)
            cardBackground = Color.white.opacity(0.07)
            cardBorder = Color.white.opacity(0.08)
            controlCardBackground = Color.white.opacity(0.06)
            controlCardBorder = Color.white.opacity(0.08)
            softBackground = Color.white.opacity(0.05)
            softBackgroundBorder = Color.white.opacity(0.08)
            logBackground = Color.white.opacity(0.06)
            logBorder = Color.white.opacity(0.08)
            errorBackground = Color(red: 0.33, green: 0.12, blue: 0.11)
            errorBorder = Color(red: 0.55, green: 0.21, blue: 0.18)
            errorText = Color(red: 1.0, green: 0.76, blue: 0.72)
            tipBackground = Color(red: 0.16, green: 0.17, blue: 0.10)
            tipBorder = Color(red: 0.36, green: 0.31, blue: 0.14)
            tipIconBackground = Color(red: 0.36, green: 0.29, blue: 0.11)
            tipIconForeground = Color(red: 1.0, green: 0.86, blue: 0.47)
            shadowColor = Color.black.opacity(0.34)
            statusOn = Color(red: 0.39, green: 0.85, blue: 0.50)
            statusOff = Color(red: 0.95, green: 0.66, blue: 0.26)
            stepCircle = Color(red: 0.20, green: 0.30, blue: 0.28)
            accentAmber = Color(red: 0.97, green: 0.73, blue: 0.32)
            accentBlue = Color(red: 0.52, green: 0.73, blue: 1.0)
        } else {
            backgroundStart = Color(red: 0.95, green: 0.97, blue: 0.94)
            backgroundEnd = Color(red: 0.89, green: 0.94, blue: 0.98)
            heroGlow = Color(red: 0.67, green: 0.85, blue: 0.74)
            secondaryGlow = Color(red: 0.69, green: 0.77, blue: 0.95)
            iconPanel = LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.26, blue: 0.24),
                    Color(red: 0.12, green: 0.18, blue: 0.17)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            iconPanelBorder = Color.white.opacity(0.55)
            iconSymbol = Color(red: 0.79, green: 0.95, blue: 0.62)
            primaryText = Color.black.opacity(0.84)
            secondaryText = Color.black.opacity(0.65)
            detailText = Color.black.opacity(0.68)
            mutedText = Color.black.opacity(0.48)
            monospaceText = Color.black.opacity(0.75)
            pillBackground = Color.white.opacity(0.84)
            pillBorder = Color.white.opacity(0.64)
            pillText = Color.black.opacity(0.84)
            cardBackground = Color.white.opacity(0.64)
            cardBorder = Color.white.opacity(0.55)
            controlCardBackground = Color.white.opacity(0.76)
            controlCardBorder = Color.white.opacity(0.64)
            softBackground = Color.white.opacity(0.80)
            softBackgroundBorder = Color.white.opacity(0.62)
            logBackground = Color.white.opacity(0.80)
            logBorder = Color.white.opacity(0.60)
            errorBackground = Color(red: 1.0, green: 0.94, blue: 0.92)
            errorBorder = Color(red: 0.93, green: 0.73, blue: 0.68)
            errorText = Color(red: 0.74, green: 0.18, blue: 0.15)
            tipBackground = Color(red: 0.99, green: 0.96, blue: 0.88)
            tipBorder = Color(red: 0.93, green: 0.83, blue: 0.57)
            tipIconBackground = Color(red: 0.98, green: 0.86, blue: 0.54)
            tipIconForeground = Color(red: 0.44, green: 0.30, blue: 0.03)
            shadowColor = Color.black.opacity(0.08)
            statusOn = Color(red: 0.17, green: 0.63, blue: 0.34)
            statusOff = Color(red: 0.92, green: 0.59, blue: 0.18)
            stepCircle = Color(red: 0.15, green: 0.23, blue: 0.21)
            accentAmber = Color(red: 0.84, green: 0.55, blue: 0.16)
            accentBlue = Color(red: 0.24, green: 0.46, blue: 0.91)
        }
    }

    func colors(for tone: ActionTone) -> ButtonColors {
        switch tone {
        case .primary:
            return ButtonColors(
                background: LinearGradient(
                    colors: [Color(red: 0.20, green: 0.62, blue: 0.37), Color(red: 0.13, green: 0.49, blue: 0.31)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                border: Color.white.opacity(0.14),
                hoverBorder: Color.white.opacity(0.24),
                shadow: Color(red: 0.10, green: 0.40, blue: 0.25),
                iconBackground: Color.white.opacity(0.18),
                iconForeground: Color.white.opacity(0.96),
                titleText: Color.white.opacity(0.98),
                subtitleText: Color.white.opacity(0.82),
                chevronText: Color.white.opacity(0.92)
            )
        case .danger:
            return ButtonColors(
                background: LinearGradient(
                    colors: [Color(red: 0.81, green: 0.28, blue: 0.23), Color(red: 0.68, green: 0.18, blue: 0.17)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                border: Color.white.opacity(0.12),
                hoverBorder: Color.white.opacity(0.22),
                shadow: Color(red: 0.45, green: 0.13, blue: 0.11),
                iconBackground: Color.white.opacity(0.16),
                iconForeground: Color.white.opacity(0.96),
                titleText: Color.white.opacity(0.98),
                subtitleText: Color.white.opacity(0.82),
                chevronText: Color.white.opacity(0.90)
            )
        case .neutral:
            return ButtonColors(
                background: LinearGradient(
                    colors: [Color.white.opacity(0.70), Color.white.opacity(0.54)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                border: Color.white.opacity(0.58),
                hoverBorder: Color.white.opacity(0.78),
                shadow: shadowColor,
                iconBackground: Color.black.opacity(0.08),
                iconForeground: primaryText,
                titleText: primaryText,
                subtitleText: secondaryText,
                chevronText: primaryText
            )
        case .amber:
            return ButtonColors(
                background: LinearGradient(
                    colors: [Color(red: 0.93, green: 0.69, blue: 0.30), Color(red: 0.84, green: 0.53, blue: 0.16)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                border: Color.white.opacity(0.12),
                hoverBorder: Color.white.opacity(0.24),
                shadow: Color(red: 0.66, green: 0.40, blue: 0.10),
                iconBackground: Color.white.opacity(0.18),
                iconForeground: Color.white.opacity(0.96),
                titleText: Color.white.opacity(0.97),
                subtitleText: Color.white.opacity(0.83),
                chevronText: Color.white.opacity(0.92)
            )
        case .blue:
            return ButtonColors(
                background: LinearGradient(
                    colors: [Color(red: 0.34, green: 0.52, blue: 0.92), Color(red: 0.22, green: 0.39, blue: 0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                border: Color.white.opacity(0.12),
                hoverBorder: Color.white.opacity(0.24),
                shadow: Color(red: 0.18, green: 0.30, blue: 0.60),
                iconBackground: Color.white.opacity(0.18),
                iconForeground: Color.white.opacity(0.96),
                titleText: Color.white.opacity(0.97),
                subtitleText: Color.white.opacity(0.83),
                chevronText: Color.white.opacity(0.92)
            )
        case .purple:
            return ButtonColors(
                background: LinearGradient(
                    colors: [Color(red: 0.59, green: 0.38, blue: 0.88), Color(red: 0.46, green: 0.27, blue: 0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                border: Color.white.opacity(0.12),
                hoverBorder: Color.white.opacity(0.24),
                shadow: Color(red: 0.32, green: 0.17, blue: 0.52),
                iconBackground: Color.white.opacity(0.18),
                iconForeground: Color.white.opacity(0.96),
                titleText: Color.white.opacity(0.97),
                subtitleText: Color.white.opacity(0.83),
                chevronText: Color.white.opacity(0.92)
            )
        case .teal:
            return ButtonColors(
                background: LinearGradient(
                    colors: [Color(red: 0.20, green: 0.68, blue: 0.70), Color(red: 0.12, green: 0.54, blue: 0.58)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                border: Color.white.opacity(0.12),
                hoverBorder: Color.white.opacity(0.24),
                shadow: Color(red: 0.10, green: 0.37, blue: 0.39),
                iconBackground: Color.white.opacity(0.18),
                iconForeground: Color.white.opacity(0.96),
                titleText: Color.white.opacity(0.97),
                subtitleText: Color.white.opacity(0.83),
                chevronText: Color.white.opacity(0.92)
            )
        }
    }
}

@MainActor
final class ClipboardControlModel: ObservableObject {
    @Published var isRunning = false
    @Published var statusMessage: String?
    @Published var lastError: String?
    @Published var logTail = ""
    @Published var cacheCount = 0
    @Published var cacheSizeText = "0 B"
    @Published var latestCaptureName = ""
    @Published var lastRefreshText = ""

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
            statusMessage = parseStatusMessage(from: result)
            lastError = nil
        } catch {
            isRunning = false
            statusMessage = nil
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
            latestCaptureName = ""
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
        latestCaptureName = latestURL?.lastPathComponent ?? ""
    }

    private func readLogs() {
        let logURL = URL(fileURLWithPath: logPath)
        guard let data = try? Data(contentsOf: logURL),
              let text = String(data: data, encoding: .utf8),
              !text.isEmpty
        else {
            logTail = ""
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
