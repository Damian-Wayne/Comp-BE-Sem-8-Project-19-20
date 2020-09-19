import tornado.ioloop
import tornado.web
from main import Scanner
import config
#is explicit or not
exp = 0
# append all files that are explicit
fil = []
op = {}
em = {}

class MainHandler(tornado.web.RequestHandler):
   
    def get(self):
        
        print(self.request)
         
        print(self.get_argument('scantype', True))
        print(self.get_argument('img_s', True))
        print(self.get_argument('vid_s', True))
        print(self.get_argument('precision', True))
        s = Scanner()

        img_c=self.get_argument('img_s', True)
        vid_c=self.get_argument('vid_s', True)
        # self.write("Scan started")
        # self.flush()
        s.QuickScan(img_c, vid_c)
        fil =s.Prediction(img_c, vid_c).copy()
        op = { i: fil[i] for i in range(0, len(fil))}
        print(op)
        self.write(op)
        

    

application = tornado.web.Application([
    (r"/", MainHandler),
])

if __name__ == "__main__":
    application.listen(8882)
    tornado.ioloop.IOLoop.instance().start()
