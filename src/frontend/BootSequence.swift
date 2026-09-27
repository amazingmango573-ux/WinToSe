import SwiftUI

// MARK: - App Entry Point & Boot Sequence
struct BootSequenceView: View {
    // Create the input manager ONCE here at the very top of the app
    @StateObject private var inputManager = EmulationInputManager()
    
    // Animation States
    @State private var terminalLines: [String] = []
    @State private var showLogo = false
    @State private var fadeOutToOS = false
    
    // Haptics
    private let bootHaptics = UINotificationFeedbackGenerator()
    private let stepHaptics = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if !fadeOutToOS {
                // LAYER: Boot UI
                VStack(alignment: .leading, spacing: 8) {
                    if showLogo {
                        HStack {
                            Image(systemName: "window.casement.closed")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0, green: 0.47, blue: 0.83))
                            Text("A15 BIOS v2.01")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .transition(.opacity)
                        .padding(.bottom, 20)
                    }
                    
                    ForEach(terminalLines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                    }
                    Spacer()
                    
                    HStack {
                        Spacer()
                        if inputManager.isGamepadConnected {
                            Text("🎮 Gamepad Detected")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onAppear {
                    runSmoothBootSequence()
                }
            } else {
                // LAYER: Main OS View
                // Pass the existing input manager down so it doesn't disconnect
                MainEmulatorView(inputManager: inputManager)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: fadeOutToOS)
        .ignoresSafeArea()
    }
    
    func runSmoothBootSequence() {
        bootHaptics.prepare()
        
        let bootSteps = [
            (0.5, "Initializing A15 Bionic architecture... OK"),
            (1.0, "Allocating 2560MB system RAM... OK"),
            (1.8, "Mounting NVMe virtual drive: windows_handheld.img"),
            (2.5, "Loading QEMU virtio drivers..."),
            (3.2, "SPICE display server listening on port 5900"),
            (4.0, "Booting Windows 10 Kernel...")
        ]
        
        withAnimation(.easeIn(duration: 1.0)) { showLogo = true }
        
        for step in bootSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + step.0) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    terminalLines.append(step.1)
                }
                stepHaptics.impactOccurred()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            bootHaptics.notificationOccurred(.success)
            fadeOutToOS = true
        }
    }
}

// MARK: - Main Windows OS View
struct MainEmulatorView: View {
    // Use @ObservedObject so it listens to the manager passed from BootSequenceView
    @ObservedObject var inputManager: EmulationInputManager
    
    @State private var isOSKVisible = true
    
    var body: some View {
        ZStack(alignment: .bottom) { 
            
            // LAYER 1: The Windows/QEMU Display
            Color.black.edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack(spacing: 20) {
                        Text("Windows 10 Desktop (Emulated)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("A15 Bionic @ 3.23 GHz | 2.5 GB RAM allocated")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                )
            
            // LAYER 2: Application UI & Toggle Button 
            VStack {
                HStack {
                    Spacer()
                    Button(action: { 
                        // Haptic tick when pressing the keyboard toggle button
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        isOSKVisible.toggle() 
                    }) {
                        Image(systemName: isOSKVisible ? "keyboard.chevron.compact.down" : "keyboard")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            // LAYER 3: The Retro On-Screen Keyboard Overlay
            if isOSKVisible || !inputManager.isHardwareKeyboardConnected {
                RetroKeyboardView(inputManager: inputManager)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 10)
            }
        }
        .animation(.default, value: isOSKVisible || !inputManager.isHardwareKeyboardConnected)
        .ignoresSafeArea()
        .supportedOrientations(.landscapeRight) 
    }
}