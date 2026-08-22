import SwiftUI

// MARK: - Premium Onboarding & Login View

public struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    // Page state machine
    private enum OnboardingPage {
        case welcome
        case about
        case features
        case security
        case login
    }
    
    @State private var currentPage: OnboardingPage = .welcome
    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var rememberMe = false
    @State private var shakeOffset: CGFloat = 0
    
    // Time-based greeting
    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good Morning"
        } else if hour < 17 {
            return "Good Afternoon"
        } else {
            return "Good Evening"
        }
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            switch currentPage {
            case .welcome:
                welcomePage
            case .about:
                aboutPage
            case .features:
                featuresPage
            case .security:
                securityPage
            case .login:
                loginPage
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: currentPage)
        .offset(x: shakeOffset)
        .onChange(of: authManager.authState) { _, newState in
            if case .failed = newState {
                triggerShake()
            }
        }
    }
    
    // MARK: - Page 1: Welcome Screen
    
    private var welcomePage: some View {
        ZStack {
            // High Resolution Boutique Background
            Image("login")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Dark elegant gold overlay gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.75),
                    Color.black.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Gold Crown Logo
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                        .shadow(color: MatteTheme.Colors.luxuryGold.opacity(0.4), radius: 8, y: 3)
                    
                    Text("LUXE MAISON")
                        .font(.system(size: 26, weight: .bold, design: .default))
                        .tracking(6)
                        .foregroundColor(.white)
                    
                    Text("CORPORATE ADMIN")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(3)
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                }
                .padding(.bottom, 60)
                
                // Welcome Text
                VStack(spacing: 14) {
                    Text("Welcome to\nLuxe Maison")
                        .font(.system(size: 42, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Text("The intelligent enterprise platform for managing luxury retail operations across boutiques.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineSpacing(3)
                }
                
                Spacer()
                
                // Progress Indicators
                HStack(spacing: 8) {
                    Circle().fill(MatteTheme.Colors.luxuryGold).frame(width: 7, height: 7)
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 7, height: 7)
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 7, height: 7)
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 7, height: 7)
                }
                .padding(.bottom, 12)
                
                // Action Buttons
                VStack(spacing: 14) {
                    Button {
                        currentPage = .about
                    } label: {
                        Text("Get Started")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [MatteTheme.Colors.luxuryGold, MatteTheme.Colors.chartGold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: MatteTheme.Colors.luxuryGold.opacity(0.3), radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        currentPage = .login
                    } label: {
                        Text("Skip")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Page 2: About Platform Screen
    
    private var aboutPage: some View {
        VStack(spacing: 0) {
            onboardingHeader(progress: 1)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Manage Every\nBoutique in\nOne Place")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .lineSpacing(3)
                        
                        Text("Manage store managers, products, pricing, merchandising, campaigns, and business policies from a single executive workspace.")
                            .font(.system(size: 14))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 24)
                    
                    // Boutique Organization Flow Chart Graphic
                    VStack(spacing: 16) {
                        // Corporate office node
                        VStack(spacing: 6) {
                            Image(systemName: "building.2.fill")
                                .font(.title3)
                                .foregroundColor(MatteTheme.Colors.luxuryGold)
                            Text("Corporate Office")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(MatteTheme.Colors.textPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(MatteTheme.Colors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(MatteTheme.Colors.luxuryGold.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Connecting Lines
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(MatteTheme.Colors.luxuryGold.opacity(0.3))
                                .frame(width: 1.5, height: 16)
                            
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(MatteTheme.Colors.luxuryGold.opacity(0.3))
                                    .frame(height: 1.5)
                                    .frame(maxWidth: .infinity)
                                
                                Circle()
                                    .fill(MatteTheme.Colors.luxuryGold)
                                    .frame(width: 5, height: 5)
                                
                                Rectangle()
                                    .fill(MatteTheme.Colors.luxuryGold.opacity(0.3))
                                    .frame(height: 1.5)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 48)
                            
                            HStack(spacing: 96) {
                                Rectangle()
                                    .fill(MatteTheme.Colors.luxuryGold.opacity(0.3))
                                    .frame(width: 1.5, height: 16)
                                Rectangle()
                                    .fill(MatteTheme.Colors.luxuryGold.opacity(0.3))
                                    .frame(width: 1.5, height: 16)
                                Rectangle()
                                    .fill(MatteTheme.Colors.luxuryGold.opacity(0.3))
                                    .frame(width: 1.5, height: 16)
                            }
                        }
                        
                        // Bottom Boutiques Row
                        HStack(spacing: 16) {
                            boutiqueNode(name: "Boutique 01")
                            boutiqueNode(name: "Boutique 02")
                            boutiqueNode(name: "Boutique 03")
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Grid summary of elements
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        aboutMetricCard(title: "Sales Overview", detail: "₹2,45,80,000", subtitle: "Total gross sales", hasChart: true)
                        aboutMetricCard(title: "Product Catalog", detail: "1,248", subtitle: "Products registered")
                        aboutMetricCard(title: "Active Boutiques", detail: "28", subtitle: "Across 4 regions")
                        aboutMetricCard(title: "Reports", detail: "View all analytics", subtitle: "Realtime updates", isLink: true)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
            .background(MatteTheme.Colors.dashboardBackground)
            
            onboardingFooter(
                backAction: { currentPage = .welcome },
                continueAction: { currentPage = .features }
            )
        }
        .background(MatteTheme.Colors.dashboardBackground)
    }
    
    private func boutiqueNode(name: String) -> some View {
        Text(name)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(MatteTheme.Colors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(MatteTheme.Colors.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
            )
    }
    
    private func aboutMetricCard(title: String, detail: String, subtitle: String, hasChart: Bool = false, isLink: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textSecondary)
                .tracking(0.5)
            
            Text(detail)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isLink ? MatteTheme.Colors.luxuryGold : MatteTheme.Colors.textPrimary)
            
            if hasChart {
                // Mini graphical mockup representation
                HStack(spacing: 2) {
                    ForEach([8, 12, 10, 15, 9, 14, 18], id: \.self) { height in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(MatteTheme.Colors.luxuryGold.opacity(0.3))
                            .frame(width: 4, height: CGFloat(height))
                    }
                }
                .frame(height: 20, alignment: .bottom)
                .padding(.vertical, 2)
            } else if isLink {
                HStack(spacing: 3) {
                    Text("Explore platform")
                        .font(.system(size: 9, weight: .semibold))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8))
                }
                .foregroundColor(MatteTheme.Colors.luxuryGold)
            }
            
            Text(subtitle)
                .font(.system(size: 9))
                .foregroundColor(MatteTheme.Colors.textTertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MatteTheme.Colors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Page 3: Features Screen
    
    private var featuresPage: some View {
        VStack(spacing: 0) {
            onboardingHeader(progress: 2)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Everything Your\nBusiness Needs")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 24)
                    
                    VStack(spacing: 14) {
                        featureRow(icon: "person.badge.shield.fill", title: "Store Manager Management", desc: "Add, manage and assign store managers across all boutiques.")
                        featureRow(icon: "shippingbox.fill", title: "Product Master", desc: "Manage your entire product catalogue with ease.")
                        featureRow(icon: "indianrupeesign.circle.fill", title: "Regional Pricing & Tax Rules", desc: "Configure pricing, GST, IGST, CGST, SGST and more.")
                        featureRow(icon: "chart.bar.fill", title: "Sales & Performance Reports", desc: "Track performance with powerful sales analytics.")
                        featureRow(icon: "heart.text.square.fill", title: "Inventory Health Reports", desc: "Review inventory health and stock movement reports.")
                        featureRow(icon: "megaphone.fill", title: "Promotions & Campaigns", desc: "Create campaigns and broadcast to targeted boutiques.")
                        featureRow(icon: "square.grid.3x3.fill", title: "Planograms", desc: "Create and distribute planograms and merchandising guidelines.")
                        featureRow(icon: "doc.text.fill", title: "Unified Business Reports", desc: "Generate consolidated reports across the business.")
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
            .background(MatteTheme.Colors.dashboardBackground)
            
            onboardingFooter(
                backAction: { currentPage = .about },
                continueAction: { currentPage = .security }
            )
        }
        .background(MatteTheme.Colors.dashboardBackground)
    }
    
    private func featureRow(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(MatteTheme.Colors.luxuryGold)
                .frame(width: 38, height: 38)
                .background(MatteTheme.Colors.luxuryGold.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .padding(12)
        .background(MatteTheme.Colors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Page 4: Security Screen
    
    private var securityPage: some View {
        VStack(spacing: 0) {
            onboardingHeader(progress: 3)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enterprise Grade\nSecurity")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .lineSpacing(3)
                        
                        Text("Your business data is protected using role-based access control, biometric authentication, two-factor authentication, and complete audit logs.")
                            .font(.system(size: 14))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 24)
                    
                    // Golden glowing shield graphics
                    VStack {
                        ZStack {
                            // Ring glow
                            Circle()
                                .stroke(MatteTheme.Colors.luxuryGold.opacity(0.15), lineWidth: 2)
                                .frame(width: 140, height: 140)
                                
                            Circle()
                                .stroke(MatteTheme.Colors.luxuryGold.opacity(0.3), lineWidth: 1)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [MatteTheme.Colors.luxuryGold.opacity(0.12), Color.clear],
                                        center: .center,
                                        startRadius: 5,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            // Golden Shield
                            Image(systemName: "shield.fill")
                                .font(.system(size: 58))
                                .foregroundColor(MatteTheme.Colors.luxuryGold)
                                .shadow(color: MatteTheme.Colors.luxuryGold.opacity(0.4), radius: 10, y: 4)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 16))
                                .foregroundColor(MatteTheme.Colors.deepBlack)
                                .offset(y: -4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    
                    // Security Checklist Icons
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        securityFeatureCard(icon: "faceid", title: "Face ID")
                        securityFeatureCard(icon: "lock.shield", title: "2FA Required")
                        securityFeatureCard(icon: "person.badge.key.fill", title: "Role Control")
                        securityFeatureCard(icon: "key.fill", title: "Encryption")
                        securityFeatureCard(icon: "clock.arrow.circlepath", title: "Audit Logs")
                        securityFeatureCard(icon: "checkmark.seal.fill", title: "Verified Users")
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
            .background(MatteTheme.Colors.dashboardBackground)
            
            onboardingFooter(
                backAction: { currentPage = .features },
                continueAction: { currentPage = .login }
            )
        }
        .background(MatteTheme.Colors.dashboardBackground)
    }
    
    private func securityFeatureCard(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(MatteTheme.Colors.luxuryGold)
                .frame(width: 44, height: 44)
                .background(MatteTheme.Colors.luxuryGold.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textPrimary)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(MatteTheme.Colors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Page 5: Login Screen
    
    private var loginPage: some View {
        GeometryReader { geo in
            let headerHeight = geo.size.height * 0.38
            
            ZStack(alignment: .top) {
                // Full-bleed boutique background image behind everything
                Image("login")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                // Dark gradient overlay on the image
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.55),
                        Color.black.opacity(0.35),
                        Color.black.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Brand logo pinned to the top area
                VStack(spacing: 10) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 36))
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                        .shadow(color: MatteTheme.Colors.luxuryGold.opacity(0.5), radius: 10, y: 4)
                    
                    Text("LUXE MAISON")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .tracking(6)
                        .foregroundColor(.white)
                    
                    Text("CORPORATE ADMIN")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(4)
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                }
                .frame(height: headerHeight)
                .frame(maxWidth: .infinity)
                
                // White card that starts after the header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Premium Greeting Header (no nested card wrapper)
                        HStack(alignment: .top, spacing: 0) {
                            VStack(alignment: .leading, spacing: 8) {
                                // Gold bar + time greeting
                                HStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(red: 175/255, green: 135/255, blue: 75/255))
                                        .frame(width: 3, height: 16)
                                    
                                    Text(timeOfDayGreeting.uppercased())
                                        .font(.system(size: 10, weight: .semibold))
                                        .tracking(2)
                                        .foregroundColor(Color(red: 175/255, green: 135/255, blue: 75/255))
                                }
                                
                                // User name
                                Text("Welcome Back")
                                    .font(.system(size: 28, weight: .bold, design: .default))
                                    .foregroundColor(Color(red: 28/255, green: 27/255, blue: 26/255))
                                
                                // Subtitle
                                Text("Ready to elevate your business today?")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(red: 120/255, green: 95/255, blue: 65/255))
                            }
                            
                            Spacer()
                            
                            // Gold avatar circle
                            ZStack {
                                Circle()
                                    .fill(Color(red: 175/255, green: 135/255, blue: 75/255))
                                    .frame(width: 48, height: 48)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Color(red: 175/255, green: 135/255, blue: 75/255).opacity(0.3), radius: 6, y: 3)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        
                        // Form fields
                        VStack(spacing: 14) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Corporate Email / Username")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color.black.opacity(0.55))
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 175/255, green: 135/255, blue: 75/255))
                                        .frame(width: 30, height: 30)
                                        .background(Color(red: 245/255, green: 237/255, blue: 220/255))
                                        .cornerRadius(7)
                                    
                                    TextField("Enter your corporate email", text: $username)
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                        .autocapitalization(.none)
                                }
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 220/255, green: 215/255, blue: 208/255), lineWidth: 1)
                                )
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Password")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color.black.opacity(0.55))
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 175/255, green: 135/255, blue: 75/255))
                                        .frame(width: 30, height: 30)
                                        .background(Color(red: 245/255, green: 237/255, blue: 220/255))
                                        .cornerRadius(7)
                                    
                                    if isPasswordVisible {
                                        TextField("Enter your password", text: $password)
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                            .autocapitalization(.none)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                            .autocapitalization(.none)
                                    }
                                    
                                    Button {
                                        isPasswordVisible.toggle()
                                    } label: {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(Color.black.opacity(0.3))
                                            .font(.system(size: 14))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 220/255, green: 215/255, blue: 208/255), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Remember me + Forgot password
                        HStack {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    rememberMe.toggle()
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(rememberMe ? Color(red: 175/255, green: 135/255, blue: 75/255) : Color.clear)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(rememberMe ? Color.clear : Color.black.opacity(0.2), lineWidth: 1.5)
                                            )
                                        if rememberMe {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    Text("Remember Me")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color.black.opacity(0.55))
                                }
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            Button {} label: {
                                Text("Forgot Password?")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 175/255, green: 135/255, blue: 75/255))
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Error state
                        if case let .failed(errorMsg) = authManager.authState {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(MatteTheme.Colors.error)
                                Text(errorMsg)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(MatteTheme.Colors.error)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(MatteTheme.Colors.errorLight)
                            .cornerRadius(10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Sign In button
                        Button {
                            Task {
                                await authManager.login(username: username, password: password)
                            }
                        } label: {
                            ZStack {
                                if case .authenticating = authManager.authState {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    HStack {
                                        Spacer()
                                        Text("Sign In")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 175/255, green: 135/255, blue: 75/255),
                                        Color(red: 200/255, green: 165/255, blue: 100/255)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color(red: 175/255, green: 135/255, blue: 75/255).opacity(0.25), radius: 8, y: 4)
                        }
                        .disabled(username.isEmpty || password.isEmpty)
                        .opacity((username.isEmpty || password.isEmpty) ? 0.6 : 1)
                        .buttonStyle(.plain)
                        
                        // OR divider
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color.black.opacity(0.08))
                                .frame(height: 1)
                            Text("or")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.black.opacity(0.3))
                            Rectangle()
                                .fill(Color.black.opacity(0.08))
                                .frame(height: 1)
                        }
                        
                        // Face ID button
                        Button {
                            username = "Admin"
                            password = "1234"
                            Task {
                                await authManager.login(username: username, password: password)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "faceid")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(red: 175/255, green: 135/255, blue: 75/255))
                                Text("Sign In with Face ID")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.black.opacity(0.75))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(red: 220/255, green: 215/255, blue: 208/255), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Secure access note
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 175/255, green: 135/255, blue: 75/255))
                                .frame(width: 32, height: 32)
                                .background(Color(red: 245/255, green: 237/255, blue: 220/255))
                                .clipShape(Circle())
                            
                            Text("Secure access for authorized\nCorporate Admin users only.")
                                .font(.system(size: 11))
                                .foregroundColor(Color.black.opacity(0.4))
                                .lineSpacing(2)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 250/255, green: 247/255, blue: 240/255))
                        .cornerRadius(12)
                        
                        // Footer
                        HStack(spacing: 4) {
                            Text("New device?")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black.opacity(0.4))
                            Text("Verify with 2FA")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 175/255, green: 135/255, blue: 75/255))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(red: 175/255, green: 135/255, blue: 75/255))
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                }
                .background(Color(red: 252/255, green: 250/255, blue: 245/255))
                .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                .padding(.top, headerHeight - 16)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Onboarding Helpers
    
    private func onboardingHeader(progress: Int) -> some View {
        HStack {
            Button {
                withAnimation {
                    switch currentPage {
                    case .about: currentPage = .welcome
                    case .features: currentPage = .about
                    case .security: currentPage = .features
                    default: break
                    }
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(MatteTheme.Colors.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Progress dots
            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { index in
                    Circle()
                        .fill(index == progress ? MatteTheme.Colors.luxuryGold : Color.gray.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
            
            Spacer()
            
            Button {
                currentPage = .login
            } label: {
                Text("Skip")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(MatteTheme.Colors.surface)
                    .cornerRadius(20)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(MatteTheme.Colors.dashboardBackground)
    }
    
    private func onboardingFooter(backAction: @escaping () -> Void, continueAction: @escaping () -> Void) -> some View {
        HStack(spacing: 16) {
            Button(action: backAction) {
                Text("Back")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(MatteTheme.Colors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            
            Button(action: continueAction) {
                Text("Continue")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [MatteTheme.Colors.luxuryGold, MatteTheme.Colors.chartGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(MatteTheme.Colors.surface)
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: -4)
    }
    
    private func triggerShake() {
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            shakeOffset = -12
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                shakeOffset = 12
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    shakeOffset = -12
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        shakeOffset = 0
                    }
                }
            }
        }
    }
}

// MARK: - RoundedCorner Shape Helper
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
