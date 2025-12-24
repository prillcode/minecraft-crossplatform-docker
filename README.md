# Family Minecraft Server - Docker Setup

Minecraft server running in Docker that allows Cross-platform (Java + Bedrock) play on **same LAN (Home WiFi network)**. Included plugins add multi-world support and portal navigation.

## Use Case

Docker host and other PC's and consoles must all be on same LAN for cross-platform play. This is ideal for a family playing on same Home WiFi network as the Minecraft server running in Docker shows up on Xbox on the "Worlds" tab as a LAN World (as opposed to connecting from "Servers" tab due to restriction by the console).

## Features

- 🎮 **Cross-Platform Play** - Java Edition and Bedrock Edition (Xbox, Mobile) on the same server
- 🌍 **Multi-World Support** - Survival, Creative, and Adventure worlds with portal navigation
- 🚪 **Hub System** - Central hub world with themed portals to different worlds
- 🔒 **Permissions** - LuckPerms for granular player permissions
- 📦 **Containerized** - Fully Dockerized for easy deployment
- 🏠 **LAN Discovery** - Xbox consoles auto-discover the server on the local network

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Linux host (tested on Pop!_OS 22.04, should work on Ubuntu/Debian)
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
   
The included docker-compose file auto-downloads GeyserMC, Floodgate, and ViaVersion.  

You need to manually download:

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

# Then copy it to your server repo plugins folder:
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

```bash

# Reopen minecraft cli in docker if not still open from above
docker exec -i minecraft-server rcon-cli

# Create a new world
/mv create WorldName NORMAL

# Set world gamemode as desired (creative/survival/adventure)
/mv modify WorldName set gamemode creative

# REPEAT and create as many worlds as the machine your Docker server is running on can handle!

```

#### Create Hub World

```bash

# Create a flat world for the "Hub" world**

/mv create HubWorldName NORMAL --world-type FLAT

/mv modify HubWorldName set gamemode adventure
```

### Creating Portals

**Important:** Hub world set to adventure mode to prevent portal destruction

**Portal Creation Workflow:**

1. **In Hub world, switch to creative mode temporarily:**  
   
```bash

# To create portals (and any other structures) Hub world gamemode must be temporarily set to 'creative'

/gamemode creative 

```

2. **Build a physical portal frame** (use any block material - stone, nether brick, etc.)
   - Build in typical portal "frame" shape
   - Portal should be at least 2 blocks wide and 3 blocks tall

3. **Get the portal wand:**
```bash
/mvp wand

# (This gives you a wooden axe)
```
   

4. **Select portal area (using the axe "wand"):**
   - LEFT-CLICK the bottom-left corner block
   - RIGHT-CLICK the opposite top-right corner block

5. **Create and configure the portal:**
   ```bash
   /mvp create ToSurvivalWorld
   /mvp modify ToSurvivalWorld dest w:WorldName
   ```

6. **Walk through to test** - you should teleport to the destination world

7. **Build return portal** in the destination world:
   
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