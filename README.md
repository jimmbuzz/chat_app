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