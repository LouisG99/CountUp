# CountUp

Mobile iOS app that enables to create different counters that enable the user to keep track of the usage of several items.

The idea for this app came from my contact lenses. After 15 days I need to change them, however it's hard to keep track of that as I don't wear them everyday. The app brings a solution to the problem as it will send notifications to the user at a specified time to keep track of the usage. 

Here is a preview of the app: 

## Interface

<b>First screen: scroll view of different counters</b>
<p sleft="auto" right="auto">
  <img align="center" src="https://github.com/LouisG99/CountUp/blob/master/CountUp/screenshots/1st_Screen.png" width="250">
  <img align="center" src="https://github.com/LouisG99/CountUp/blob/master/CountUp/screenshots/Multiple_counters.png" width="250"
</p>
<br>This scroll view will expand automatically based on how many counters you have. Moreover, counters that have been completed are displayed in different colors (dark grey and green). 
  
<b>Screens for a specific counter</b>
<p align="center">
  <img align="center" src="https://github.com/LouisG99/CountUp/blob/master/CountUp/screenshots/Counter_Screen.png" width="250">
  <img align="center" src="https://github.com/LouisG99/CountUp/blob/master/CountUp/screenshots/Settings_Screen.png" width="250"> 
</p>
The app will fetch the right values for the name, the value and the increment of the counter using CoreData. 
<br>The button "modify" unlocks the picker view to change the value of the increment. The "settings" button leads to the second screen to set preferences for the notifications. 

<br><br><b>Note:</b> I have not been able to implement the notifications functionalities as an Apple Developer license (which is rather expensive) is necessary to program notifications. However, once an the license obtained, it would be very easy to implement the notifications since the enitre app was designed for that. 
