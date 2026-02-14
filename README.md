 AgriShare
      AgriShare is a cross-platform, mobile-first application built using Flutter and Firebase that enables farmers to rent agricultural equipment from nearby owners through a transparent, role-based booking system.The platform improves access to machinery, reduces idle equipment time, and promotes efficient resource sharing in agriculture.

-> Features

* Role-based access (Farmer, Owner, Admin)
* Real-time equipment listings
* Booking request and approval system
* Booking status tracking (Pending / Approved)
* Admin monitoring and analytics
* Transparent 2% platform commission

-> Tech Stack

* Flutter (Dart)
* Firebase Authentication
* Firebase Firestore
* Firebase Storage (optional)

-> Architecture

Flutter App  
→ Firebase Authentication  
→ Firestore Database  
→ Real-time Sync  

->  Commission Model

* Platform charges a 2% commission
* Applied only after successful booking approval
* Ensures transparency for all users

-> Setup

1. Clone the repository
2. Create a Firebase project
3. Enable Email/Password authentication
4. Create Firestore database
5. Replace `firebase_options.dart`
6. Run:

