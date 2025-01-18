# Nawykomat


## Table of Contents
1. [Project Overview](#project-overview)
2. [Motivation and Objectives](#motivation-and-objectives)
3. [Architecture](#architecture)
4. [Frontend Layer](#frontend-layer)
5. [Backend Layer](#backend-layer)
6. [Database Layer](#database-layer)
7. [Key Features](#key-features)
8. [Statistics and Analysis](#statistics-and-analysis)
9. [Data Flow](#data-flow)
10. [Screenshots](#screenshots)
11. [Future Enhancements](#future-enhancements)
12. [Conclusion](#conclusion)

---

## Project Overview
Nawykomat is a multi-platform habit management application designed for Android, iOS, and web browsers. The project aims to support users in building positive habits and enhancing personal growth through intuitive design and advanced technologies.

---

## Motivation and Objectives
- **Efficient Time Management:**
  - Enables users to schedule and prioritize their daily tasks efficiently.
  - Provides a visual calendar for better organization and overview of habits.
  - Integrates reminders that align with the user's specific routines and preferences.

- **Maintaining Healthy Habits:**
  - Offers customizable habit templates for quick setup.
  - Tracks habit consistency with detailed insights on performance.
  - Delivers motivational reminders and progress notifications.

- **Personal Growth:**
  - Includes a self-assessment feature to evaluate habit effectiveness.
  - Provides recommendations based on user performance and goals.
  - Promotes reflective practices with progress summaries.

- **Commercial Potential:**
  - Features freemium and subscription models tailored to user preferences.
  - Integrates with external platforms like wearables to enhance utility.

---

## Architecture
- **Frontend:**
  - Developed with Flutter for seamless cross-platform compatibility.
  - Adheres to best practices in responsive design, ensuring usability across devices.

- **Backend:**
  - Leverages Firebase Functions for dynamic server-side processes.
  - Ensures efficient handling of user authentication and data security.

- **Database:**
  - Implements Firebase Firestore for structured and scalable data storage.
  - Supports real-time synchronization and offline access.

---

## Frontend Layer
- **Framework:**
  - Built using Flutter with Dart, delivering high performance and rapid development.

- **Material Design:**
  - Creates a visually consistent and intuitive user experience.

- **Customization:**
  - Includes light and dark themes, color options, and adaptable text sizes.

- **Push Notifications:**
  - Supports scheduled notifications to reinforce habit consistency.

---

## Backend Layer
- **Firebase Functions:**
  - Dynamically handles tasks like habit tracking and notification delivery.

- **Firebase Authentication:**
  - Offers multi-factor authentication with options like email, Google, and social logins.

- **Real-Time Sync:**
  - Ensures user data is consistently updated across all devices.

---

## Database Layer
- **Firestore:**
  - Stores user data as structured documents in scalable collections.

- **Firebase Storage:**
  - Handles multimedia files such as user-uploaded images or custom reminders.

- **Real-Time Sync:**
  - Automatically updates data across devices to maintain continuity.

---

## Key Features
- **Registration and Login:**
  - Includes multi-method authentication for user convenience and security.

- **Habit Management:**
  - Allows users to create, modify, and delete habits effortlessly.
  - Features tagging and categorization for easier habit organization.

- **Statistics and Reports:**
  - Provides in-depth habit analysis through graphs, summaries, and insights.

---

## Statistics and Analysis
- **Daily and Weekly Summaries:**
  - Displays visual summaries of daily and weekly progress.

- **Percentage-Based Insights:**
  - Highlights completion rates and trends with dynamic charts.

- **Monthly Reports:**
  - Generates comprehensive reports for long-term performance tracking.

---

## Data Flow
1. **Adding Habits:**
   - Users input habit details such as name, schedule, and frequency via a user-friendly form.
   - Data is processed locally before being securely transferred to Firebase.

2. **Backend Processing:**
   - Habit data is validated and formatted on the server.
   - Processed information is stored in structured collections within Firestore.

3. **Real-Time Display:**
   - User interfaces dynamically fetch and display updated data.
   - Supports interactive components like graphs and charts for visualization.

---

## Screenshots
### Welcome Screens

### Login and Registration
![Login Screen](https://via.placeholder.com/800x400?text=Login+Screen)
![Registration Screen](https://via.placeholder.com/800x400?text=Registration+Screen)

### Habit Management
![Habit Management Screen](https://via.placeholder.com/800x400?text=Habit+Management+Screen)
![Add/Edit Habits Screen](https://via.placeholder.com/800x400?text=Add+Habits+Screen)

### Notifications and Settings
![Notification Settings Screen](https://via.placeholder.com/800x400?text=Notification+Settings+Screen)
![General Settings Screen](https://via.placeholder.com/800x400?text=General+Settings+Screen)

### Customization Options
![Dark Mode Screen](https://via.placeholder.com/800x400?text=Dark+Mode+Screen)
![Language Selection Screen](https://via.placeholder.com/800x400?text=Language+Selection+Screen)

### Statistics
![Daily Statistics Screen](https://via.placeholder.com/800x400?text=Daily+Statistics+Screen)
![Weekly Statistics Screen](https://via.placeholder.com/800x400?text=Weekly+Statistics+Screen)
![Monthly Reports Screen](https://via.placeholder.com/800x400?text=Monthly+Reports+Screen)

### Web Version
![Web Version Screen 1](https://via.placeholder.com/800x400?text=Web+Version+Screen+1)
![Web Version Screen 2](https://via.placeholder.com/800x400?text=Web+Version+Screen+2)

---

## Future Enhancements
- **Wearable Device Integration:** Sync with smartwatches.
- **Social Features:** Add groups and competitions.
- **AI Recommendations:** Tailored habit suggestions.
- **Gamification:** Reward systems for motivation.

---

## Conclusion
Nawykomat is an innovative tool for personal growth, blending cutting-edge technology and intuitive design. It empowers users to build and maintain positive habits while offering commercial scalability through advanced features.

---

## Authors
**Adam Głaz**  
Supervisor: **Dr. Eng. Karol Suchenia**

---

## References
- [Atomic Habits - James Clear](https://example.com)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Clean Code - Robert C. Martin](https://example.com)
