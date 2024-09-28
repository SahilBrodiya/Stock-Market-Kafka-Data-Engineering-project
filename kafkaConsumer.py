from kafka import KafkaConsumer
from time import sleep
from json import dumps,loads
import json
from s3fs import S3FileSystem

# Making a consumer object
consumer = KafkaConsumer(
    'demo_test',
     bootstrap_servers=[':9092'], #add your IP here
    value_deserializer=lambda x: loads(x.decode('utf-8')))

# Creating a file system object to write data in S3 bucket
s3 = S3FileSystem()

# Receiving data in the topic and writing to S3
for count, i in enumerate(consumer):
    with s3.open("s3://kafka_test/stock_market_{}.json".format(count), 'w') as file:
        json.dump(i.value, file) 