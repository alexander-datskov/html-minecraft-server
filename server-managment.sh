#!/bin/sh

# Function to start the Minecraft server
start_server() {
    VERSION=$1
    SERVER_NAME=$2

    # Create server directory if it doesn't exist
    mkdir -p ~/minecraft-server
    cd ~/minecraft-server

    # Download Minecraft server JAR file if it doesn't exist
    if [ ! -f "minecraft_server.${VERSION}.jar" ]; then
        wget https://launcher.mojang.com/v1/objects/YOUR_SERVER_JAR_HASH/minecraft_server.${VERSION}.jar
    fi

    # Generate SHA-1 hash of the JAR file
    JAR_HASH=$(sha1sum minecraft_server.${VERSION}.jar | awk '{ print $1 }')

    # Accept the EULA
    echo "eula=true" > eula.txt

    # Create or update server properties
    cat <<EOL > server.properties
server-name=${SERVER_NAME}
server-port=25565
motd=A Minecraft Server
max-players=20
EOL

    # Start the server
    screen -dmS minecraft java -Xmx1024M -Xms1024M -jar minecraft_server.${VERSION}.jar nogui

    # Fetch the public IP address
    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

    echo "Server started with JAR hash: ${JAR_HASH}"
    echo "Server IP: ${PUBLIC_IP}"
}

# Function to stop the Minecraft server
stop_server() {
    # Stop the Minecraft server by sending the stop command
    screen -S minecraft -p 0 -X stuff "stop^M"

    # Check if the server stopped successfully
    sleep 10

    if pgrep -f "minecraft_server" > /dev/null; then
        echo "Failed to stop the server."
    else
        echo "Minecraft server stopped successfully."
    fi
}

# Check for the action argument
if [ "$1" = "start" ]; then
    if [ -z "$2" ] || [ -z "$3" ]; then
        echo "Usage: sh server-management.sh start <VERSION> <SERVER_NAME>"
    else
        start_server $2 $3
    fi
elif [ "$1" = "stop" ]; then
    stop_server
else
    echo "Usage: sh server-management.sh <start|stop> [<VERSION> <SERVER_NAME>]"
fi
