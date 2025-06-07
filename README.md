# TeamNougat – Task 1: Student Record Management System

## Demo (Video and Screenshots)

Access the working demo and screenshots here:
[Google Drive - Demo Folder](https://drive.google.com/drive/folders/1Sv6GZVCycXRWyPTc3z_SthsVPpmuft0I?usp=sharing)

---

## Project Overview

The objective of this project was to develop a **Student Record Management System**, based on a reference UI and functional demo shared via WhatsApp. The application features account authentication and CRUD operations on student data, all powered by Firebase.

### Key Development Steps:

* Initialized Firebase within the main project file and implemented the user **sign-up functionality**.
* Created a separate file `login_page.dart` to handle **user login and authentication**.
* Designed a `home_page.dart` for the **main dashboard**, implementing all core student record operations.
* Enhanced UI/UX by:

   * Introducing a **popup table view** for improved data readability.
   * Replacing the traditional logout button with a **profile icon dropdown** in the AppBar.

---

## Application Features

1. **User Authentication**

   * Users can register with an email and password.
   * Credentials are stored securely in Firebase.
   * Password visibility can be toggled using an eye icon.

2. **Navigation**

   * Existing users can switch directly to the login page.
   * New users can navigate back to the sign-up page.

3. **Home Page Dashboard**

   * Displays user login info accessible via a profile icon in the AppBar.
   * Logout option is available in the dropdown menu.

4. **Student Record Operations**

   * Four fields: **Name**, **Roll Number**, **Branch**, and **CGPA**.
   * `Create`: Add new student record.
   * `Read`: Display all student records in a structured table.
   * `Update`: Modify existing student details based on **Roll Number** (used as a unique identifier).
   * `Delete`: Remove a student record using the roll number.

---

## Technologies Used

* **Firebase** – Cloud-based backend for user authentication and data storage
* **Android Studio** – IDE with in-built Gemini assistant for coding support
* **YouTube Tutorials & Online Resources** – For design references and feature integration
* **Cursor AI** – Utilized for debugging the update functionality and signup flow
