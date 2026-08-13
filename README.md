# 📦 Scanbox

> Delivery confirmation powered by QR Code scanning and photo proof — built for logistics companies.

![iOS](https://img.shields.io/badge/iOS-16%2B-blue?style=flat-square)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift)
![UIKit + SwiftUI](https://img.shields.io/badge/UI-UIKit%20%2B%20SwiftUI-purple?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

---

## 📱 About

**Scanbox** is an iOS app designed for logistics companies to ensure accurate and verifiable deliveries. The delivery person scans a **QR Code or barcode** at the destination and then takes a **photo of the delivery location** as proof of completion.

This simple flow helps companies:
- ✅ Confirm the right package was delivered to the right address
- 📉 Reduce costs from failed or disputed deliveries
- ⭐ Improve customer satisfaction by minimizing bad reviews

---

## ✨ Features

- 📷 **QR Code & Barcode scanning** — fast and reliable package identification
- 🖼️ **Photo proof** — delivery confirmation with a location photo
- 🏢 **Built for logistics teams** — designed around real delivery workflows
- 📱 **Native iOS experience** — built with UIKit and SwiftUI

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| Swift | Primary language |
| SwiftUI | Declarative UI components |
| UIKit | Navigation and legacy views |
| AVFoundation | Camera & barcode scanning |
| PhotosUI | Photo capture and picker |

---

## ⚙️ Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Physical device recommended (camera required)

---

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/Arakraques/ArakraquesHackaton.git
   cd scanbox
   ```

2. **Open in Xcode**
   ```bash
   open Scanbox.xcodeproj
   ```

3. **Run the app**
   - Select a simulator or connect a physical device
   - Press `Cmd + R` to build and run
   - Note: camera features require a real device

---

## 📸 Screenshots

---

## 🗂️ Project Structure

```
ScanBox/
├── ScanBoxApp.swift       # App entry point
├── ContentView.swift      # Main view / navigation root
├── ScannerView.swift      # QR Code & barcode scanning screen
└── Assets.xcassets        # Images, icons and colors
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">Made with ❤️ for logistics</p>
