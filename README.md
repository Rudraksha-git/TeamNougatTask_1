# teamnougat_task_1

# Working video and screenshots: 
"https://drive.google.com/drive/folders/1Sv6GZVCycXRWyPTc3z_SthsVPpmuft0I?usp=sharing"

# Basic Overview:

The task given was to create a student record management based on video provided on whatsapp video 
which gave basic UI structure and function understanding.

I started with the main file and added the firebase database initialization to it as well as the 
sign-up page code is written in the main file.

Then, I made the login page for authorization in a different file named login_page.
Home page and its functions are added in home_page file.

# I improved the UI by adding a pop-up table feature in the home page which increases readability and replaced the logout button in profile icon of appbar.

# App description:

1. It takes user email and password as inputs for creating a user account. It stores data into 
   firebase database online.
2. The data is used for login and authorization in login page. The password is shown encrypted by 
   default but can viewed by using the eye button.
3. Once login credentials are verified, the user is redirected to the home page.
4. A button is given in the form of text in case, the user directly wants to jump to login page in 
   case, he has already created an account. He can also go back to sign-up page in case he wants to 
   create a new account.
5. once in the homepage, user is shown login info by using the profile button in the appbar. Below, 
   the login details there is also a logout button which leads to login page.
6. In the Homepage, There are four detail fields for every student which include name, roll number,
   branch and CGPA. One needs to give information of each field in order to save student info. Once 
   information is filled, press on "Create" button to save and create a new entry in the table.
7. You can press on "Read" button to see all the entries in the table.
8. In case, one wants to update student information, one can give credentials changed in the fields
   and press "Update" to change information in the table. Remember, The app uses roll no. as the 
   identifier for updating the information, so be careful while entering roll no. during student 
   profile creation.
9. In case, you want to delete a student information in the table, you can give credentials of the 
   student and press "Delete" to delete the information.

# Techonology used: Firebase online database, In-built Gemini in Android Studio. Various youtube videos and online sites. 
# Cursor AI for debugging Update function and user sign-up authorization.


