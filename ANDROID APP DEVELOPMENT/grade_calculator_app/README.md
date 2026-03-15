# 📊 Grade Calculator — Desktop App
### Built with Flutter + Dart | Dark Blue UI | Excel Import/Export

---

## 🎯 Project Overview

A professional **desktop Grade Calculator** application that:
- Uploads a student Excel file (with exam marks)
- Automatically calculates grades and pass/fail status
- Displays a beautiful dark-blue dashboard with class statistics
- Exports the results to a new Excel file for download

---

## 🏗️ OOP Architecture

```
Calculator (abstract base class)
    └── GradeCalculator (derived class — inherits Calculator)

Concepts demonstrated:
  ✅ Inheritance        — GradeCalculator extends Calculator
  ✅ Polymorphism       — calculate() overrides abstract method
  ✅ Abstract class     — Calculator cannot be instantiated directly
  ✅ Lazy/Delayed init  — late keyword used throughout
  ✅ Lambdas            — Arrow functions (=>) everywhere
  ✅ Factory pattern    — Calculator.ofType(type) factory constructor
```

---

## 🖥️ Step 1 — Install Flutter for Desktop (VS Code)

### 1.1 Install Flutter SDK

**Windows:**
```
1. Go to https://flutter.dev/docs/get-started/install/windows
2. Download Flutter SDK zip
3. Extract to: C:\flutter
4. Add C:\flutter\bin to your PATH environment variable
```

**macOS:**
```bash
brew install --cask flutter
```

**Linux (Ubuntu/Debian):**
```bash
sudo snap install flutter --classic
```

### 1.2 Verify Installation
```bash
flutter doctor
```
All items should show ✅ (Android is NOT required — we only need Desktop)

### 1.3 Enable Desktop Support
```bash
flutter config --enable-windows-desktop   # Windows
flutter config --enable-macos-desktop     # macOS
flutter config --enable-linux-desktop     # Linux
```

### 1.4 Verify desktop target is available
```bash
flutter devices
# You should see: Windows (desktop) or macOS (desktop) or Linux (desktop)
```

---

## 🔧 Step 2 — VS Code Setup

### 2.1 Install VS Code Extensions
Open VS Code → Extensions (Ctrl+Shift+X) → Install:
- **Flutter** (by Dart Code) — required
- **Dart** (by Dart Code) — required

### 2.2 Open Project in VS Code
```bash
# Open project folder
code grade_calculator_app
```

---

## 📦 Step 3 — Install Dependencies

```bash
cd grade_calculator_app
flutter pub get
```

This installs:
| Package | Purpose |
|---|---|
| `excel` | Read & write .xlsx files |
| `file_picker` | Open file dialog / save dialog |
| `path_provider` | Get Documents directory path |
| `flutter_animate` | Smooth animations |

---

## ▶️ Step 4 — Run the App

```bash
# Run on Windows desktop
flutter run -d windows

# Run on macOS desktop
flutter run -d macos

# Run on Linux desktop
flutter run -d linux
```

**In VS Code:** Press `F5` → Select your desktop device from the dropdown.

---

## 📁 Step 5 — Prepare Your Student Excel File

Your Excel file **must** have these column headers in row 1:

| Student ID | Student Name | Exam Mark |
|---|---|---|
| STU001 | John Doe | 78 |
| STU002 | Jane Smith | 45 |
| STU003 | Bob Johnson | 92 |

> Column headers are **not case-sensitive** — "student id", "Student ID", "STUDENT ID" all work.

---

## 🎓 Grading Scale

| Mark Range | Grade |
|---|---|
| 75 – 100 | A |
| 70 – 74 | A- |
| 65 – 69 | B+ |
| 60 – 64 | B |
| 55 – 59 | B- |
| 50 – 54 | C+ |
| 45 – 49 | C |
| 40 – 44 | D |
| Below 40 | F |

**Pass:** ≥ 40 | **Fail:** < 40

---

## 📂 Project Structure

```
grade_calculator_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   └── calculator.dart          # OOP: Calculator + GradeCalculator + StudentRecord
│   ├── screens/
│   │   └── home_screen.dart         # Main UI screen
│   ├── utils/
│   │   ├── app_theme.dart           # Dark blue theme
│   │   └── excel_service.dart       # Excel read/write logic
│   └── widgets/
│       └── app_widgets.dart         # Reusable UI components
├── pubspec.yaml                     # Dependencies
└── README.md
```

---

## 🛠️ Build for Release (Executable)

```bash
# Windows — creates .exe
flutter build windows

# macOS — creates .app
flutter build macos

# Linux — creates binary
flutter build linux
```

Output location: `build/windows/runner/Release/`

---

## 🐛 Troubleshooting

**"No desktop device found"**
```bash
flutter config --enable-windows-desktop
flutter devices   # check again
```

**"pub get" fails**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**File picker doesn't open**
- On Linux, install: `sudo apt-get install zenity` or `sudo apt-get install kdialog`

---

## 💡 Key Dart/OOP Concepts Used

```dart
// 1. Abstract class
abstract class Calculator { ... }

// 2. Inheritance
class GradeCalculator extends Calculator { ... }

// 3. Polymorphism — override abstract method
@override
double calculate(List<double> values) => average(values);

// 4. Late (Delayed) Initialisation
late final GradeCalculator _calculator;
// ... assigned in initState(), not at declaration

// 5. Lambda / Arrow functions
static String _computeGrade(double mark) => mark >= 75 ? 'A' : ...;
List<StudentRecord> processStudents(rawData) =>
    rawData.map((row) => StudentRecord(...)).toList();

// 6. Factory constructor
factory Calculator.ofType(String type) { ... }
```
