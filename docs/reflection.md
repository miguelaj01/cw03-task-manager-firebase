# Reflection

## 1) Objective + Expectation
The main objective of this assignment was to build a stateful Flutter app with Firebase Firestore that supports full CRUD operations and nested subtasks. Before building it, I expected `setState()` to handle most of the updating, but I learned that once Firestore streams were connected through `StreamBuilder`, the database updates handled most of the UI refresh automatically.

## 2) What I Obtained
I successfully built a task management app that can add, read, update, and delete tasks in Firestore. The app also supports subtasks, task completion toggling, delete confirmation, task search, dark mode support, and clear UX states for loading, empty data, and errors.

## 3) Evidence
The best evidence is that tasks remain in the app even after restarting it because they are stored in Firestore instead of a temporary local list. Another piece of evidence is the live update behavior: when a task is added or checked off, the list refreshes immediately through the Firestore stream without a manual reload. My commit history also shows the app growing phase by phase from setup, to model, to service, to UI, then subtasks and polish.

## 4) Analysis
The easiest objective was the base UI because Flutter widgets like `TextField`, `ListView`, and `Checkbox` are straightforward to organize. The hardest part was structuring Firestore data for nested subtasks and making sure updates changed the correct subtask entry. I first thought I would keep a separate local task list and sync it manually, but that became unnecessary once `StreamBuilder` was connected to `.snapshots()`. Debugging mostly came from checking field names carefully, testing each CRUD action one by one, and making sure the task model matched Firestore keys exactly.

## 5) Improvement Plan
If I continued this project, the first improvement I would make is adding Firebase Authentication so each user sees only their own task list. After that, I would add pagination or query limits for performance if the app scaled to a very large number of tasks. I would also refactor state management into Provider or Riverpod to make the app easier to maintain as features grow.

## Critical Thinking Prompts

### Which objective was easiest to achieve, and why?
The easiest objective was building the basic UI because Flutter already gives reusable widgets that made the layout simple to organize.

### Which objective was hardest, and what misconception did you correct?
The hardest objective was nested subtasks because I had to update items inside a list of maps stored in Firestore. My misconception was thinking local state alone would manage everything, when in reality Firestore streams did most of the work once the data flow was set up correctly.

### Where did expected behavior not match obtained behavior, and how did you debug it?
At first I expected `setState()` to be the main reason the list refreshed after changes. What I obtained instead was real-time sync from Firestore through `StreamBuilder`. I debugged this by testing add, toggle, and delete actions repeatedly and watching whether the data still appeared after restarting the app.

### How does your commit history show growth from a basic task list to a cloud-backed app?
The commit history starts with project setup and Firebase configuration, then moves to the task model, service layer, UI, subtasks, and final polish. This shows a clear progression from a basic app structure to a working cloud-backed CRUD application.

### If this app scaled to thousands of tasks per user, what design change would you make first?
The first design change I would make is query optimization with pagination and possibly user-based collections. That would reduce load time and make the app more scalable.
