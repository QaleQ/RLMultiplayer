# RLMultiplayer
Batch script for making it easier to play Workshop maps online

This script lets you use the BakkesMod console (F6 in game) to host- or connect to servers playing- Workshop maps, provided both the host and the client has applied this script, and have subscribed to the map in question in the Steam Workshop.


What it does (short version):
Creates symlinks for each .udk file in your workshop map folder substructure as .upk files inside your Rocket League folder,
to trick the game into loading them as normal maps when the game starts.


To play online:
-The host has to open the required ports (will add later)

-Both the client and the host has to be running BakkesMod

- Both the client and the host must subscribe to the map that will be hosted, and then run this script to add the map to the game.

- The client connects to the host using "connect <ip-adress>" (no quotes or brackets) in the console (F6 in game)
  
- The host hosts by using "start <mapname>?Lan?Listen"
  
- Any deviations from the default game settings are have to be specified within the start command

  
A list of game settings and how to apply them will be added later.
