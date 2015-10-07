import sys
from mq import HOST, QUEUE, ROUTING_KEY, get_channel, send


if __name__ == '__main__':
    ch = get_channel(HOST, QUEUE)
    send(ch, ROUTING_KEY, ' '.join(sys.argv[1:]))
