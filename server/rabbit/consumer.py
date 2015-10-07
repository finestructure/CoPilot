from mq import HOST, QUEUE, get_channel

    
def callback(ch, method, properties, body):
    print " [x] Received:", body
    ch.basic_ack(delivery_tag = method.delivery_tag)


def consume():
    ch = get_channel(HOST, QUEUE)
    ch.basic_consume(callback, queue=QUEUE)
    ch.start_consuming()


if __name__ == '__main__':
    consume()