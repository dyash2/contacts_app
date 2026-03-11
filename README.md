# 📱 Contacts App — Flutter Assignment

A **Google Contacts-inspired** mobile application built with **Flutter**, following a clean **MVC architecture** with **Provider** for state management and **SQLite** for fully offline local storage.

---

## ✨ Features

| Feature | Details |
|---|---|
| **View Contacts** | Alphabetically grouped list with A–Z section headers |
| **Add Contact** | Form with name, phone, email, company, address & notes |
| **Edit Contact** | Pre-filled form; update any field |
| **Delete Contact** | Confirmation dialog before permanent deletion |
| **Contact Profile** | Detail screen with Call / Message / Video actions |
| **Call Contact** | One-tap call via system dialer (`tel:` URL scheme) |
| **Favorite Contacts** | Star/unstar; dedicated Favorites tab |
| **Search Contacts** | Real-time search by name, phone, or email — works on both tabs |
| **Duplicate Detection** | Blocks saving if same name + phone already exists |
| **Splash Screen** | Animated branded launch screen |

---

## 🏗️ Architecture — MVC + Provider

This project strictly separates concerns across three layers:

```
┌─────────────────────────────────────────────┐
│                   VIEW                       │
│  Screens & Widgets (Flutter UI only)         │
│  context.watch / context.read                │
└───────────────────┬─────────────────────────┘
                    │ delegates to
┌───────────────────▼─────────────────────────┐
│               PROVIDER                       │
│  ContactProvider (ChangeNotifier)            │
│  Owns all UI state, notifies widgets         │
└───────────────────┬─────────────────────────┘
                    │ calls
┌───────────────────▼─────────────────────────┐
│              CONTROLLER                      │
│  ContactController (pure Dart, no Flutter)   │
│  Business logic, grouping, duplicate checks  │
└───────────────────┬─────────────────────────┘
                    │ reads/writes
┌───────────────────▼─────────────────────────┐
│               DATABASE                       │
│  DatabaseHelper (SQLite singleton)           │
│  All raw SQL lives here                      │
└─────────────────────────────────────────────┘
```


## 📁 Project Structure

```
contacts_app/
├── android/
│   └── app/src/main/AndroidManifest.xml     # CALL_PHONE permission + tel:/mailto: queries
├── lib/
│   ├── main.dart                            # App entry point
│   ├── models/
│   │   └── contact_model.dart               # Contact data class
│   ├── controllers/
│   │   └── contact_controller.dart          # Pure business logic
│   ├── providers/
│   │   └── contact_provider.dart            # ChangeNotifier state management
│   ├── views/
│   │   ├── screens/
│   │   │   ├── splash_screen.dart           # Animated launch screen
│   │   │   ├── home_screen.dart             # BottomNav host + search bar
│   │   │   ├── contacts_tab.dart            # All contacts, grouped A–Z
│   │   │   ├── favorites_tab.dart           # Starred contacts
│   │   │   ├── contact_detail_screen.dart   # Profile screen
│   │   │   └── add_edit_contact_screen.dart # Add / Edit form
│   │   └── widgets/
│   │       ├── contact_avatar.dart          # Coloured initials avatar
│   │       ├── contact_list_tile.dart       # Reusable list row
│   │       └── confirm_dialog.dart          # Generic confirmation dialog
│   └── utils/
│       ├── app_theme.dart                   # Material 3 theme + colour palette
│       └── database_helper.dart             # SQLite CRUD singleton
├── pubspec.yaml
└── README.md
```

---

## 🛠️ Tech Stack

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | State management — `ChangeNotifier` binding |
| `sqflite` | ^2.3.2 | SQLite local database |
| `path` | ^1.9.0 | DB file path resolution |
| `url_launcher` | ^6.2.5 | `tel:` dialer and `mailto:` email intents |
| `permission_handler` | ^11.3.0 | Runtime `CALL_PHONE` permission |

> All models use hand-written `toMap()` / `fromMap()` — **no** `json_serializable`, **no** `build_runner`.

---

## 🗄️ Database Schema

```sql
CREATE TABLE contacts (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  name         TEXT    NOT NULL,
  phone        TEXT    NOT NULL,
  email        TEXT,
  address      TEXT,
  company      TEXT,
  notes        TEXT,
  is_favorite  INTEGER NOT NULL DEFAULT 0,   -- 0 = false, 1 = true
  avatar_color TEXT                          -- AARRGGBB hex e.g. FF3D5A99
);
```

Duplicate detection query (runs before every insert/update):

```sql
SELECT id FROM contacts
WHERE name = ? AND phone = ? AND id != ?   -- id != ? excluded when editing
LIMIT 1;
```

---

## 🚀 Installation & Setup

### Prerequisites

- Flutter SDK **≥ 3.0.0** → [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK **≥ 3.0.0** (bundled with Flutter)
- Android Studio **or** VS Code with the Flutter & Dart plugins
- Android device / emulator (API **21+**) or iOS device / simulator (iOS **12+**)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/contacts_app.git
cd contacts_app

# 2. Install dependencies
flutter pub get

# 3. Run in debug mode on a connected device or emulator
flutter run

# 4. Build a release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

> **Android note:** The app requests `CALL_PHONE` permission at runtime when the user first taps **Call**. Grant it to enable direct dialling.

---

## 📱 Screen-by-Screen Usage

### Splash Screen
- Animated logo shown on launch.
- Auto-navigates to Home after 400 milliseconds.

### Home — Contacts Tab
- Displays all contacts grouped **A–Z** with section headers.
- **Search bar** (below app bar) — tap to activate; filters by name, phone, or email in real time.
- Tap the **＋ FAB** to open the Add Contact form (FAB is hidden on the Favorites tab).
- Tap any row to open the Contact Profile.

### Home — Favorites Tab
- Lists only starred contacts.
- Search bar works here too — filters favorites by name, phone, or email.
- FAB is hidden on this tab.

### Contact Profile
- Shows avatar, name, and action buttons: **Call · Email**.
- **Details** section: Mobile, Email, Company, Address, Notes.
- **Favorite toggle** — star icon at the appbar.
- **⋮ menu** in the app bar also provides Edit and Delete options.

### Add Contact
- Required fields: **Name**, **Phone** (min 10 digits).
- Optional fields: Email (validated format), Company, Notes.
- Duplicate check: if the same name **and** phone already exist, save is blocked and a snackbar is shown.
- Tap **Save** (top-right) to persist. Tap **←** to discard.

### Edit Contact
- Same form as Add, pre-filled with existing data.
- Duplicate check excludes the contact being edited (so it doesn't flag itself).

### Delete Contact
- Confirmation dialog: **Cancel** or **Delete**.
- On confirm, contact is permanently removed and both tabs refresh instantly.

---

## 📸 Screenshots

> Place screenshots in a `/screenshots/` folder and update the paths below.

| Splash | Contacts | Favorites | Profile | Add Contact | Delete Dialog |
|---|---|---|---|---|---|
| ![splash](screenshots/splash.png) | ![contacts](screenshots/contacts.png) | ![favorites](screenshots/favorites.png) | ![profile](screenshots/profile.png) | ![add](screenshots/add.png) | ![delete](screenshots/delete.png) |

---
