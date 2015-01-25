<h1>About PatchProtect:</h1>

<b>PatchProtect</b> is a <i>fast, simple and stable</i> prop protection for Garry's Mod 13.

<h3>Usage of PatchProtect:</h3>
You can control the settings in the <b>Q-Menu -> Utilities</b> (mostly the second tab). There, if you are an admin, you can change all settings and also what should happen, if someone is spamming. (Don't forget to press the Save-Button!)


<h2>Why we recommend PatchProtect on your server:</h2>

<h3>Lagfree and highest performance:</h3>
It is very important for us, to code a prop-protection, which doesn't need that much resources from the CPU.
Everybody hates lags and we too, so we want to save some resources for other addons or for the server itself.

<h3>Simple but functional:</h3>
Also we are pleased to keep the code as simple as possible, to prevent confusions or other similar things.
On the other hand we keep adding new functions to give you more freedom to control and more abilities to set things up like you whish to.

<h3>5 Panels for a good overview:</h3>
The Panels are <b>AntiSpam, Prop Protection, Buddy, Cleanup and Client-Settings</b>.

Every Panel has Labels to split features into specific sections. This helps to keep a good overview over all controls:

- <b>AntiSpam</b> ( general settings, antispam features, cooldown settings )
- <b>PropProtection</b> ( general settings, propportection features, special user-restrictions, propdelete on disconnect )
- <b>Buddy</b> ( add buddy, remove buddy )
- <b>Cleanup</b> ( cleanup everything, cleaning all disconnected player's props and cleanup player's props )
- <b>Client Settings</b> ( use owner-hud, fppmode, enable notifications )

<h3>Modern Design:</h3>
Patchprotect is not just a functional addon. It also looks pretty! We gave PatchProtect a nice modern design, which makes it easy to see, what you can do or not. Also checkboxes, as well as other control-elements have their own modern design.
You can also write us some suggestions about possible changes.

<h3>Bug fixing:</h3>
<b>We try to keep PatchProtect as bugfree as possible.</b>
If someone posts an error on GitHub or on Workshop, we try to fix the problem as soon as possible. But please have in mind, that we are students, so it could happen that the bugfix would take some time.


<h2>Features of PatchProtect:</h2>

<b>PatchProtect offers a nice range of features. To give you an overview of all features, we created a list with the most important ones:</b>

<h3>AntiSpam:</h3>
We offer a nice working <b>AntiSpam-System</b>, so that people are <b>not able to spam your server to death</b>:

- You can <b>enable/disable AntiSpam</b> if you want to use it or not
- You can <b>enable/disable that Admins</b> (not SuperAdmins!) will be ignored from the AntiSpam-System
- You can <b>enable/disable Adminalert-Sounds</b> (when somebody spams on the server) if you think that they are annoying
- It prevents that people <b>spawn props too fast</b>
	- If you use a <b>duplicator, like the default one or AdvancedDuplicator 1/2</b>, there is an <b>exception</b>. <i>So you can still spawn dupes!</i>
- It prevents that people <b>fire the toolgun too fast</b>
- You can set the <b>length of the 'cooldown'</b>
- Players, who try to spam will get an information, <b>how long they have to wait</b> till the next prop spawn/tool fire
- Admins get <b>informed if someone is spamming</b> ( There is also a little sound, which should make attention to the message )
- You can change the <b>spam-action</b>: What should happen, if someone is spamming <i>( nothing, message, kick, ban, custom console command )</i>
- You can <b>enable/disable Toolgun-AntiSpam</b> for each Tool <i>( i.e. you can use the 'remover' as fast as you can, but you are not able to spam 'thrusters' )</i>
- You can <b>block tools, props and entities</b>, which you don't want to be used on your server
	- <b>Add blocked prop/entity:</b> Aim on prop/entity and hold <i>c-key</i> to open the <i>context-menu</i> of it. There you will find an entry to <i>add the viewing prop to blocked props/entities</i>. You can remove it again over the <i>q-menu</i>.
	- <b>You can also import a blocked-props list:</b> Copy the file to the <b>'data'-folder of the server</b> with the name: <b>'pproptect_import_blocked_props.txt'</b>. This textfile should <b>ONLY</b> include in each line the <b>model-path</b> of each prop. Now you only need to type into the <b>server-console</b> following command: <b>'pprotect_import_blocked_props'</b>. Finally follow all instructions, which are printed from the console.
	- You can also disable it completely if you don't want to use it on your server

<h3>PropProtection:</h3>
The <b>main thing</b> of PatchProtect.
Here are <b>all features of our PropProtection</b>:

- You can <b>enable/disable our PropProtection</b> if you just want to use our AntiSpam-System
- You can <b>enable/disable</b> that <b>SuperAdmins</b> will be <b>ignored from the PropProtection-System</b>
- You can <b>enable/disable</b> that <b>Admins</b> (not SuperAdmins!) will be ignored from the PropProtection-System
- You can <b>enable/disable</b> that <b>Admins</b> are allowed to use the Cleanup-Menu of PatchProtect
- You can <b>enable/disable many PropProtection-Features:</b>
	- PhysGun-Protection
	- Use-Protection
	- Reload-Protection <i>( prevents the use of the 'r'-key when using the PhysGun )</i>
	- Damage-Protection
	- GravGun-Protection
	- PropPickup-Protection <i>( prevents to pick up props with 'use'-key )</i>
	- You can ignore some of those features, if the other player is in your <b>Buddy-List</b>
	- You are also allowed to <b>share permissions ( like use, touch, tool, damage )</b> of just one specific prop to all other players <i>( hold 'c'-key to share permissions of the viewing prop )</i>
- You can <b>enable/disable a world protection</b>, which prevents people from interacting with world props <i>( if you are looking on a world prop, you will get informed about it )</i>
	- You can also allow them to <b>use</b> world-props (especially for doors and other stuff) <b>but not moving</b> them
- A smart <b>HUD shows the Owner</b> of the currently viewing prop
	- You can <b>switch between two HUD-Modes</b>:
		- First, there is our <b>own design</b> <i>( little white box with on the right-middle position of the screen )</i>
		- Secondly you can change in the <b>Client-Settings</b> to the <b>'FPP-Mode'</b> <i>( little box with the owner in it under the crosshair )</i>
		- The color shows you, if you are allowed to interact with the viewing prop or not <i>( <span style="color: green;">green</span> = yes, <span style="color: red;">red</span> = no, <span style="color: blue;">blue</span> = yes on using a world-prop )</i>
- If you <b>disconnect</b>, your props will be on the server, but if you <b>enalbed prop-cleanup</b>, your <b>props will be deleted after a configured time</b> ( If you rejoin between this time, your props won't get deleted )

<h3>Cleanup:</h3>
We have added some <b>Cleanup-Features</b> to allow SuperAdmins ( or probably Admins ) to <b>clear props very fast</b>.

<b>You have following posibilities:</b>

- <b>Cleanup the whole map</b> ( all world props will be resetted )
- <b>Cleanup everything from a specific player</b>
- You also get informed, <b>how many props are currently on the server</b> ( complete map and each player )
- <b>Cleanup disconnected players props</b>

<h3>Buddy:</h3>
You can <b>add buddies to a buddy list</b>, to share your prop with other players. It is very easy to understand.
You are also able to <b>set only specific rights to other players</b>. ( i.e.: another player can use it but he is not able to pick it up with the physgun )

<h3>Client Settings:</h3>
You can set some <b>settings, which are only affecting you</b>. There you have different possibilities to personalize your own experience with PatchProtect. Here are some examples:

- Enable/Disable the <b>Owner-HUD</b>
- Enable/Disable the <b>FPPMode of the Owner-HUD</b> ( it looks similar to the Owner-HUD from FPP )
- Enable/Disable all <b>incoming notifications</b>
- More features will come from time to time

<h3>CPPI:</h3>
We implemented CPPI, so you are able to <b>use PatchProtect with other Addons/Pugins/Gamemodes</b>!

<h2>Other important information:</h2>
There are some <b>console-commands</b>, which allow you to perform some commands, which are not used quite often. This commands should be used, if you think that there is something wrong with your saved settings. Just type them into the correct console to clear all settings.
Here is a list of all that commands:
- <b>Serverside:</b> ( type them into the server-console )
	- <b>pprotect_reset [arg]</b> - This resets Serverside-Settings. Please follow all printed intstructions, if you ran this command.
	For <b>[arg]</b> you can use <b>help, all, antispam, propprotection, blocked_props, blocked_ents, blocked_tools or antispam_tools</b> (all recommended).
- <b>Clientside:</b> ( type them into the client-console )
	- <b>pprotect_reset_csettings</b> - This resets all client settings. Just follow all instructions, which will be printed into the console.
	- <b>pprotect_reset_buddies</b> - This resets all buddies.

<br>
So that was pretty much information for now. We hope, that you like all mentioned features here. As I said, this is only a list of the most important things of PatchProtect. There are also many background-functions which are really important for all above mentioned features.

We hope, that you enjoy <b>PatchProtect</b> on your server! ;)
