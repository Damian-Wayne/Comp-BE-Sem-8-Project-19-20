import tornado.ioloop
import tornado.web
from random import random
import math
# import os
# import threading
# import queue
# import tensorflow as tf
# tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.FATAL)
# session_conf = tf.ConfigProto( intra_op_parallelism_threads=1, inter_op_parallelism_threads=1)
# import keras
# from keras.models import load_model
# from keras.backend import clear_session
# import cv2 as cv
# import numpy as np
# import logging
# import uuid
# import pickle
# import shutil
# import win32api
# import time
# import config
# import shlex
# import subprocess
# import re
# from numpy.ma import frombuffer
# import time

class MainHandler(tornado.web.RequestHandler):
    def get(self):
        
        print(self.request)
        scan_type=self.get_argument('scantype',True)
        img_s=self.get_argument('img_s', True)
        vid_s=self.get_argument('vid_s', True)
        precision=self.get_argument('precision', True)

        print("Video=", vid_s)
        print("Img=", img_s)
        print("precision =", precision)
        self.write(str(math.floor(random()*100)))

application = tornado.web.Application([
    (r"/", MainHandler),
])

if __name__ == "__main__":
    application.listen(8882)
    tornado.ioloop.IOLoop.instance().start()
