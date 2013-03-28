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

    def on_open(self, info):
        print "WebSocket open"
        self.clients.add(self)
        self.broadcast(self.clients, "Someone Joined")

    def on_message(self, message):
        print "message received"
        #inputs = tornado.escape.json_decode(message)
        self.broadcast(self.clients, message)


    def on_close(self):
        print "WebSocket Close"
        self.clients.remove(self)

        self.broadcast(self.clients, "Someone left.")




class MainHandler(tornado.web.RequestHandler):
    def get(self):
        return "no root config"



if __name__ == '__main__':
    import logging
    logging.getLogger().setLevel(logging.DEBUG)
    ChatRouter = sockjs.tornado.SockJSRouter(chatServer, '/chat')
    application = tornado.web.Application(
        [(r"/", MainHandler)] + ChatRouter.urls
        )
    application.listen(8765)
    io_loop = tornado.ioloop.IOLoop.instance()
    try:
        io_loop.start()
    except SystemExit, KeyboardInterrupt:
        io_loop.stop()
