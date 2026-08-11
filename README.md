# Babe's Notebook

A private daily journal app — a calm space to write about each day and pour out your heart to God.

Built with **Flutter** (Android) and **Supabase** (auth, sync, storage).

---

## Features

- **Daily journal entries** — one entry per day, with auto-save while you write
- **"Dear Father,"** opening — a gentle letter-style editor
- **Home screen** — greeting, today's entry, recent history
- **Calendar** — see which days have entries, tap to read or write
- **Private by default** — Supabase Row Level Security; only she sees her entries
- **Warm, personal design** — cream, rose, and serif typography

---

## Prerequisites

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.16+)
2. [Supabase](https://supabase.com) project (free tier works)
3. Android Studio or device for running the app

---

## 1. Generate platform folders

This repo contains the Dart source. Generate Android/iOS scaffolding once:

```bash
cd "/Users/kidus/Documents/Projects/Babe's Notebook"
flutter create . --project-name babes_notebook --org com.babesnotebook
flutter pub get
```

---

## 2. Set up Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Open **SQL Editor** and run:

   `supabase/migrations/001_journal_entries.sql`

3. In **Authentication → Providers**, enable Email
4. Copy your **Project URL** and **anon public** key from **Settings → API**

---

## 3. Run the app

Pass Supabase credentials at build time (recommended — keeps keys out of source):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Or build a release APK:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 4. Deploy to her phone

### Option A — Direct APK (simplest)

1. Build the release APK (above)
2. Send the APK to her phone (AirDrop, Google Drive, etc.)
3. Install (enable "Install from unknown sources" if prompted)

### Option B — Google Play (private)

1. Create a [Google Play Developer](https://play.google.com/console) account ($25 one-time)
2. Build an App Bundle:

   ```bash
   flutter build appbundle --release \
     --dart-define=SUPABASE_URL=... \
     --dart-define=SUPABASE_ANON_KEY=...
   ```

3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Use **Internal testing** or **Closed testing** so only she can install it

### Option C — GitHub + CI (optional)

Push to GitHub. Use GitHub Actions to build signed APKs on each release tag. Store Supabase keys in **Repository Secrets**:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

---

## Project structure

```
lib/
├── config/          # Theme, Supabase config
├── models/          # JournalEntry
├── providers/       # Riverpod providers
├── router/          # GoRouter navigation
├── screens/         # UI screens
├── services/        # Auth & journal API
└── widgets/         # Reusable components
supabase/
└── migrations/      # Database schema
```

---

## Stack

| Layer    | Technology        |
|----------|-------------------|
| App      | Flutter           |
| Backend  | Supabase          |
| Auth     | Supabase Auth     |
| Database | PostgreSQL (RLS)  |
| Repo     | GitHub            |

Vercel is not needed for the mobile app. Add it later only if you want a web companion.

---

## First account

On first launch, tap **Create an account** and sign up with her email. Supabase will send a confirmation email if email confirmation is enabled in your project settings (you can disable it for a personal app under **Authentication → Providers → Email**).

---

Made with love for daily letters to God.
