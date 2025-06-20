import SwiftUI
import MessageUI
import WebKit

// Enhanced Toast View with modern design
struct Toast: View {
    let message: String
    @Binding var isShowing: Bool
    @State private var offsetY: CGFloat = 100
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        HStack(spacing: 14) {
            // Success icon with animated background
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
            }
            
            Text(message)
                .soraSubheadline()
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            ZStack {
                // Blur background effect
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                
                // Gradient overlay
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.green.opacity(0.9), location: 0),
                                .init(color: Color.green.opacity(0.8), location: 0.5),
                                .init(color: Color.green.opacity(0.85), location: 1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            // Subtle border highlight
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 8)
        .shadow(color: Color.green.opacity(0.3), radius: 15, x: 0, y: 5)
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offsetY)
        .onChange(of: isShowing) { _, showing in
            if showing {
                // Show animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    offsetY = 0
                    opacity = 1
                    scale = 1.0
                }
                
                // Icon animation delay
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
                    scale = 1.0
                }
            } else {
                // Hide animation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                    offsetY = 100
                    opacity = 0
                    scale = 0.95
                }
            }
        }
        .onAppear {
            if isShowing {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    offsetY = 0
                    opacity = 1
                    scale = 1.0
                }
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var isShareSheetPresented = false
    @State private var isWidgetSupportSheetPresented = false
    @State private var isMailSheetPresented = false
    @State private var isTermsSheetPresented = false
    @State private var showToast = false
    @State private var profileAppeared = false
    @State private var accountInfoAppeared = false
    @State private var supportAppeared = false
    @State private var generalAppeared = false
    @Binding var showSlideOverMenu: Bool
    @Binding var selectedTab: Int
    
    init(showSlideOverMenu: Binding<Bool>, selectedTab: Binding<Int>) {
        _showSlideOverMenu = showSlideOverMenu
        _selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 28) {
                        // Enhanced User Profile Section
                        VStack(spacing: 20) {
                            // Profile image with enhanced styling
                            if let url = settingsViewModel.imageURL {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.1)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 3
                                                )
                                        )
                                        .shadow(color: Color.accentColor.opacity(0.2), radius: 15, x: 0, y: 8)
                                        .onAppear {
                                            Task {
                                                await ImageCache.shared.setImage(image, for: url)
                                            }
                                        }
                                } placeholder: {
                                    ZStack {
                                        Circle()
                                            .fill(Color(.tertiarySystemBackground))
                                            .frame(width: 120, height: 120)
                                        
                                        ProgressView()
                                            .scaleEffect(1.2)
                                            .tint(.accentColor)
                                    }
                                }
                            }
                            
                            // User info with enhanced typography
                            VStack(spacing: 8) {
                                Text(settingsViewModel.name)
                                    .soraTitle2()
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.primary, .primary.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text(settingsViewModel.email)
                                    .soraSubheadline()
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color(.quaternarySystemFill))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 20)
                        .opacity(profileAppeared ? 1 : 0)
                        .offset(y: profileAppeared ? 0 : 30)
                        
                        // Enhanced Account Information Section
                        ModernSectionView(title: "Account Information") {
                            VStack(spacing: 1) {
                                EnhancedAccountInfoRow(
                                    icon: "person.text.rectangle.fill",
                                    iconColor: .blue,
                                    title: "Publisher ID",
                                    value: settingsViewModel.publisherId,
                                    isCopyable: true,
                                    onCopy: {
                                        UIPasteboard.general.string = settingsViewModel.publisherId
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                        
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            showToast = true
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                showToast = false
                                            }
                                        }
                                    }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                EnhancedAccountInfoRow(
                                    icon: "building.2.fill",
                                    iconColor: .purple,
                                    title: "Publisher Name",
                                    value: settingsViewModel.publisherName
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                EnhancedAccountInfoRow(
                                    icon: "clock.fill",
                                    iconColor: .orange,
                                    title: "Time Zone",
                                    value: settingsViewModel.timeZone
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                EnhancedAccountInfoRow(
                                    icon: "dollarsign.circle.fill",
                                    iconColor: .green,
                                    title: "Currency",
                                    value: settingsViewModel.currency
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                PaymentThresholdRow(settingsViewModel: settingsViewModel)
                            }
                        }
                        .opacity(accountInfoAppeared ? 1 : 0)
                        .offset(y: accountInfoAppeared ? 0 : 30)
                        
                        // Enhanced Support Section
                        ModernSectionView(title: "Support & Information") {
                            VStack(spacing: 1) {
                                ModernSettingsRow(
                                    icon: "info.circle.fill",
                                    iconColor: .blue,
                                    title: "Version",
                                    subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                                    showChevron: false
                                ) {}
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ModernSettingsRow(
                                    icon: "square.grid.2x2.fill",
                                    iconColor: .orange,
                                    title: "Widget Support",
                                    subtitle: "Setup and troubleshooting",
                                    showChevron: true
                                ) {
                                    isWidgetSupportSheetPresented = true
                                }
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ModernSettingsRow(
                                    icon: "envelope.fill",
                                    iconColor: .green,
                                    title: "Send Feedback",
                                    subtitle: "Help us improve AdRadar",
                                    showChevron: true
                                ) {
                                    isMailSheetPresented = true
                                }
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ModernSettingsRow(
                                    icon: "bird.fill",
                                    iconColor: .blue,
                                    title: "Follow @AdRadar",
                                    subtitle: "Stay updated on X",
                                    showChevron: true
                                ) {
                                    if let url = URL(string: "https://x.com/gdelfava") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ModernSettingsRow(
                                    icon: "doc.text.fill",
                                    iconColor: .purple,
                                    title: "Terms & Privacy",
                                    subtitle: "Legal information",
                                    showChevron: true
                                ) {
                                    isTermsSheetPresented = true
                                }
                            }
                        }
                        .opacity(supportAppeared ? 1 : 0)
                        .offset(y: supportAppeared ? 0 : 30)
                        
                        // Enhanced General Section
                        ModernSectionView(title: "Account Actions") {
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                settingsViewModel.signOut(authViewModel: authViewModel)
                            }) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.red.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Sign Out")
                                            .soraBody()
                                            .fontWeight(.medium)
                                            .foregroundColor(.red)
                                        
                                        Text("Sign out of your account")
                                            .soraCaption()
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                        .opacity(generalAppeared ? 1 : 0)
                        .offset(y: generalAppeared ? 0 : 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSlideOverMenu = true
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Enhanced Toast overlay
                if showToast {
                    VStack {
                        Spacer()
                        Toast(message: "Publisher ID copied to clipboard", isShowing: $showToast)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 100)
                    }
                    .allowsHitTesting(false)
                    .zIndex(1000)
                }
            }
        }
        .onAppear {
            settingsViewModel.authViewModel = authViewModel
            Task {
                await settingsViewModel.fetchAccountInfo()
            }
            
            // Staggered animations for sections
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                profileAppeared = true
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                accountInfoAppeared = true
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                supportAppeared = true
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
                generalAppeared = true
            }
        }
        .onDisappear {
            // Reset animation states
            profileAppeared = false
            accountInfoAppeared = false
            supportAppeared = false
            generalAppeared = false
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: ["Check out AdRadar for AdSense! https://apps.apple.com/app/add own id here"])
        }
        .sheet(isPresented: $isWidgetSupportSheetPresented) {
            WidgetSupportSheet()
        }
        .sheet(isPresented: $isMailSheetPresented) {
            if MFMailComposeViewController.canSendMail() {
                MailView(toRecipients: ["support@adradar.app"], subject: "AdRadar Feedback", body: "") { result in
                    switch result {
                    case .success:
                        print("Email sent successfully")
                    case .failure(let error):
                        print("Email failed to send: \(error.localizedDescription)")
                    }
                }
            } else {
                // Enhanced fallback view
                VStack(spacing: 20) {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("Email Not Available")
                        .soraTitle2()
                        .fontWeight(.bold)
                    
                    Text("Email is not configured on this device. Please contact us directly at apps@delteqis.co.za")
                        .soraBody()
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isTermsSheetPresented) {
            TermsAndPrivacySheet()
        }
    }
}

