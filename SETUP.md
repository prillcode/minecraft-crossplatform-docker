# Detailed Setup Guide

This document repeats the same content described in the README, but includes clarification steps to help get your Local docker-hosted Minecraft server running!

## Prerequisites Check

Before starting, verify you have:

```bash
# Check Docker
docker --version
# Should show: Docker version 20.x or higher

# Check Docker Compose
docker compose version
# Should show: Docker Compose version v2.x or higher

# Check available RAM
free -h
# Should have at least 4GB available

# Check ports are free
sudo netstat -tulpn | grep -E '25565|19132'
# Should return nothing (ports available)
```

## Step 1: Clone/Fork Repo

```bash
# Clone the repository 
git clone https://github.com/prillcode/minecraft-crossplatform-docker.git

# Or Fork it first, then clone from your forked repo!

# Navigate to cloned repo on your machine
cd minecraft-crossplatform-docker

```

## Step 2: Download Plugins

### Auto-Downloaded Plugins
These are handled automatically by the Docker container:
- ✅ GeyserMC
- ✅ Floodgate  
- ✅ ViaVersion

### Manual Download Required

**Option A: Using wget (Linux/Mac)**

```bash
# Multiverse-Core
wget -O data/plugins/Multiverse-Core.jar \
  "https://hangar.papermc.io/api/v1/projects/Multiverse/Multiverse-Core/versions/5.4.0/PAPER/download"

# Multiverse-Inventories
wget -O data/plugins/Multiverse-Inventories.jar \
  "https://hangar.papermc.io/api/v1/projects/Multiverse/Multiverse-Inventories/versions/5.2.1/PAPER/download"

# Multiverse-Portals
wget -O data/plugins/Multiverse-Portals.jar \
  "https://hangar.papermc.io/api/v1/projects/Multiverse/Multiverse-Portals/versions/5.0.1/PAPER/download"
```

**LuckPerms (requires browser):**
1. Visit https://luckperms.net/download
2. Click "Bukkit" button
3. Save to `~/Downloads/`
4. Copy to plugins:
```bash
cp ~/Downloads/LuckPerms-Bukkit-*.jar data/plugins/
```

**Option B: Using provided script**

```bash
# Make script executable and run it
chmod +x scripts/download-plugins.sh
./scripts/download-plugins.sh
```

## Step 3: Configure Server (Optional)

Edit `docker-compose.yml` if you want to customize:

```yaml
environment:
  MEMORY: "3G"              # Adjust based on available RAM
  SERVER_NAME: "My Server"  # Change server name
  MOTD: "Welcome!"          # Change welcome message
```

## Step 4: Start the Server

```bash
# Start in detached mode
docker compose up -d

# Watch the logs (Ctrl+C to exit viewing)
docker compose logs -f
```

**Wait for this line in logs:**
```
[Server thread/INFO]: Done (XX.XXXs)! For help, type "help"
```

## Step 5: Make Yourself Operator

```bash
# Connect to console
docker exec -i minecraft-server rcon-cli

# Add yourself as operator (replace with your username)
/op YourMinecraftUsername

# Exit console
exit
```

## Step 6: Configure LuckPerms

```bash
# Connect to console
docker exec -i minecraft-server rcon-cli

# Give all players permission to use portals
lp group default permission set multiverse.portal.access.* true

# Exit console
exit
```

## Step 7: Create Your Worlds

```bash
# Connect to console
docker exec -i minecraft-server rcon-cli

# Required: Create a hub world (flat terrain)  
/mv create HubWorld NORMAL --world-type FLAT
# Set Hub to adventure mode (prevents block breaking) - will be temporarily set to creative in a later step!
/mv modify HubWorld set gamemode adventure

# Required: Create at least one of the following "destination" worlds (or as many as you like) >  

# Create a survival world (name = "SurvivalWorld" can be anything you want)
/mv create SurvivalWorld NORMAL
/mv modify SurvivalWorld set gamemode survival
/mv modify SurvivalWorld set difficulty easy # (options: easy/normal/hard)

# Create a creative world
/mv create CreativeWorld NORMAL
/mv modify CreativeWorld set gamemode creative
/mv modify CreativeWorld set difficulty peaceful

# Create an adventure world
/mv create AdventureWorld NORMAL
/mv modify AdventureWorld set gamemode adventure

# Repeat for as many worlds you think the machine hosting your docker container can handle
# Keep in mind you'll have to build Portals to/from however many you create!

# List all worlds to verify
/mv list

# Exit console
exit
```

