# Family Minecraft Server - Docker Setup

Minecraft server running in Docker that allows Cross-platform (Java + Bedrock) play on **same LAN (Home WiFi network)**. Included plugins add multi-world support and portal navigation.

## Use Case

Same household, multiple Minecraft user accounts, cross-platform desired (PC + Xbox tested, PS5/Switch likely works too).  

- This Docker-hosted Minecraft server image with preloaded Plugins will give your household hours of Minecrafting playing fun!
- All PC's and consoles must all be on same LAN to play together.
- This is ideal for a family/household playing on same Home WiFi network where multiple children/parents/roomates have different Minecraft player accounts and devices.
- One PC/laptop, preferably Linux-based (but WSL on Windows should work too) will serve as the Minecraft server running in Docker. 

IMPORTANT: On Xbox running Bedrock, the server shows up on the "Worlds" tab as a LAN-discovered World (as opposed to being on "Servers" tab due to how consoles restrict adding custom servers).

## Features

- 🎮 **Cross-Platform LAN Play** - Java Edition and Bedrock Edition (Xbox, Mobile) on same LAN (Local Area Network) with GeyserMC and Floodgate plugins
- 🌍 **Multi-World Support** - Survival, Creative, and Adventure worlds with portal navigation via Multiverse plugins.
- 🔒 **Permissions** - Granular player permissions set by LuckPerms plugin (used to enable Portal travel between worlds in this setup)
- 📦 **Containerized** - Fully Dockerized for easy deployment and network discovery
- 🏠 **LAN Discovery** - Xbox consoles (and likely others) auto-discover the server on the local network

## Quick Start

### Prerequisites

- Docker installed on Linux machine (laptop/PC) preferred; or WSL on Windows
- Docker Compose
- 4GB+ RAM available
- Ports 25565 (Java) and 19132 (Bedrock) available

### Installation

1. **Clone/Fork the repository**

```bash
# Clone the repository 
git clone https://github.com/prillcode/minecraft-crossplatform-docker.git

# Or Fork it first, then clone from your forked repo!

# Navigate to cloned repo on your machine
cd minecraft-crossplatform-docker

```

2. **Download required plugins**
   
The included docker-compose file auto-downloads GeyserMC, Floodgate, and ViaVersion plugins.  

The following plugins need to be manually downloaded. The commands below download each to the data/plugins directory in the repo, which is mapped to the Docker volume on startup:

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

# LuckPerms (download from browser at https://luckperms.net/download)
# - Click the big "Bukkit" download button
# - It'll save to ~/Downloads/

# Then copy it to your server repo data/plugins folder used by the docker volume:
cp ~/Downloads/LuckPerms-Bukkit-*.jar ~/path-to-cloned-repo/minecraft-crossplatform-docker/data/plugins/
```

3. **Start the server**
```bash
docker compose up -d
docker compose logs -f
```

4. **Configure permissions** (after first start)
```bash
# Open minecraft cli in docker container
docker exec -i minecraft-server rcon-cli

# IMPORTANT: Make YOUR player the server operator (op)
/op YourMinecraftUsername

# Use LuckPerms plugin to allow all players to use portals
lp group default permission set multiverse.portal.access.* true

# exit docker container (or leave open for next section)
exit
```

## Configuration

### Server Settings

Edit `docker-compose.yml` to customize:
- `MEMORY`: RAM allocation (default: 3G)
- `SERVER_NAME`: Server name
- `MOTD`: Message of the day

### Create Destination Worlds

Multiverse Plugin used for world creations. See [/mv create command docs](https://mvplugins.org/core/fundamentals/commands-usage/#Create-Command) for world customization options.
```bash

# Reopen minecraft cli in docker if not still open from above
docker exec -i minecraft-server rcon-cli

# Use multiverse 'mv' command to create world(s) - "WorldName" can be any name desired (ex: "SmithFamilySurvival")
/mv create WorldName NORMAL

# Set world gamemode as desired (creative/survival/adventure)
/mv modify WorldName set gamemode creative

# REPEAT and create as many worlds as the machine your Docker server is running on can handle!

```

#### Create Hub World

- The "Hub" world is where players will spawn into each time they join the server.
- The Portals will be created here taking players to the actual Destination worlds.
- The hub world is created in ADVENTURE mode so portals/structures can't be destroyed.
- While you create the portals/structure the gamemode is changed to creative.
- It serves as a Lobby to your worlds.
- A FLAT world is suggested, but it doesn't have to be. 

```bash

# Create a flat world for the "Hub" world** - "HubWorldName" can be any name desired (ex: "SmithFamilyHub")

/mv create HubWorldName NORMAL --world-type FLAT

/mv modify HubWorldName set gamemode adventure
```

### Creating Portals

**Important:** Hub world created in adventure mode to prevent portal destruction

**Portal Creation Workflow:**

1. **In Hub world, switch to creative mode temporarily during portal/structure creation:**  
   
```bash

# To create portals (and any other structures) Hub world gamemode must be temporarily set to 'creative'

/gamemode creative 

