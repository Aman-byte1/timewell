# ⏳ TimeWell

**TimeWell** is a comprehensive Flutter application designed to help users manage their time effectively, build healthy habits, track challenges, and stay organized with timers and a calendar.

---

## 🚀 Features

### 📊 Habit Statistics
- Visualize habit completion trends using beautiful charts.
- Powered by `syncfusion_flutter_charts`.
- Get daily motivational quotes to keep you going.

### 🏆 Challenges
- Start structured challenges with daily projects.
- Create custom challenges by specifying a duration.
- Organize each day's projects with titles, descriptions, external links, and goals.
- Mark tasks as complete and monitor overall challenge progress.
- Data is stored persistently using `shared_preferences`.

### ⏱️ Timers
- Countdown timers with custom titles, notes, target dates, and repeat options.
- Built with `TimerNotifier` and `TimerModel`.

### 📅 Calendar View
- View upcoming challenges, events, and timers visually using a calendar (via `CalendarScreen`).

### ⚙️ Settings
- Customize preferences, including light/dark theme toggle.

---

## 🧠 Tech Stack

| Technology                  | Use Case                                |
|----------------------------|------------------------------------------|
| **Flutter**                | UI development                          |
| **Riverpod**               | State management                        |
| **shared_preferences**     | Local data persistence                  |
| **url_launcher**           | Opening project external links          |
| **uuid**                   | Generating unique IDs                   |
| **intl**                   | Date/time formatting                    |
| **syncfusion_flutter_charts** | Charting and visual analytics       |

---

## 🛠️ Setup & Installation

### ✅ Prerequisites
- Flutter SDK 3.x or higher
- Dart SDK (included with Flutter)
- Android Studio or Visual Studio Code

### 📥 Installation Steps

Clone the repository:

```bash
git clone https://github.com/Aman-byte1/time_well.git
cd time_well
````

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Build the release APK:

```bash
flutter build apk --release --no-tree-shake-icons
```

---

## 💡 Usage Guide

### 🔁 Navigation

Use the bottom navigation bar to access:

* **Challenges**
* **Timeline (Timers)**
* **Calendar**
* **Settings**

### 🧗 Challenges

1. Tap ➕ to create a challenge.
2. Enter title, duration (in days), and start date.
3. Tap on any day to add daily projects.
4. Provide project title, description, goals, and external links.
5. Mark completed tasks and track progress.

### 📈 Habit Stats

* Access from home or statistics tab.
* View pie or line charts of habit tracking.
* See your streaks and completions visually.

### 🕒 Timers

* View and manage countdowns under Timeline.
* Add new timers with custom name, notes, deadlines, and repetition.

### ⚙️ Settings

* Customize the theme.
* Future: add notifications and reminder preferences.

---

## 🤝 Contributing

Contributions are what make the open-source community amazing!

1. Fork the repo
2. Create your Feature Branch:
   `git checkout -b feature/AmazingFeature`
3. Commit your changes:
   `git commit -m 'Add some AmazingFeature'`
4. Push to the branch:
   `git push origin feature/AmazingFeature`
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

---

## 📬 Contact

**Amanuel Gizachew**
[GitHub](https://github.com/Aman-byte1)
Project Repo: [https://github.com/AmanuelGizachew/time\_well]([https://github.com/Aman-byte1/timewell])

---

> TimeWell helps you own your time and build your future — one challenge, habit, and minute at a time.

```

Let me know if you want help generating screenshots, badges, or auto-deployment instructions for GitHub Pages or Play Store later!
```
