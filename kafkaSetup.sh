#!/bin/bash

# Check if Java is installed, if not install it
if ! java -version &> /dev/null; then
    echo "Java not found, installing Java 1.8..."
    sudo yum install java-1.8.0-openjdk -y
fi

# Download and extract Kafka if it's not already present
if [ ! -d "kafka_2.12-3.3.1" ]; then
    echo "Downloading Kafka..."
    wget https://downloads.apache.org/kafka/3.3.1/kafka_2.12-3.3.1.tgz
    tar -xvf kafka_2.12-3.3.1.tgz
fi

# Export Kafka home path
export KAFKA_HOME=$(pwd)/kafka_2.12-3.3.1
cd $KAFKA_HOME

# Start Zookeeper
echo "Starting Zookeeper..."
nohup $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > zookeeper.log 2>&1 &

# Wait for Zookeeper to start up
sleep 5

# Modify server.properties for public IP
PUBLIC_IP=$(curl ) # Public address can be obtained from instance details in EC2 console.S
echo "Updating Kafka advertised listeners to public IP: $PUBLIC_IP"
sed -i "s/^#advertised.listeners=.*/advertised.listeners=PLAINTEXT:\/\/$PUBLIC_IP:9092/" $KAFKA_HOME/config/server.properties

# Start Kafka server
echo "Starting Kafka broker..."
export KAFKA_HEAP_OPTS="-Xmx256M -Xms128M" # Setting the Java heap memory options for the Kafka broker process
nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > kafka.log 2>&1 &

# Wait for Kafka to start up
sleep 10

# Create Kafka topic
TOPIC_NAME="Kafla_test_streaming"
echo "Creating Kafka topic: $TOPIC_NAME"
$KAFKA_HOME/bin/kafka-topics.sh --create --topic $TOPIC_NAME --bootstrap-server $PUBLIC_IP:9092 --replication-factor 1 --partitions 1

# Start Producer (Optional - You can choose to comment this out if you want to start it later)
echo "Starting Kafka producer..."
nohup $KAFKA_HOME/bin/kafka-console-producer.sh --topic $TOPIC_NAME --bootstrap-server $PUBLIC_IP:9092 > producer.log 2>&1 &

# Start Consumer (Optional - You can choose to comment this out if you want to start it later)
echo "Starting Kafka consumer..."
nohup $KAFKA_HOME/bin/kafka-console-consumer.sh --topic $TOPIC_NAME --bootstrap-server $PUBLIC_IP:9092 --from-beginning > consumer.log 2>&1 &

echo "Kafka setup complete and running!"