```

2. **Build a physical portal frame** (use any block material - stone, nether brick, etc.)
   - Build in typical portal "frame" shape
   - Portal should be at least 2 blocks wide and 3 blocks tall

3. **Get the portal wand:**
   - Use multiverse portals `/mvp wand` command to start!
```bash
/mvp wand

# (This gives you a wooden axe)
```
   
4. **Select portal area (using the axe "wand"):**
   - LEFT-CLICK the bottom-left corner block
   - RIGHT-CLICK the opposite top-right corner block
   - Confirmation text should show selections.

5. **Immediately run following commands in succession to create and configure the just-selected portal:**
   - Use multiverse portals `/mvp create` and `/mvp modify`  commands
   - Portal name can be anything. Below example uses "ToSurvivalWorldPortal".
```bash
/mvp create ToSurvivalWorldPortal
/mvp modify ToSurvivalWorldPortal dest w:WorldName
```

6. **Walk through to test** 
   - If no errors occured, walking through should teleport you to the destination world!

7. **Build return portal** in the destination world:
   - Use same steps to build a portal back to the Hub world if desired
```bash
/mvp wand
# [select portal area]
/mvp create BackToHub
/mvp modify BackToHub dest w:HubWorldName
```

**Note:** Use `dest w:WorldName` syntax (not `dest p:WorldName`)

## Connecting

**Java Edition:**
```
Server Address: YOUR_SERVER_IP:25565
```

**Bedrock Edition (Xbox/Mobile):**
- Server auto-appears in "Worlds" tab on LAN
- Or manually add: `YOUR_SERVER_IP` (port 19132 auto-detected)

## Project Structure

```
.
├── docker-compose.yml          # Docker configuration
├── data/
│   ├── plugins/
│   │   ├── Geyser-Spigot.jar
│   │   ├── floodgate-spigot.jar
│   │   ├── ViaVersion.jar
│   │   ├── Multiverse-Core.jar
│   │   ├── Multiverse-Inventories.jar
│   │   ├── Multiverse-Portals.jar
│   │   ├── LuckPerms-Bukkit.jar
│   │   └── [plugin configs/]
│   ├── [HubWorldName]/             # Required: Hub world
│   ├── [SurvivalWorldName]/        # Optional: Survival world
│   ├── [CreativeWorldName]/        # Optional: Creative world
│   ├── [AdventureWorldName]/       # Optional: Adventure world
│   └── server.properties
└── README.md
```

## Plugin Details

| Plugin | Version | Purpose |
|--------|---------|---------|
| GeyserMC | 2.9.2+ | Bedrock/Java crossplay bridge |
| Floodgate | 2.2.5+ | Bedrock authentication |
| ViaVersion | 5.6.1+ | Client version compatibility |
| Multiverse-Core | 5.4.0+ | Multi-world management |
| Multiverse-Inventories | 5.2.1+ | Per-world inventories |
| Multiverse-Portals | 5.0.1+ | Portal creation system |
| LuckPerms | 5.5.22+ | Permissions management |

## Common Commands

### Server Management
```bash
# View logs
docker compose logs -f

# Restart server
docker compose restart

# Stop server
docker compose down

# Access console
docker exec -i minecraft-server rcon-cli
```

### Player Management
```bash
# Make player operator
/op PlayerName

# For Bedrock players (note the dot prefix)
/op .XboxGamerTag
```

### World Management
```bash
# List worlds
/mv list

# Teleport to world
/mv tp WorldName

# Set spawn point
/mv setspawn
```

## Backup

```bash
# Stop server
docker compose down

# Backup entire data directory
tar -czf minecraft-backup-$(date +%Y%m%d).tar.gz data/

# Restart server
docker compose up -d
```

## Troubleshooting

### Server won't start
- Check logs: `docker compose logs -f`
- Verify all plugin JARs are present in `data/plugins/`
- Ensure ports 25565 and 19132 are not in use

### Bedrock clients can't connect
- Verify host networking mode is enabled in `docker-compose.yml`
- Check firewall isn't blocking ports
- Ensure Geyser-Spigot is loaded (check logs)

### Portals not working
- Verify LuckPerms is installed and permissions are set
- Check portal configuration: `/mvp info PortalName`
- Ensure destination world exists: `/mv list`

## Performance

**Tested on:** Intel i5-1240U, 16GB RAM, Pop!_OS 22.04  
**Resource Usage:** ~2.1GB RAM with 4 worlds and 3-4 players  
**Recommended:** 4GB+ RAM, SSD storage

## Contributing

Contributions welcome! Please open an issue or pull request.

## License

MIT License - See LICENSE file for details

## Acknowledgments (Required Pre-Reqs)

- [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) - Excellent Docker image
- [GeyserMC](https://geysermc.org/) - Cross-platform bridge
- [Multiverse](https://github.com/Multiverse/Multiverse-Core) - Multi-world plugin
- [LuckPerms](https://luckperms.net/) - Permissions plugin

---

**Built by a DevOps dad for family gaming** 🎮👨‍👩‍👧‍👦