// MARK: - Modern Components

struct ModernSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .soraCaption()
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            content
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
        }
    }
}

struct ModernSettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let showChevron: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .soraBody()
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .soraCaption()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isPressed ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EnhancedAccountInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var isCopyable: Bool = false
    var onCopy: (() -> Void)? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if isCopyable {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                    onCopy?()
                }
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .soraBody()
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(value)
                        .soraCaption()
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                Spacer()
                
                if isCopyable {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isPressed ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isCopyable)
    }
}

// MARK: - Supporting Views (keeping existing implementations but with minor improvements)

// ShareSheet view to present the system share sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    let toRecipients: [String]
    let subject: String
    let body: String
    let completion: (Result<Void, Error>) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(toRecipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.completion(.failure(error))
            } else {
                parent.completion(.success(()))
            }
            parent.presentation.wrappedValue.dismiss()
        }
    }
}

struct WidgetSupportSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image("LoginScreen")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        
                        Text("Widget Support")
                            .soraTitle2()
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        SupportInfoCard(
                            icon: "questionmark.circle.fill",
                            iconColor: .orange,
                            title: "Widgets not updating frequently?",
                            description: "Apple limits how often widgets can refresh in the background to preserve battery life."
                        )
                        
                        SupportInfoCard(
                            icon: "brain.head.profile.fill",
                            iconColor: .purple,
                            title: "The system learns your usage",
                            description: "iOS learns when you typically check the app and refreshes widgets just before those times."
                        )
                        
                        SupportInfoCard(
                            icon: "clock.fill",
                            iconColor: .blue,
                            title: "Give it about a week",
                            description: "Use the app regularly for a week and you should see more frequent widget updates as the system learns your patterns."
                        )
                        
                        SupportInfoCard(
                            icon: "bell.fill",
                            iconColor: .red,
                            title: "Enable notifications",
                            description: "Make sure notifications are enabled for AdRadar. Don't worry - we won't send you any annoying alerts!"
                        )
                        
                        SupportInfoCard(
                            icon: "envelope.fill",
                            iconColor: .green,
                            title: "Still having issues?",
                            description: "If widgets continue not updating, feel free to contact us using the 'Feedback' option in Settings."
                        )
                    }
                    .padding(.horizontal)
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Thanks for your support!")
                            .soraHeadline()
                            .fontWeight(.semibold)
                        
                        Text("— Guilio")
                            .soraSubheadline()
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Widget Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct SupportInfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .soraHeadline()
                    .fontWeight(.semibold)
                
                Text(description)
                    .soraBody()
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
}

