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
 
 Build Commands

```bash
flutter pub get
flutter run

architecture diagram
## 🏗 Architecture Diagram

```text
┌───────────────────────────┐
│        Flutter App        │
│  (Android / iOS / Web)    │
│                           │
│  • Farmer UI              │
│  • Owner UI               │
│  • Admin UI               │
└─────────────┬─────────────┘
              │
              ▼
┌───────────────────────────┐
│   Firebase Authentication │
│  • Email / Password Login │
│  • Role-based Access      │
└─────────────┬─────────────┘
              │
              ▼
┌───────────────────────────┐
│   Firebase Firestore      │
│                           │
│  • Users Collection       │
│  • Equipment Collection   │
│  • Bookings Collection    │
│  • Commission Tracking    │
│                           │
│  (Real-time Sync)         │
└─────────────┬─────────────┘
              │
              ▼
┌───────────────────────────┐
│  Firebase Storage         │
│ (Equipment Images - Opt.) │
└───────────────────────────┘

-----app flow diagram

## 🔄 App Flow Diagram

```text
          ┌─────────────────┐
          │   App Launch    │
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │ Login / Register│
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │ Role Detection  │
          │ (Farmer/Owner/  │
          │      Admin)     │
          └───────┬─────────┘
                  │
     ┌────────────┼─────────────┐
     │            │             │
     ▼            ▼             ▼

┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ Farmer Flow │ │ Owner Flow  │ │ Admin Flow  │
└─────┬───────┘ └─────┬───────┘ └─────┬───────┘

Farmer:           Owner:            Admin:
──────────        ──────────        ──────────
Browse Equipment  Add Equipment      View Metrics
     │                 │                 │
Select Equipment   Manage Equipment   Total Users
     │                 │                 │
Book Equipment     View Bookings      Total Equipment
     │                 │                 │
Booking Pending    Approve / Reject   Total Bookings
     │                 │                 │
Approved Booking   Booking Status     Commission Stats
     │
View My Bookings



team members
REHMA MANAL MANKARATHODI
SAYIFA V

LINKS
demo WORKING  link:  https://agrishare-app.web.app

demo video link ; https://drive.google.com/file/d/12L_u3LuTwm0BYWDMkVm2QblEkPo_ob2g/view?usp=sharing
