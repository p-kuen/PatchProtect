## What Patchprotect is:
**PatchProtect** is a **fast**, **simple** and **stable prop protection** for **Garry's Mod 13**.

#### Usage of PatchProtect:
You can control the settings in the **Q-Menu -> Utilities**. There you can **change all settings** and also **what should happen, if someone is spamming**. (Don't forget to press the Save-Button!)


## Advantages of Patchprotect:

1. **Lagfree and highest performance:** Everybody hates lags and we too, so it is very important for us, to offer a prop-protection, which saves resources from the Server-CPU.
2. **Simple but functional:** Also we are pleased to keep the code as simple as possible. On the other hand we keep adding new features to give you more freedom to control your server.
3. **5 Panels for a good overview:** The Panels are *AntiSpam, Prop Protection, Buddy, Cleanup and Client-Settings*.
	Every Panel has Labels to split features into categories. This helps to keep a good overview over all controls:
	* *AntiSpam* ( general settings, antispam features, cooldown settings )
	* *PropProtection* ( general settings, propportection features, special user-restrictions, propdelete on disconnect )
	* *Buddy* ( add buddy, remove buddy )
	* *Cleanup* ( cleanup everything, cleaning all disconnected player's props and cleanup player's props )
	* *Client Settings* ( use owner-hud, fppmode, enable notifications )
4. **Modern Design:** Patchprotect is not just a fast, simple and functional addon. It also looks pretty! We gave PatchProtect a nice modern design, which makes it easy to see, what you can do or not.
5. **Bug fixing:** After 1 year of development, we can say that PatchProtect works almost bugfree. But if someone posts an error on GitHub or on Workshop, we try to fix the problem as soon as possible. But please have in mind, that we are students, so it could happen that the bugfix would take some time.


## Features of PatchProtect:

**PatchProtect offers a nice range of features. To give you an overview of all features, we created a list with the most important ones:**

### AntiSpam:
We offer a nice working **AntiSpam-System**, so that people are **not able to spam your server to death**:

* Prevents that players **spawn props too fast**:
	If you use a **duplicator, like the default one or AdvancedDuplicator 1/2**, there is an **exception**. *So you can still spawn dupes!*
* Prevents that people **fire the toolgun too fast**
* You can set the **length of the 'cooldown'**
* Players, who try to spam will get an information, **how long they have to wait** till the next prop spawn/tool fire
* Admins get **informed if someone is spamming** ( There is also a little sound, which should make attention to the message )
* You can change the **spam-action**:
	What should happen, if someone is spamming *( nothing, message, kick, ban, custom console command )*
* You can **enable/disable Toolgun-AntiSpam** for each Tool:
	( i.e. you can use the 'remover' as fast as you can, but you are not able with 'thrusters' )
* You can **block tools, props and entities**, which you don't want to be used on your server:
	* **Add blocked prop/entity**:
		Hold **c-key**, aim on **prop/entity** and then **right-click** to open the context-menu. There you will find an entry: **Add to blocked list**. You can remove it again inside of the *spawnmenu*.
	* You can also **import a blocked-props list**:
		* Copy the txt-file to the **'data'-folder of the server** with the name: **'pproptect_import_blocked_props.txt'**. This textfile should **ONLY INCLUDE IN EACH LINE ONE PROP** with the **model-paths**, which are seperated with a **';'**.
		(e.g.: "models/props_c17/oildrum001_explosive.mdl;" )
		* Now you only need to type into the **server-console** following command: **'pprotect_import_blocked_props'**.
		* Follow all instructions, which are printed from the console.
	* You can also disable it completely if you don't want to use it on your server

### PropProtection:
**The main part of PatchProtect. Here are all features of our PropProtection**:

* You can **enable/disable many PropProtection-Features**:
	* PhysGun-Protection
	* Use-Protection
	* Reload-Protection *( prevents the use of the 'r'-key when using the PhysGun )*
	* Damage-Protection
	* GravGun-Protection
	* PropPickup-Protection *( prevents to pick up props with 'use'-key )*
	* You can ignore some of those features, if the other player is in your **Buddy-List**
	* You are also allowed to **share permissions ( like use, touch, tool, damage )** of just one specific prop to all other players *( hold 'c'-key to share permissions of the viewing prop )*
* You can **enable/disable a world protection**:
	It prevents people from interacting with world props *( if you are looking on a world prop, you will get informed about it )*
	* You can also allow them to **use** world-props (especially for doors and other stuff) **but not moving** them
* A smart **HUD shows the Owner** of the currently viewing prop
	* You can **switch between two HUD-Modes**:
		* First, there is our **own design** *( little white box with on the right-middle position of the screen )*
		* Secondly you can change in the **Client-Settings** to the **'FPP-Mode'** *( little box with the owner in it under the crosshair )*
		* The color shows you, if you are allowed to interact with the viewing prop or not *( green = yes, red = no, blue = yes on using a world-prop )*
* If you **disconnect**, your props will be on the server, but if you **enalbed prop-cleanup**, your **props will be deleted after a configured time** ( If you rejoin between this time, your props won't get deleted )

### Cleanup:
**We have added some **Cleanup-Features** to allow SuperAdmins ( or probably Admins ) to clear props very fast**:

* Cleanup the **whole map** ( all world props will be resetted )
* Cleanup **everything from a specific player**
* **Prop-Count** of the whole map and each player
* Cleanup **disconnected player's props**

### Buddy:
**We also added a nice buddy-system wich allowes you to share your props with some friends**:

* **add buddies to a buddy list**
* Set **specific rights for other players**:
	( i.e.: another player can use it but he is not able to pick it up with the physgun )

### Client Settings:
**You can set some settings, which are only affecting you. There you have different possibilities to personalize your own experience with PatchProtect**:

* Enable/Disable the **Owner-HUD**
* Enable/Disable the **FPPMode of the Owner-HUD** ( it looks similar to the Owner-HUD from FPP )
* Enable/Disable all **incoming notifications**

### CPPI:
We implemented CPPI, so you are able to **use PatchProtect with other Addons/Pugins/Gamemodes**!

## Console Commands:
**Here is a list of all server/client - commands, which are not used quite often**:

* **Serverside:** ( type them into the server-console )
	* **pprotect_reset [arg]**
		* This resets Serverside-Settings. Please follow all printed intstructions, if you ran this command.
		* For *[arg]* you can use *help, all, antispam, propprotection, blocked_props, blocked_ents, blocked_tools or antispam_tools*
* **Clientside:** ( type them into the client-console )
	* **pprotect_reset_csettings**
		* This resets all client settings. Just follow all instructions, which will be printed into the console.
	* **pprotect_reset_buddies**
		* This resets all buddies.

<br>
So that was pretty much information for now. We hope, that you like all mentioned features here. As I said, this is only a list of the most important things of PatchProtect. There are also many background-functions which are really important for all above mentioned features.

We hope, that you enjoy **PatchProtect** on your server! ;)
