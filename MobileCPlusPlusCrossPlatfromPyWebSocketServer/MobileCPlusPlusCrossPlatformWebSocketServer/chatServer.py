#


import tornado.httpserver
import tornado.websocket
import tornado.ioloop
import tornado.web
import tornado.escape
import sockjs.tornado
import sys
import os

class chatServer(sockjs.tornado.SockJSConnection):
    currSession = 0
    clients = set()

    def open(self):
        print "WebSocket open"
        self.clients.add(self)
        self.broadcast(self.clients, "Someone Joined")

    def on_message(self, message):
        print "message received"
        inputs = tornado.escape.json_decode(message)
        self.broadcast(self.clients, message)


    def on_close(self):
        print "WebSocket Close"
        self.clients.remove(self)

        self.broadcast(self.clients, "Someone left.")






application = tornado.web.Application([
    (r'/chat/', chatServer),
])

if __name__ == '__main__':
    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(8765)

    io_loop = tornado.ioloop.IOLoop.instance()
    try:
        io_loop.start()
    except SystemExit, KeyboardInterrupt:
        io_loop.stop()
