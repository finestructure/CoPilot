import pika

HOST = 'dockerhost'
EXCHANGE = ''
QUEUE = 'mytest'
ROUTING_KEY = 'mytest'


def get_channel(host, queue):
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host)
    )
    channel = connection.channel()
    channel.queue_declare(queue=queue, durable=True)
    channel.basic_qos(prefetch_count=1)
    return channel


def send(channel, routing_key, message, exchange=''):
    channel.basic_publish(exchange=exchange,
                          routing_key=routing_key,
                          body=message,
                          properties=pika.BasicProperties(
                              delivery_mode = 2, # make message persistent
                          ))
    print " [x] Sent %d bytes" % (len(message),)

