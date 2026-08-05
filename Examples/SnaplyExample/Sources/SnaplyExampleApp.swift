import SwiftUI
import SnaplyAgent

/// A complete Snaply integration in one file.
///
/// The screen is deliberately plain — a fake order with a failed payment, which is the situation
/// someone actually contacts support about. What matters is `Snaply.on`, `Snaply.configure`,
/// `Snaply.showSupportCode`, and the one `.snaplyRedact()` on the card field.

/// Replace with your own key from the Snaply console (Products → your product → API key).
///
/// It is not a secret. It identifies the workspace, ships inside every copy of your app, and is
/// checked server-side against your product's allowed bundle id — so a copy lifted from your binary
/// is useless from another app. Committing it is fine.
private let snaplyKey = "snap_live_REPLACE_WITH_YOUR_KEY"

@main
struct SnaplyExampleApp: App {
    var body: some Scene {
        WindowGroup { CheckoutView() }
    }
}

@MainActor
final class SupportModel: ObservableObject {
    @Published var status = "Connecting…"

    func start() {
        // 1. Listen BEFORE configuring. A support request can arrive as soon as the device
        //    registers, and callbacks attached afterwards would miss it. All of them are optional.
        Snaply.on(SnaplyCallbacks(
            onRequestShown: { [weak self] in self?.say("Support asked to see your screen…") },
            onAllowed: { [weak self] _ in self?.say("Screenshot shared ✓") },
            onDenied: { [weak self] in self?.say("You declined the request.") },
            onExpired: { [weak self] in self?.say("The request expired.") },
            onError: { [weak self] error in self?.say("Snaply error: \(error.localizedDescription)") },
            onLiveEnded: { [weak self] _ in self?.say("Live session ended.") }
        ))

        // 2. Register. `user` is optional — without it the device stays anonymous and support finds
        //    it by the support code. If they sign in later, call Snaply.identify(id:name:phone:)
        //    then, and Snaply.reset() on sign-out.
        Snaply.configure(
            key: snaplyKey,
            user: SnaplyUser(id: "usr_20481", name: "Maya Kowalski")
        ) { [weak self] error in
            guard let self else { return }
            if let error {
                // Worth handling rather than swallowing: `invalid_key` means the placeholder above
                // is still there, and `origin_mismatch` means this app's bundle id is not on the
                // product's allowed list.
                self.say("Could not connect: \(error.localizedDescription)")
            } else {
                self.say("Connected — this device is now visible in the console.")
            }
        }
    }

    private func say(_ message: String) {
        Task { @MainActor in self.status = message }
    }
}

struct CheckoutView: View {
    @StateObject private var model = SupportModel()
    @State private var card = "4242 4242 4242 4242"
    @State private var address = "12 Rue des Lilas, Paris"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Acme Delivery").font(.title2.bold())
            Text("Order #8412 · Margherita pizza · 2")
                .font(.footnote).foregroundStyle(.secondary)

            // The one line that matters most in this file.
            //
            // The SDK redacts SECURE text fields automatically and nothing else. A card number is
            // not a secure field, so without .snaplyRedact() it is captured in full. Mark anything
            // a support agent should not read — card numbers, addresses, medical notes, another
            // customer's data on screen.
            //
            // The box is painted on the device BEFORE the image is encoded, so the real pixels
            // never leave the phone. It is not a server-side blur that could be undone.
            Text("Card number").font(.caption).foregroundStyle(.secondary)
            TextField("Card number", text: $card)
                .textFieldStyle(.roundedBorder)
                .snaplyRedact()

            Text("Delivery address").font(.caption).foregroundStyle(.secondary)
            TextField("Address", text: $address)
                .textFieldStyle(.roundedBorder)
                .snaplyRedact(label: "HIDDEN")

            Text("Payment failed — card declined (402)")
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))

            // 3. What the person reads out to an agent so support can find this device.
            Button("Show support code") { Snaply.showSupportCode() }
                .buttonStyle(.borderedProminent)

            Text(model.status).font(.caption2).foregroundStyle(.secondary)
            Spacer()
        }
        .padding(24)
        .onAppear { model.start() }
    }
}