struct TermsAndPrivacySheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            WebView(url: URL(string: "https://www.notion.so/AdRadar-Terms-Privacy-Policy-21539fba0e268090a327da6296c3c99a?source=copy_link")!)
                .navigationTitle("Terms & Privacy Policy")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .fontWeight(.medium)
                    }
                }
        }
    }
}

struct PaymentThresholdInfoSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "banknote.fill")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(.green)
                        }
                        .shadow(color: Color.green.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        Text("Payment Threshold")
                            .soraTitle2()
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        PaymentInfoCard(
                            icon: "target",
                            iconColor: .blue,
                            title: "What is the Payment Threshold?",
                            description: "The payment threshold in Google AdSense is the minimum earnings amount you must reach before Google issues a payment."
                        )
                        
                        PaymentInfoCard(
                            icon: "dollarsign.circle.fill",
                            iconColor: .green,
                            title: "Standard Threshold Amount",
                            description: "For most accounts, this threshold is $100 USD or the equivalent in local currency."
                        )
                        
                        PaymentInfoCard(
                            icon: "checkmark.circle.fill",
                            iconColor: .orange,
                            title: "Requirements for Payment",
                            description: "Once your balance exceeds the threshold and all account requirements (like tax and payment info) are complete, a payment is issued."
                        )
                        
                        PaymentInfoCard(
                            icon: "calendar.circle.fill",
                            iconColor: .purple,
                            title: "Payment Schedule",
                            description: "Payments are issued during the next payment cycle after meeting all requirements."
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
}

struct PaymentInfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .soraHeadline()
                    .fontWeight(.semibold)
                
                Text(description)
                    .soraBody()
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
}

// For preview
// MARK: - Payment Threshold Row

struct PaymentThresholdRow: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var isEditing = false
    @State private var tempThreshold = ""
    @State private var showAlert = false
    @State private var showInfoSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "target")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("Payment Threshold")
                        .soraBody()
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        showInfoSheet = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if isEditing {
                    HStack {
                        TextField("Enter amount", text: $tempThreshold)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 120)
                        
                        Button("Save") {
                            if let threshold = Double(tempThreshold), threshold > 0 {
                                settingsViewModel.updatePaymentThreshold(threshold)
                                isEditing = false
                                
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            } else {
                                showAlert = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.mini)
                        
                        Button("Cancel") {
                            tempThreshold = ""
                            isEditing = false
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                    }
                } else {
                    Text(formatCurrency(settingsViewModel.paymentThreshold))
                        .soraCaption()
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !isEditing {
                Button(action: {
                    tempThreshold = String(settingsViewModel.paymentThreshold)
                    isEditing = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .alert("Invalid Amount", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text("Please enter a valid amount greater than 0.")
                .soraBody()
        }
        .fullScreenCover(isPresented: $showInfoSheet) {
            PaymentThresholdInfoSheet()
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSlideOverMenu: .constant(false), selectedTab: .constant(0))
            .environmentObject(AuthViewModel())
            .environmentObject(SettingsViewModel(authViewModel: AuthViewModel()))
            .preferredColorScheme(.light)
        
        SettingsView(showSlideOverMenu: .constant(false), selectedTab: .constant(0))
            .environmentObject(AuthViewModel())
            .environmentObject(SettingsViewModel(authViewModel: AuthViewModel()))
            .preferredColorScheme(.dark)
    }
} 
