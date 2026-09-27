import SwiftUI
import GameController

class EmulationInputManager: ObservableObject {
    
    // Track if a hardware keyboard is currently paired.
    @Published var isHardwareKeyboardConnected: Bool = false
    
    init() {
        listenForPhysicalKeyboard()
    }
    
    private func listenForPhysicalKeyboard() {
        // ... (Hardware connection logic as before) ...
        NotificationCenter.default.addObserver(forName: .GCKeyboardDidConnect, object: nil, queue: .main) { _ in
            self.isHardwareKeyboardConnected = true
            self.bindHardwareKeys()
        }
        
        NotificationCenter.default.addObserver(forName: .GCKeyboardDidDisconnect, object: nil, queue: .main) { _ in
            self.isHardwareKeyboardConnected = false
        }

        if GCKeyboard.coalesced != nil {
            self.isHardwareKeyboardConnected = true
            bindHardwareKeys()
        }
    }
    
    private func bindHardwareKeys() { /* ... unchanged hardware scancode logic ... */ }

    // Step 2.1: Implement the function that converts a virtual key tap into a Scancode
    func sendVirtualScancode(for key: String) {
        // Map the key string back to a USB HID Scancode.
        // For example: "ENTER" maps to 0x28, "BKSP" maps to 0x2A, "1" maps to 0x1E, "A" maps to 0x04.
        
        print("Emulating Virtual Scancode for: \(key)")
        // QEMUEngine.shared.sendKey(keyName: key, isDown: true)
        // QEMUEngine.shared.sendKey(keyName: key, isDown: false) // Simulate a full click
    }
}