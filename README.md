# LastMinuteExam
<div align="center">

<img src="assets/icon.png" alt="ExamAI Logo" width="100" height="100" style="border-radius: 20px"/>

# ⚡ LastMinuteExam

### AI-Powered Last Minute Exam Preparation App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Auth%20%26%20DB-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4o%20Mini-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

**Turn your notes into exam questions in seconds.**
Upload a PDF, DOCX, PPTX or TXT file and get AI-generated viva questions, subjective answers and a last-minute cheat sheet — instantly.

[📱 Download APK (android)](https://drive.google.com/file/d/1jBgVQ-W3F5vLNYXUUDrv0ZMQaYFbVIkQ/view?usp=sharing) · [🔗 Backend Repo](https://github.com/lakshaygaba18/LastMinuteExam-Backend) · [🐛 Report Bug](https://github.com/lakshaygaba18/LastMinuteExam/issues)

</div>

---

## 🎯 Problem It Solves

Every engineering student knows the feeling — exam tomorrow, 200 pages of notes to revise. **LastMinuteExam** turns that panic into preparation. Upload your teacher's PDF and within 60 seconds you have:

- Viva questions with answers for oral exams
- 1, 3, 5 and 10 mark questions with structured answers
- A cheat sheet with key formulas, dates and definitions
- Favourite questions screen for weak topics revision
- Saved exam sreen for offline revision and backup

---

## ✨ Features

| Feature | Description |
|---|---|
| 👤 Cross-Device Account Sync | Login from any device using the same account and instantly access all your saved exams |
| 🤖 **AI Question Generation** | GPT-4o Mini generates genuine, topic-specific questions from your actual notes |
| 📄 **Multi-format Support** | PDF, DOCX, PPTX and TXT files all supported |
| 🎯 **4 Study Modes** | Viva, Subjective (1/3/5/10 marks), Cheat Sheet |
| 🔐 **User Authentication** | Sign up / login with email via Supabase Auth |
| ☁️ **Cloud Sync** | Saved exams sync across devices via Supabase Database |
| ⚡ **Smart Caching** | Same document never hits the API twice — instant response |
| 🌙 **Dark / Light Mode** | Full theme support with animated toggle |
| 📱 **Responsive UI** | Works on phones, tablets and desktops |
| ⭐ **Favourites** | Star and save important questions for quick revision |
| 🔍 **Search & Sort** | Find any saved exam by name, sort by date |

---

## 🏗️ Architecture

```
LastMinuteExam (Flutter)
├── lib/
│   ├── config/
│   │   └── supabase_config.dart          # Supabase credentials (gitignored)
│   ├── screens/
│   │   ├── home_screen.dart              # Dashboard with recent exams
│   │   ├── login_screen.dart             # Auth screen
│   │   ├── upload_screen.dart            # File upload + generation
│   │   ├── mode_selection_screen.dart    # Choose study mode
│   │   ├── viva_screen.dart              # Flashcard-style viva Q&A
│   │   ├── subjective_menu_screen.dart   # Pick mark category
│   │   ├── subjective_questions_screen.dart  # Expandable Q&A cards
│   │   ├── cheat_sheet_screen.dart       # Last-minute revision
│   │   ├── saved_tests_screen.dart       # All saved exams
│   │   └── favorites_screen.dart        # Starred questions
│   ├── services/
│   │   ├── exam_api_service.dart         # HTTP calls to backend
│   │   ├── exam_storage_service.dart     # Local + cloud storage
│   │   ├── auth_service.dart             # Supabase auth wrapper
│   │   └── favorites_service.dart       # Local favourites
│   └── widgets/
│       └── premium_button.dart          # Reusable UI components
|   main.dart
```

---

## 🛠️ Tech Stack

- **Framework:** Flutter 3.x / Dart 3.x
- **Authentication:** Supabase Auth (email/password)
- **Database:** Supabase PostgreSQL (cloud exam sync)
- **Local Storage:** SharedPreferences
- **HTTP Client:** Dart `http` package
- **File Picker:** `file_picker` package
- **State Management:** StatefulWidget + setState

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x installed
- Android Studio or VS Code
- A Supabase account (free)

### Installation

```bash
# Clone the repo
git clone https://github.com/lakshaygaba18/LastMinuteExam.git
cd LastMinuteExam

# Install dependencies
flutter pub get

# Create config file (gitignored — never commit this)
mkdir -p lib/config
cat > lib/config/supabase_config.dart << 'DART'
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
DART

# Run the app
flutter run
```

### Supabase Setup

Create this table in your Supabase SQL Editor:

```sql
create table saved_exams (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  created_at timestamptz default now(),
  data text not null
);

alter table saved_exams enable row level security;

create policy "Users can manage their own exams"
on saved_exams for all
using (auth.uid() = user_id);
```

---

## 📱 Download

> **Android APK** — Direct download available. Enable "Install from unknown sources" on your device.

*Play Store listing coming soon.*

---

## 🔗 Related

- **Backend API:** [LastMinuteExam-Backend](https://github.com/lakshaygaba18/LastMinuteExam-Backend) — Spring Boot REST API with OpenAI integration
- **Live API:** `https://exam-engine-backend.onrender.com`

---

## 👨‍💻 Author

**Lakshay Gaba**
- GitHub: [@lakshaygaba18](https://github.com/lakshaygaba18)
- Built during B.Tech — designed, developed and deployed solo

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
Built with ❤️ for every student who has an exam tomorrow
</div>
