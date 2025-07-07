TimeWell
TimeWell is a comprehensive Flutter application designed to help users manage their time effectively, build healthy habits, track challenges, and stay organized with timers and a calendar.

Features
Habit Statistics: Visualize your habit completion rates and daily trends with intuitive charts (powered by syncfusion_flutter_charts). Get daily motivational quotes to keep you going.

Challenges: Embark on structured challenges with daily projects.

Create custom challenges with a specified duration in days.

Organize projects for each day of a challenge, including titles, descriptions, external links, and goals.

Mark projects as complete and track overall challenge progress.

Persistently save challenge data using shared_preferences.

Timers: (Based on the TimerNotifier and TimerModel provided in conversation history) Manage various countdown timers with custom titles, notes, target dates, and repeat types.

Calendar View: (Implied by CalendarScreen) Provides a visual overview of your schedule and progress.

Settings: (Implied by SettingsScreen) Customize app preferences, including theme (light/dark mode).

Data Persistence: All user data (habits, challenges, timers) is saved locally using shared_preferences.

Technologies Used
Flutter: The UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.

Riverpod: A robust and scalable state management solution for Flutter applications.

shared_preferences: For local data persistence.

url_launcher: To open external links (e.g., project links in challenges).

uuid: For generating unique IDs for challenges and projects.

intl: For internationalization and date/time formatting.

syncfusion_flutter_charts: For rendering interactive charts in the Habit Statistics section.

Setup and Installation
To get a local copy up and running, follow these simple steps.

Prerequisites
Flutter SDK installed (version 3.x.x or higher recommended)

Dart SDK (comes with Flutter)

Installation
Clone the repository:

git clone <your-repository-url>
cd time_well

Install dependencies:

flutter pub get

Generate Launcher Icons (Optional but Recommended):
If you've configured flutter_launcher_icons in your pubspec.yaml (as discussed previously), run:

flutter pub run flutter_launcher_icons:main

Run the application:

flutter run

Usage
Navigation: Use the bottom navigation bar to switch between Challenges, Timers (Timeline), Calendar, and Settings screens.

Challenges:

On the "My Challenges" screen, tap the floating action button to create a new challenge.

Enter a title, duration in days, and a start date.

Tap on an existing challenge to view its daily breakdown.

On a daily challenge page, tap the + icon next to a day to add a new project.

Fill in project details (title, description, link, goal).

Mark projects as complete using the checkbox.

Tap on a project to expand its details.

Habit Statistics: Access this screen (e.g., from a dedicated tab or button, depending on your HomeScreen setup) to see visual summaries of your habits.

Timers: The "Timeline" tab will likely display your countdown timers. Use the floating action button to add new timers.

Settings: Adjust app themes and other preferences.

Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

Fork the Project

Create your Feature Branch (git checkout -b feature/AmazingFeature)

Commit your Changes (git commit -m 'Add some AmazingFeature')

Push to the Branch (git push origin feature/AmazingFeature)

Open a Pull Request

License
Distributed under the MIT License. See LICENSE for more information.

Contact
Your Name/Project Maintainer - your_email@example.com
Project Link: https://github.com/your_username/time_well (Replace with your actual GitHub link)
