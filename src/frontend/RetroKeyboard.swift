import SwiftUI

// Step 1.1: Define a custom, blocky, old-school keyboard color palette.
extension Color {
    static let retroBeige = Color(red: 0.85, green: 0.85, blue: 0.83)
    static let retroDarkBeige = Color(red: 0.75, green: 0.75, blue: 0.73)
}

struct RetroKeyboardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold, design: .monospaced)) // The retro PC font
            .foregroundColor(.black)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(configuration.isPressed ? Color.retroDarkBeige : Color.retroBeige)
                    .overlay( // Creates a subtle 'shadow' effect typical of old keys
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            .offset(y: configuration.isPressed ? 0 : 2)
                    )
            )
    }
}

// Step 1.2: The On-Screen Keyboard Layout
struct RetroKeyboardView: View {
    @ObservedObject var inputManager: EmulationInputManager
    
    // Simplifed layout optimized for the SE 3 screen
    private let keysRow1 = ["ESC", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "BKSP"]
    private let keysRow2 = ["TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "ENTER"]
    private let keysRow3 = ["CTRL", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "CTRL"]
    private let keysRow4 = ["SHIFT", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "SHIFT"]
    private let keysRow5 = ["ALT", "SPC", "WIN", "SPC", "ALT", "<-", "^", "v", "->"]
    
    var body: some View {
        VStack(spacing: 6) { // Compact spacing for small screen
            keyboardRow(keys: keysRow1)
            keyboardRow(keys: keysRow2)
            keyboardRow(keys: keysRow3)
            keyboardRow(keys: keysRow4)
            keyboardRow(keys: keysRow5)
        }
        .padding(8)
        .background(Color.retroDarkBeige.opacity(0.95)) // Translucent overlay background
        .cornerRadius(10)
        // Set the final keyboard size constraint. We can adjust this width dynamically later.
        .frame(maxWidth: 550)
    }
    
    // A helper function to create a standardized keyboard row.
    @ViewBuilder
    private func keyboardRow(keys: [String]) -> some View {
        HStack(spacing: 4) {
            ForEach(keys, id: \.self) { key in
                Button(action: {
                    // Step 1.3: Inject the *virtual* keystroke into the shared manager.
                    // print("Virtual key pressed: \(key)")
                    // This uses the same logic as the GCKeyboard did connect.
                    self.inputManager.sendVirtualScancode(for: key)
                }) {
                    Text(key)
                        // Dynamic key width for functional keys like SPC and CTRL
                        .frame(minWidth: key == "SPC" ? 120 : (key.count > 1 ? 40 : 25))
                }
                .buttonStyle(RetroKeyboardButtonStyle())
            }
        }
    }
}