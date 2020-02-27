## What Patchprotect is:

**PatchProtect** is a **fast**, **simple** and **stable prop protection** for **Garry's Mod 13**.

#### Usage of PatchProtect:

You can control the settings in the `Spawn-Menu -> Utilities`. There you can **change all settings** and also **what should happen, if someone is spamming**. _(Don't forget to save!)_

## Advantages of Patchprotect:

1. **Lagfree and high performance:** Everybody hates lags, and we too, so it's very important for us, to offer a prop protection, which is fast and saves CPU-resources.
2. **Simple and functional:** We try to keep PatchProtect easy to understand. Also we are adding new features to give you more freedom to control your server.
3. **5 Panels for a good overview:** The panels are _AntiSpam, Prop Protection, Buddy, Cleanup and Client-Settings_.
4. **Modern Design:** Patchprotect is not just fast, simple and functional. It also looks pretty! We gave PatchProtect a modern design, which offers a good and nice-looking overview of all what you can do.
5. **Bug fixing:** If you found an error, you could inform us on GitHub or Workshop about it. We try to fix it (relatively to its priority) as soon as possible. _Please have in mind, that we are students, so it could happen that changes and bug fixes take some time._

## Features and instructions of PatchProtect:

> PatchProtect offers a nice range of features to gain more control of your server

### SuperAdmins and Admins in PatchProtect:

We decided to have a simple rank-management in PatchProtect.

- SuperAdmins
  - have no restrictions
  - are not affected by the antispam and prop protection feature
  - can change settings of PatchProtect
  - can interact with props and entities, owned by another SuperAmdin
- Admins
  - can be freed from any antispam and prop protection feature
  - can change some settings as long as they are allowed to _(configured by SuperAdmins)_
  - can not interact with props and entities, owned by SuperAdmins, as long as they have no special permissions to do it
  - every Admin can interact with props and entities, owned by another Admin

### AntiSpam:

> tries to prevent players from spamming the server to death.

- You can prevent players from **spamming props, tools and entities**! _(duplicator-exception is included)_
- You can set the **cooldown-time** _(how long to wait until next prop-spawn, tool-fire, entity-spawn)_
- Players will get informed about the current cooldown time on the right-bottom corner
- Admins will get **informed if someone is spamming** _(if enabled, there is also a short alert sound, so the admin takes attention to it)_
- You can change the **spam-action** _(what automatically happens, if someone is spamming)_
  - nothing
  - message
  - kick or ban
  - custom console command

### Tool Block:

> prevent players to use specific tools.

#### Add/Remove blocked tools:

- Navigate to `Spawn-Menu -> Utilities -> PatchProtect -> AntiSpam`
- Click on `Set blocked tools`
- Check a tool to block it

### Tool Antispam:

> apply cooldown time to specific tools.

#### Add/Remove antispam-protected tools:

- Navigate to `Spawn-Menu -> Utilities -> PatchProtect -> AntiSpam`
- Click on `Set antispammed tools`
- Check a tool to enable antispam

### Prop/Entity Block:

> prevent players from spawning specific props and entities.

#### Add blocked prop:

- Spawn the prop/entity, which you want to block
- Hold the `c` key and `right-click` on it
- Click on `Add to Blocked-List`

#### Remove blocked prop:

- Navigate to `Spawn-Menu -> Utilities -> PatchProtect -> AntiSpam`
- Click on `Set blocked props` or `Set blocked entities`
- Click on the `icon of the prop/entity`
- Select `Remove from Blocked-List`

#### Import list of blocked props:

PatchProtect allows to import a list of blocked props from a TXT file.

- The TXT-file should include **one model-path in each line**, which are seperated with a **;** _(semicolon)_. _(e.g.: `models/props_c17/oildrum001_explosive.mdl;`)_
- Save the file to the servers `data` folder with the name `pprotect_import_blocked_props.txt`.
- Open the server console and run `pprotect_import_blocked_props`.
- Follow the instructions, which are printed to the console.

PatchProtect contains a list of default props that you may want to block. It includes every model in the `rails` build category as well as many other large props. Copy the `pprotect_import_blocked_props.txt` file, which is located in this repository and follow the instructions above.

### PropProtection:

> protect your stuff

- You can **enable/disable many PropProtection-Features**:
  - PhysGun-Protection
  - Use-Protection
  - Reload-Protection _(prevent use of the 'r'-key when using the PhysGun)_
  - Damage-Protection
  - GravGun-Protection
  - PropPickup-Protection _(prevent pick-up of props with 'use'-key)_
- You can prevent players from **interacting with world-objects**:
  - You can allow players that they can move world-objects
  - You can allow players that they can use world-doors and buttons
  - You can allow players to use tools on world props
- A **HUD prints the owner** of the currently viewing prop:
  - You can **switch between two HUDs**:
    - **PatchProtect-design** _(little white box with the owner in it on the right-middle of the screen)_
    - **FPP-design** _(little box with the owner in it under the crosshair)_ You can enable it in the client settings.
    - The color shows you, if you are allowed to interact with the viewing prop or not *(green = yes, red = no, blue = partly)*
- Auto-Cleanup:
  - If somebody disconnects, you can enable that props are getting removed when `Use Prop-Delete` is `checked`
  - You can set the time, after how many seconds the props are getting cleaned-up
  - If you rejoin before the deadline, your props won't get deleted _(so no need to rage on client crashes)_

### Cleanup:

> keep your server clean and lagfree

- Cleanup the **whole map** _(all world props will be reset)_
- Cleanup **everything from a specific player**
- **Prop-Count** of the whole map and each player
- Cleanup **disconnected player's props** _(see above for more details)_

### Buddy:

> you wan't to play with your friend(s) together? No problem!

- You can add/remove each player to your buddies
- You can set specific rights to each buddy _(pickup, tool, use, damage)_

#### Add/Remove a buddy:

- Navigate to `Spawn-Menu -> Utilities -> PatchProtect -> Buddy`
- Follow the instructions on the top of the menu

### Share Props/Entities:

> allow all other players on the server to have special rights on a specific prop/entity

- The permissions are pickup, tool, use and damage

#### Add/Remove prop share-permissions:

- Be sure that you are the owner of the prop/entity
- Hold the `c` key and `right-click` on the prop/entity
- Click on `Share entity`
- Check permissions, which you want to allow to all other players on the server

### Client Settings:

> we offer some settings to personalize your PatchProtect-experience

- Enable/Disable the **Owner-HUD**
- Enable/Disable the **FPP-Design**
- Enable/Disable all **incoming notifications**

### CPPI:

We implemented CPPI, so you are able to **use PatchProtect with other Addons/Pugins/Gamemodes**!

## Console Commands:

> some commands, which you (hopefully) won't use that often

- **Server side:** (type them into the server console)
  - `pprotect_reset [arg]`
    - This resets serverside-settings. Please follow all printed instructions, after executing this command.
    - For `[arg]` you can use `help, all, antispam, propprotection, blocked_props, blocked_ents, blocked_tools` or `antispam_tools`
- **Client side:** (type them into the client console)
  - `pprotect_reset_csettings`
    - This resets all client settings. Please follow all printed instructions, after executing this command.
  - `pprotect_reset_buddies`
    - This resets all buddies.

This is a description of most important features of PatchProtect. We recommend to go through the settings in game to make sure that everything is correctly configured.

## Contributors

Thanks to @azarus, @cardermeister, @zaknesler, @ReturnEnd, @Voperak.
