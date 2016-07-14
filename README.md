## What Patchprotect is:
**PatchProtect** is a **fast**, **simple** and **stable prop protection** for **Garry's Mod 13**.

#### Usage of PatchProtect:
You can control the settings in the **Q-Menu -> Utilities**. There you can **change all settings** and also **what should happen, if someone is spamming**. (Don't forget to press the Save-Button!)


## Advantages of Patchprotect:

1. **Lagfree and highest performance:** Everybody hates lags and we too, so it is very important for us, to offer a prop-protection, which is fast and saves CPU-resources.
2. **Simple and functional:** We try to keep PatchProtect easy to understand. Also we are adding new features to give you more freedom to control your server.
3. **5 Panels for a good overview:** The Panels are *AntiSpam, Prop Protection, Buddy, Cleanup and Client-Settings*.
4. **Modern Design:** Patchprotect is not just fast, simple and functional. It also looks pretty! We gave PatchProtect a nice modern design, which makes it easy to see, what you can do or not.
5. **Bug fixing:** After 1 year of development, we can say that PatchProtect works almost bugfree. But if found an error, you could inform us on GitHub or Workshop about it. We try to fix it as soon as possible. But please have in mind, that we are students, so it could happen that the bugfix would take some time.


## Features and Instructions of PatchProtect:
> PatchProtect offers a nice range of features to gain more control of your server

### AntiSpam:
> We offer a nice working **AntiSpam-System**, so that people are **not able to spam your server to death**

* You can prevent players from **spaming props, tools and entities**! *(Duplicator exception is included)*
* You can set the **'cooldown-time'** *(How long you have to wait till the next prop-spawn, tool-fire, entity-spawn)*
* Players will get informed about the cooldown-time on the right-bottom corner
* Admins will get **informed if someone is spamming** *(If enabled, there is also a short alert sound, so the admin takes attention to it)*
* You can change the **spam-action** *(What automatically happens, if someone is spaming)*
	* nothing
	* message
	* kick or ban
	* custom console command

### Tool Block:
> You are able to **block each tool**, which is available on your server.

#### Add/Remove a blocked tool:
* Navigate to `Spawn-Menu -> Utilities -> PatchProtect -> AntiSpam`
* Click on `Set blocked tools`
* Check a tool to block it, Uncheck a tool to allow it

### Tool Antispam:
> You are able to **set the antispam-function on each tool**, which is available on your server.
> **e.g.:** You are able to allow to spam balloons but not thrusters.

#### Add/Remove an antispammed tool:
* Navigate to `Spawn-Menu -> Utilities -> PatchProtect -> AntiSpam`
* Click on `Set antispamed tools`
* Check a tool to enable antispam on it, Uncheck a tool to disable antispam on it

### Prop/Entity Block:
> You are able to **block each prop/entity**, which is available on your server.

#### Add a new blocked prop:
* Be sure that you are a **SuperAdmin** on your server
* Spawn the prop/entity once, which you want to block
* Hold the `c-key` and `right-click` on the prop/entity
* Click on `Add to Blocked-List`

#### Remove a blocked prop:
* Navigate to `Spawn-Menu -> Utilities -> PatchProtect -> AntiSpam`
* Click on `Set blocked props` OR `Set blocked entities`
* Click on the `icon of the prop/entity`
* Select `Remove from Blocked-List`

#### Import a file with a list of blocked props:
* Save the txt-file to the `data-folder of the server` with the name `pproptect_import_blocked_props.txt`. This textfile should **ONLY INCLUDE IN EACH LINE ONE PROP** with the **model-paths**, which are seperated with a **';'**. (e.g.: `models/props_c17/oildrum001_explosive.mdl;` )
* Open the server-console and type: `pprotect_import_blocked_props`
* Follow all instructions, which are printed to the console.

> Included with PatchProtect is a list of default props that you may want to block. It includes every model in the `rails` build category aswell as many other large props. Just copy the `pproptect_import_blocked_props.txt` file located in this repository and follow the instructions above.

### PropProtection:
> The main part of PatchProtect. Here are all features of our PropProtection

* You can **enable/disable many PropProtection-Features**:
	* PhysGun-Protection
	* Use-Protection
	* Reload-Protection *( prevents the use of the 'r'-key when using the PhysGun )*
	* Damage-Protection
	* GravGun-Protection
	* PropPickup-Protection *( prevents to pick up props with 'use'-key )*
* You can prevent players from **interacting with world-objects**:
	* You can allow players that they can move world-objects
	* You can allow players that they can use world-doors and buttons
	* You can allow players to use tools on world props
* A smart **HUD prints the Owner** of the currently viewing prop:
	* You can **switch between two HUD-Modes**:
		* **PatchProtect-Design** *( little white box with on the right side of the screen )*
		* **FPP-Design** *( little box with the owner in it under the crosshair )* You can enable it in the client-settings.
		* The color showes you, if you are allowed to interact with the viewing prop or not *( green = yes, red = no, blue = partly )*
* Auto-Cleanup:
	* If you disconnect, you could enable that props are getting removed when `Use Prop-Delete` is `checked`
	* You can set the time, after how many seconds the props are getting cleaned-up
	* If you rejoin between this time, your props won't get deleted (So client-crashes are not that bad)

### Cleanup:
> We have added some **Cleanup-Features** to allow SuperAdmins ( or probably Admins ) to clear props very fast

* Cleanup the **whole map** ( all world props will be resetted )
* Cleanup **everything from a specific player**
* **Prop-Count** of the whole map and each player
* Cleanup **disconnected player's props**

### Buddy:
> We also added a nice buddy-system wich allowes you to share props with some friends

* You can set specific rights to each buddy *(pickup, tool, use, damage)*

#### Add/Remove a Friend to the Buddy-List:
* Navigate to `Spawn-Menu -> Utilities -> PatchProtect -> Buddy`
* Follow the instructions on the top of the panel

### Share Props:
> Allow all other players to have special rights on a specific prop

* The permissions are pickup, tool, use and damage

#### Add/Remove share-permissions of a prop:
* Be sure that you are owning the prop
* Hold the `c-key` and `right-click` on the prop/entity
* Click on `Share entity`
* Check/Uncheck all permissions, which you want to allow to all other players on the server

### Client Settings:
> You can set some settings, which are only affecting you. We offer some possibilities to personalize your own experience with PatchProtect

* Enable/Disable the **Owner-HUD**
* Enable/Disable the **FPP-Design**
* Enable/Disable all **incoming notifications**

### CPPI:
We implemented CPPI, so you are able to **use PatchProtect with other Addons/Pugins/Gamemodes**!

## Console Commands:
> Here is a list of all server/client - commands, which are not used quite often

* **Serverside:** ( type them into the server-console )
	* `pprotect_reset [arg]`
		* This resets Serverside-Settings. Please follow all printed intstructions, if you ran this command.
		* For `[arg]` you can use `help, all, antispam, propprotection, blocked_props, blocked_ents, blocked_tools` or `antispam_tools`
* **Clientside:** ( type them into the client-console )
	* `pprotect_reset_csettings`
		* This resets all client settings. Just follow all instructions, which will be printed into the console.
	* `pprotect_reset_buddies`
		* This resets all buddies.

<br>
So that was pretty much information for now. We hope, that you like all mentioned features here. As I said, this is only a list of the most important things of PatchProtect. There are also many background-functions which are really important for all above mentioned features.

We hope, that you enjoy **PatchProtect** on your server! ;)