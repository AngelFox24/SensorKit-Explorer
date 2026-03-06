# SensorKit Explorer

[![Swift](https://img.shields.io/badge/Swift-5.7-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-26-blue.svg)](https://developer.apple.com/xcode/)
[![iOS](https://img.shields.io/badge/iOS-17.6-green.svg)](https://developer.apple.com/ios/)

---

## Overview

Welcome to **SensorKit Explorer**, a sample iOS application designed to demonstrate the integration of various device sensors using Swift and modern architectural principles. This project showcases how to collect and manage sensor data such as location and motion information in a clean and maintainable way.

**Note:** Two demonstration videos are attached because the export of the AHAP file and the location permission prompt were recorded separately.

**Minimum iOS Version:** This project requires iOS 17.6 or later to utilize the new `@Observable` property wrapper for more efficient observation.

---

## Features

- Real-time location updates using `CLLocationManager`.
- Motion data collection through `CMMotionManager`.
- Clean and testable architecture using MVVM and Clean Code principles.
- Sensor data streams managed with direct service calls and proper cancellation.
- Simple UI to visualize sensor information.

---

## Architecture

SensorKit Explorer is built using the **MVVM (Model-View-ViewModel)** pattern combined with **Clean Code** practices to ensure maintainability and scalability. Dependencies are injected to facilitate testing and modularity.

Note: The originally intended `SensorBus` event bus was not implemented due to time constraints. Instead, direct service calls are used with stream subscriptions properly canceled to manage sensor data flows.

---

## Sensor Update Frequencies

- **Location Manager**: Updates are configured to provide location changes with a desired accuracy and frequency suitable for most applications.
- **Motion Manager**: Motion updates are set to a frequency that balances responsiveness with battery efficiency.

---

## Devices Tested

- iPhone 12 Pro Max running iOS 26.2
- iPhone Air running iOS 26.1

---

## Known Limitations

- Lack of SensorBus implementation limits event-driven communication.
- No automated tests included.
- Sensor update frequencies are fixed and may need tuning for specific use cases.
- UI is minimal and primarily for demonstration purposes.
- AHAP files can be imported into the app but currently are not in the correct Core Haptics format and need proper formatting.
- Dark Mode is not currently supported.

---

## Future Improvements

- Implement `SensorBus` for event-driven sensor data handling.
- Add comprehensive unit and UI tests.
- Enhance UI for better visualization and user interaction.
- Provide configuration options for sensor update intervals.
- Expand support for additional sensors and data types.
- Improve AHAP export to produce files in the correct Core Haptics format.
- Plan to add multiple environments (Development, Production) using `.xcconfig` files and Xcode schemes.
- Add Dark Mode support for the app.

---

Thank you for exploring SensorKit Explorer! If you have any questions or suggestions, feel free to reach out.
