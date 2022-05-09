# Powershell script to create Profiles in Google Chrome.
 
Userfull for Software projectes where you have multiple personas and you would like a fast and consisten way to create the profiles when onboarding people.
 
Features:
Creates persona if it does not exist.
Updates existing personal if it already exists.
Persona folders are named to make it easy to identify them in the file system. Folders can be deleted if you nolonger need the personas.

For each persona you can set:
     Bookmark list
     Theme colour
     Profile Icon
          Chrome supports 55 different icons, chrome://theme/IDR_PROFILE_AVATAR_1 -> chrome://theme/IDR_PROFILE_AVATAR_55. You can put them in to you browser to see what they look like.

Ececution:
Before running you need to close chrome. The profile settings changes would be lost otherwise.
When you run the script, if the profile does not exist it will open chrome to create the profile. You need to close Chome for the script to continue.
If for some reason it gets messed up, go to your Chrome User Data folder and delete the impacted profiles, they will be called 'Profile-<profilename>
