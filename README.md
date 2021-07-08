# chat_app
Raleigh Curns  
CSC 4360 - Durham   
7/8/2021  
Midterm: Let's talk money  
  
A new Flutter project.  

## Android Installation

Clone repository and run.  
  
If using a emulator you may need to downgrade to an AVD using api 28, or try a physical device. I experienced crashes and poor performane using api 30.

## Web Installation 

Due to google admob and web's incompability, use the main branch and launch with port: 5000.

## Testing

Open a console and navigate to the chat_app directory and run 'flutter drive --target=test_driver/app.dart'. If you want to run tests multiple times than you need to change the labeled fields in the "test_driver\app_test.dart" file in order to prevent conflicts with firebase.

## Things of note:
- If a user registers with google, the drawer will display their google profile pic.  

- If a user did not register with google a default profile image is shown.  

- Group chat's are created by entering an existing chat and tapping the add icon in the app bar opening a new page that search's for additional users to add.  

- Anon users may register when they select the drawer and then "Settings" and the press the "Register" button.  

- Users may link their account to a google account.  