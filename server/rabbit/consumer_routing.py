from mq import HOST, get_channel

    
def callback(ch, method, properties, body):
    print " [x] Received:", body
    ch.basic_ack(delivery_tag = method.delivery_tag)


def consume(queue):
    ch = get_channel(HOST, queue)
    ch.basic_consume(callback, queue=queue)
    ch.start_consuming()


if __name__ == '__main__':
    consume('queue1')