## Step 8: Set HubWorld as Spawn

```bash
# Join the server in Minecraft
# Then from in-game - Teleport to hub world
/mv tp HubWorld

# Stand where you want players to spawn
# Then set spawn point
/mv setspawn

exit
```

## Step 9: Create Portals

**Portal Creation Process:**

**In Hub world:**

1. **Switch to creative mode temporarily:**
   ```
   /gamemode creative
   ```

2. **Build a physical portal frame:**
   - Use any block material (stone bricks, nether brick, etc.)
   - Build in typical portal frame shape
   - Minimum size: 2 blocks wide x 3 blocks tall

3. **Get the portal wand:**
   ```
   /mvp wand
   ```
   (Gives you a wooden axe tool)

4. **Select the portal area:**
   - LEFT-CLICK the bottom-left corner block of your frame
   - RIGHT-CLICK the opposite top-right corner block

5. **Create the portal:**
   ```
   /mvp create ToCreativeWorld
   /mvp modify ToCreativeWorld dest w:CreativeWorld
   ```

6. **Test it** - Walk through the portal frame. You should teleport to Creative world!

7. **Switch back to adventure mode** (to prevent accidental block breaking):
   ```
   /gamemode adventure
   ```

**In Creative world (build return portal):**

1. **Get wand:**
   ```
   /mvp wand
   ```

2. **Build another portal frame** (physically construct it with blocks)

3. **Select area** (left-click corner, right-click opposite corner)

4. **Create return portal:**
   ```
   /mvp create BackToHubWorld
   /mvp modify BackToHubWorld dest w:HubWorld
   ```

5. **Test** - Walk back through to Hub

**Repeat for all worlds:**
- Hub → Adventure (and Adventure → Hub)
- Hub → Survival (and Survival → Hub)
- etc.

**Portal Design Tips:**
- Theme each portal area (e.g., use nether brick for adventure portal)
- Add signs outside portals indicating destinations
- Build portals inside existing structures (village houses, temples, etc.)
- Leave space around portals for players to safely exit

## Step 10: Test Connections

### Java Edition
1. Open Minecraft Java Edition
2. Multiplayer → Direct Connection
3. Enter: `YOUR_SERVER_IP:25565` or `localhost:25565` (if on same machine)
4. Click "Join Server"

### Bedrock Edition (Xbox)
1. Open Minecraft on Xbox
2. Go to "Worlds" tab
3. Server should auto-appear under "LAN Games"
4. If not, add manually: Settings → Servers → Add Server
   - Server Name: (anything)
   - Server Address: YOUR_SERVER_IP
   - Port: 19132

## Step 11: Invite Players

For non-OP players:
- They'll spawn in HubWorld
- Can walk through portals
- Cannot use `/mv tp` commands (forced to use portals)

## Verification Checklist

After setup, verify:

- [ ] Server starts without errors
- [ ] All plugins show as loaded in logs
- [ ] You can connect via Java Edition
- [ ] You can connect via Bedrock Edition (if applicable)
- [ ] Worlds are created and accessible
- [ ] Portals work (both directions)
- [ ] Non-OP players can use portals
- [ ] Spawn point is set correctly

## Common First-Time Issues

### Issue: "Connection refused"
**Solution:** Server is still starting. Wait for "Done!" in logs.

### Issue: "Unknown command" when using /mv
**Solution:** Multiverse-Core didn't load. Check plugins folder and restart.

### Issue: Portals don't work
**Solution:** Run LuckPerms command from Step 6 to grant permissions.

### Issue: World files missing
**Solution:** Worlds are only created after running `/mv create` commands.

### Issue: Can't OP myself
**Solution:** Make sure you're using exact Minecraft username (case-sensitive).

## Next Steps

Now that your server is running:

1. **Create more worlds** with different themes/seeds
2. **Build your hub** with themed portal areas
3. **Add more portals** connecting all your worlds
4. **Configure world-specific settings** (difficulty, pvp, etc.)
5. **Set up regular backups** (see main README)
6. **Invite friends/family** to join

## Getting Help

If you run into issues:
1. Check the logs: `docker compose logs -f`
2. Verify plugin versions are compatible
3. Search for error messages online
4. Open an issue on GitHub

## Performance Tuning

If server is laggy:

```yaml
# In docker-compose.yml, increase memory:
MEMORY: "4G"  # or "5G", "6G", etc.
```

Then restart:
```bash
docker compose down
docker compose up -d
```

---

**Setup complete!** Enjoy your cross-platform family Minecraft server! 🎉
