LearnTrack :

LearnTrack is a modern attendance-tracking system built using Flutter, Firebase, and Hotspot-based verification.
It is designed for colleges, schools, and training institutes where teachers can quickly start/end classes, and attendance is captured only when students connect to the teacher’s hotspot.

Core Idea:
Instead of GPS or manual attendance, LearnTrack verifies students via hotspot connectivity, reducing proxy attendance and ensuring real-time authentication.

Features:

1. Teacher Portal
Start a new class only when hotspot is ON
Prevent multiple active classes
End class & log completion time
Auto-save SSID + time + class session details in Firestore
Elegant, clean UI
Real hotspot detection using Platform Channels

Hotspot-Based Authentication:
Detects whether the teacher’s hotspot is active
Ensures that only students connected to that hotspot can mark attendance (student-side logic in progress)

2. Firebase Integration
Firestore stores:
Teacher name 
Subject
Start time
End time
SSID
Active class flag

Cross-Platform Support :
Designed primarily for Android (because hotspot APIs are Android-specific)
Flutter UI supports iOS, but hotspot logic is Android-only

3. 

| Technology                   | Purpose                |
| ---------------------------- | ---------------------- |
| **Flutter**                  | Cross-platform UI      |
| **Dart**                     | Application logic      |
| **Firebase Firestore**       | Cloud data storage     |
| **Hotspot Platform Channel** | Real hotspot detection |
| **Connectivity Plus**        | Network status         |
| **Network Info Plus**        | SSID, IP detection     |


4. Installation Instructions
Follow these steps to run LearnTrack locally:
1) Clone the repository- git clone https://github.com/uday-mahajan/LearnTrack.git
                         cd LearnTrack
2) Install dependencies- flutter pub get
3) Configure Firebase  - flutterfire configure
4) Run the project     - flutter run

Note:
Hotspot APIs work only on real Android devices (not emulators).

5. Why LearnTrack?
Traditional attendance systems are slow & easily manipulated
QR codes can be shared
GPS has error margins and privacy issues
Bluetooth is inconsistent
Hotspot-based verification ensures:
Low chance of proxy
Fast
Works offline (local hotspot check)

LearnTrack aims to modernize attendance tracking using everyday smartphone capabilities.
It’s lightweight, secure, and scalable — perfect for small and large institutions.
