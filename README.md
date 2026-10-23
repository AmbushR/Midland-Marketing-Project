# Midland Marketing – Second Level Project

An attendance manager app built with Flutter. People log in, check in and out for the day, and look back at their history. What each person can see and do depends on their role: Admin, Senior Staff or Staff.

Everything runs on the device with local storage, so there is no backend or internet connection to set up.

---

## 1. README

### What the app does

- Login with email and password, and the session is remembered after the app closes
- Check in and check out once per day
- Personal attendance history for every role
- Admin can see everyone's attendance, add Senior Staff and Staff accounts, and read all comments
- Senior Staff can see Staff attendance and leave feedback comments on it
- Staff can only see their own attendance, and can add work notes to their own days (and read the feedback they get)

### What you need first

- Flutter SDK (the project uses Dart `^3.11.4`, so use a recent stable Flutter)
- Android Studio or VS Code with the Flutter plugin
- An Android emulator, a real device, or Chrome

Run `flutter doctor` first and fix anything it complains about.

### Installation

1. Unzip the project and open a terminal inside the `midlandmarketing` folder.

2. Get the packages:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

   To pick a device yourself:

   ```bash
   flutter devices
   flutter run -d <device-id>
   ```







### Architecture overview

The app follows a feature-first clean architecture. Every feature is split into three layers:

```
presentation  →  domain  ←  data
(UI + Bloc)     (rules)    (storage)
```

- Presentation has the pages, widgets and Blocs. It only talks to use cases.
- Domain holds the entities, repository interfaces and use cases. The business rules (who can see what) live here, and it does not know about Flutter or storage.
- Data implements the repositories using `shared_preferences` and the demo data.



### Testing the three roles

These demo accounts are already in the app. On the login screen you can also tap a demo tile to fill the fields.

Test Login Credentials

1. Admin

Email: admin@test.com
Password: Admin@123

2. Senior Staff

Email: senior@test.com
Password: Senior@123

3. Staff

Email: staff@test.com
Password: Staff@123


Admin:
1. Log in, then check in and check out from the top card.
2. Open Attendance records. You should see everybody, and the role filter chips are there.
3. Open Add senior staff & staff and create a new user. Log out and log in with the new account to confirm it works.
4. Open any record and tap the comments button. You can read comments but not write on other people's records.

Senior Staff:
1. Log in. The dashboard shows staff numbers only, with no admin or other senior staff.
2. Open Staff attendance & comments and add a feedback comment on a staff record.
3. Try to find the Users screen. There is no link to it, and opening the route directly sends you back home.

Staff:
1. Log in, then check in and check out.
2. Open My attendance history. You only see your own days.
3. Tap Add note on today's card or any past day and write a short work note.
4. Log in as a Senior Staff first, leave feedback on this staff member, then log back in as that staff and you will see the feedback in the same comments sheet.



## 2. Screen recording

A short demo covering login, check-in, check-out, attendance history and role-based access.

Video link: https://drive.google.com/drive/folders/1vf6KnmO3cAielZO9aIaWRbgtqs5jxwoh?usp=sharing

Screenshots: https://drive.google.com/drive/folders/1FMJM1NlaBycOerSlhBbx0oxSV-l-ugMd?usp=sharing


## 3. Technical notes

### Folder structure

```
lib/
├── main.dart                  App entry point
├── core/
│   ├── di/                    get_it setup (injection.dart)
│   ├── router/                go_router config, route names, redirect rules
│   ├── theme/                 Colors and the app theme
│   ├── widgets/               Shared widgets (cards, avatars, hero header...)
│   ├── utils/                 Date helpers
│   └── error/                 Custom exceptions
└── features/
    ├── auth/                  Login, session restore, logout
    ├── users/                 User list and the admin "add user" flow
    ├── attendance/            Check in/out, history, team records
    ├── comments/              Feedback and work notes on attendance records
    └── dashboard/             Admin, Senior Staff and Staff home screens
```

Inside each feature the folders are `data/`, `domain/` and `presentation/`, which keeps the same pattern everywhere.

### State management

I used Bloc for everything on screen.

- `AuthBloc` lives for the whole app. It restores the saved session on start and the router listens to it, so logging in or out moves the user to the right screen automatically.
- The other Blocs are created per screen (`DashboardBloc`, `TodayAttendanceBloc`, `TeamRecordsBloc`, `AttendanceHistoryBloc`, `UsersBloc`, `CommentsBloc`), so they start clean every time a screen opens.
- Events go in, and a single immutable state comes out. Loading, loaded and failure are always handled in the UI.

### Local data storage

Data is stored as JSON strings in `shared_preferences`:

Local Storage Keys and Their Purpose

1. `current_user`:
Stores the currently logged-in user's details, excluding the password, so the session persists after an app restart.

2. `app_users`:
Stores the user list, including the default demo accounts and any additional users created by the admin.

3. `attendance_records`:
Stores all employee check-in and check-out records.

4. `attendance_comments`:
Stores feedback, comments, and work-related notes.

- One attendance record exists per user per day. The id is `userId_yyyy-MM-dd`, which stops a double check-in.
- On the first launch the app generates about a week of sample attendance, relative to today's date, so the screens are not empty.
- Passwords are stored in plain text because this is a demo. A real app would use a backend and never keep passwords like this.

### Permission logic

The rules are in one place on purpose, so the UI does not decide who can see what.

- Route guard (`app_router.dart`): the redirect sends logged-out users to login, and sends anyone without permission back home if they open `/records` or `/users`.
- Use cases double check the same rules (`GetTeamAttendance`, `GetDashboardSummary`, `AddUser`, `AddComment`), so even if a screen were reached by mistake, the data would not be returned.
- Comments (`CommentPolicy`):
    - Anyone can add a work note on their own record
    - Senior Staff can add feedback on a Staff record
    - Admin can read comments but not write on other people's records

So there are three layers of protection: the buttons are hidden, the route is blocked, and the use case refuses.