# TMUF Keyboard Helper

Hi! This is a keyboard visualizer app largely inspired by TMVIZ. Difference being that TMVIZ works for controllers, this app works for keyboard. You can start the app with tmuf_kb_helper.exe.


## Important notice

A crucial part of the app is likely to get flagged as a keylogger by antivirus software. Unfortunately there is no way around it, you cant detect keypresses without detecting keypresses. For transparency reasons I added the code for the keyboard listener on the branch called dev-kblistener. You are free to review, test and analyse the code to make sure im not doing anything malicious. In case the kblistener.exe gets put into quarantine:
 - You will notice it if the first app start takes about a minute
 - Restore kblistener.exe from quarantine
 - Close the app
 - Restart app
 
 ### For those in the know
 I share the idea that wrapping python like this is not good practice, but I had trouble finding a library that I can directly or indirectly call from dart/flutter, that hooks directly into the global keyboard event loop. Keep in mind that this app needs to detect keypresses while running in background, and therefore without having keyboard focus. If you have a better alternative Im all ears.

## Usage

You can start the app with tmuf_kb_helper.exe. After first (successful) launch you will be promted to select your accel, brake and steer keys. Like in TMUF/NF you have the option to assign two keys to an action, but assigning one key is also valid. Once you have selected all the primary keys you can press Apply and Start. After that if you go to the /viz tab you should be all set up. If some keys dont work for you, check out the Keyboard layout support section below. Streamers can overlay this app on their streams via window capture.

## Keyboard layout support

Unfortunately keyboards do their keyboard events in their own language, not necessarily in English. But dont worry lots of keyboard languages are supported:

Belgian, Czech, Dutch, English, Estonian, Finnish, French, German, Greek, Hungarian, Italian, Latvian, Lithuanian, Luxembourgish, Romanian, Slovak, Slovenian, Swedish

I used keyboard event names from this site: https://kbdlayout.info/ If your keyboard has the same key events as one of the above it should also work for you. **Either way if it doesnt, please make an issue, where you include the following**:
- your country
- the keys that dont work for you
