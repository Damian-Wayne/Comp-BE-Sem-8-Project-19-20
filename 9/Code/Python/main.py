import os
import threading
import queue
#import tensorflow.compat.v1 as tf
#tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.FATAL)
import tensorflow.compat.v1 as tf
session_conf = tf.ConfigProto( intra_op_parallelism_threads=1, inter_op_parallelism_threads=1)
import keras
from keras.models import load_model
from keras.backend import clear_session
import cv2 as cv
import numpy as np
import logging
import uuid
import pickle
import shutil
import win32api
import time
import config
import shlex
import subprocess
import re
from numpy.ma import frombuffer
import time

image_data = queue.Queue()
video_data = queue.Queue()
explicitfiles = queue.Queue()
video_frames = queue.Queue()
erroneous_files = queue.Queue()
tif=0
class Scanner():

	def __init__(self):
		pass
		
	def single_filescan(self):
		filename=config.filename
		filename=filename.lower()
		config.scan_details['total_videos_scanned']=config.total_videos_scanned
		config.scan_details['total_images_scanned']=config.total_images_scanned
		config.scan_details['total_explicit_images']=config.total_explicit_images
		config.scan_details['total_explicit_videos']=config.total_explicit_videos
		if(filename.endswith(".jpg") or filename.endswith(".png") or filename.endswith(".bmp") or filename.endswith(".jpeg")):
			image_data.put(filename)
		if(filename.endswith(".mp4") or filename.endswith(".avi") or filename.endswith(".mkv") or filename.endswith(".flv")):
			video_data.put(filename)
		image_data.put("XOXO")
		video_data.put("XOXO")
		config.filename=None
		config.single_file=False
		return

	def DeepScan(self,cs_images_chkbox,cs_videos_chkbox):
		total_images_found = 0
		total_videos_found = 0
		drives = win32api.GetLogicalDriveStrings()
		drives = drives.split('\000')[:-1]
		drives[0]=os.path.expanduser("~")
		print(drives)
		drives[0] = "C://Users//britt//Desktop//Final_Code//Anuj_new//work//"
		drives.pop()
		if cs_images_chkbox:
			for drive in drives:
				if(config.thread_stop==True):
					config.scan_details['total_images_found'] = total_images_found
					break	
				for (root,dirs,files) in os.walk(drive, topdown=True): 
					if(config.thread_stop==True):
						config.scan_details['total_images_found'] = total_images_found
						break
					if(len(files)!=0):
						for i in files:
							if(config.thread_stop==True):
								config.scan_details['total_images_found'] = total_images_found
								break
							if(i.endswith(".jpg") or i.endswith(".png") or i.endswith(".bmp") or i.endswith(".jpeg")):
								print("lol")
								while(image_data.qsize()>=1000):
									time.sleep(3)
									print("Sleeping in Deep Scan Images")
								image_data.put(root+"\\"+i)
								total_images_found+=1
			config.scan_details['total_images_found'] = total_images_found
			image_data.put("XOXO")

		if cs_videos_chkbox:
			for drive in drives:
				if(config.thread_stop==True):
					config.scan_details['total_videos_found'] = total_videos_found
					break	
				for (root,dirs,files) in os.walk(drive, topdown=True): 
					if(config.thread_stop==True):
						config.scan_details['total_videos_found'] = total_videos_found
						break
					if(len(files)!=0):
						for i in files:
							if(config.thread_stop==True):
								config.scan_details['total_videos_found'] = total_videos_found
								break
							if(i.endswith(".mp4") or i.endswith(".mkv") or i.endswith(".avi") or i.endswith(".flv")):
								while(video_data.qsize()>=10):
									if config.thread_stop == True:
										config.scan_details['total_videos_found'] = total_videos_found
										print("Ending Quickscan : Level 4")
										break
									time.sleep(3)
									print("Sleeping in Deep Scan Videos")

								video_data.put(root+"\\"+i)
								total_videos_found+=1
			config.scan_details['tatal_videos_found'] = total_videos_found
			video_data.put("XOXO")

	def QuickScan(self,cs_images_chkbox,cs_videos_chkbox):
		total_images_found = 0
		total_videos_found = 0
		drives = win32api.GetLogicalDriveStrings()
		drives = drives.split('\000')[:-1]
		drives[0]=os.path.expanduser("~")
		print(drives)
		drives[0] = "C://Users//britt//Desktop//Final_Code//Anuj_new//work//"
		drives.pop()
		if cs_images_chkbox:
			for drive in drives:
				if(config.thread_stop==True):
					config.scan_details['total_images_found'] = total_images_found
					print("Ending Quickscan : Level 1")
					break
				for (root,dirs,files) in os.walk(drive, topdown=True):
					if(config.thread_stop==True):
						config.scan_details['total_images_found'] = total_images_found
						print("Ending Quickscan : Level 2")
						break
					if(len(files)!=0): 
						for i in files:
							if(config.thread_stop==True):
								config.scan_details['total_images_found'] = total_images_found
								print("Ending Quickscan : Level 3")
								break
							if(i.endswith(".jpg") or i.endswith(".png") or i.endswith(".bmp") or i.endswith(".jpeg")):
								while(image_data.qsize()>=1000):
									print(image_data.queue)
									return
									time.sleep(3)
									print("QuickScan Thread Sleeping in Image Section")
								image_data.put(os.path.join(root,i))
								total_images_found+=1
								# print(image_data.queue)
			config.scan_details['total_images_found'] = total_images_found
			tif = total_images_found
			image_data.put("XOXO")
			
		if cs_videos_chkbox:
			for drive in drives:
				if(config.thread_stop==True):
					config.scan_details['total_videos_found'] = total_videos_found
					print("Ending Quickscan : Level 1")
					break
				for (root,dirs,files) in os.walk(drive, topdown=True):
					if(config.thread_stop==True):
						config.scan_details['total_videos_found'] = total_videos_found
						print("Ending Quickscan : Level 2")
						break
					if(len(files)!=0):
						for i in files:
							if(config.thread_stop==True):
								config.scan_details['total_videos_found'] = total_videos_found
								print("Ending Quickscan : Level 3")
								break
							if(i.endswith(".mp4") or i.endswith(".mkv") or i.endswith(".avi") or i.endswith(".flv")):
								print("we're here")
								while(video_data.qsize()>=10):
									if config.thread_stop == True:
										config.scan_details['total_videos_found'] = total_videos_found
										print("Ending Quickscan : Level 4")
										break
									time.sleep(3)
									print("Thread Sleeping in QuickScan in Video Section")
								video_data.put(os.path.join(root,i))
								total_videos_found+=1
			config.scan_details['tatal_videos_found'] = total_videos_found
			video_data.put("XOXO")
		return

	def FramesExtraction(self,cs_images_chkbox,cs_videos_chkbox,sensitivity_level):
		filename = ""
		while(filename!="XOXO"):
			if(config.image_done==1):
				if(config.thread_stop==True):
					break
				filename = video_data.get()
				if filename == "XOXO":
					video_frames.put("XOXO")
					break
				video_frames.put("-/-/-/---O---/-/-/-{}".format(filename))
				startupinfo = None
				if os.name == 'nt':
				    startupinfo = subprocess.STARTUPINFO()
				    startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW	
				if sensitivity_level==0:
					try:
						base_cmd = 'ffmpeg -hide_banner -filter_threads 1 -filter_complex_threads 1 -i "{}" -ignore_editlist 0 -map 0:v:0 -c copy -f null -'.format(filename)
						vid_info_proc = subprocess.Popen(base_cmd,stdin=subprocess.DEVNULL,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,startupinfo=startupinfo)
						vid_info = vid_info_proc.communicate()[0].decode("utf-8")
						vd = re.findall("time=(.+?) bitrate=",vid_info)[-1].strip().split(":")
					except:
						print("Error")
						continue
					time_multiplier = [3600,60,1]
					video_duration = 0
					for i in range(3):
						video_duration+=time_multiplier[i]*float(vd[i])
					# Considering we are extracting 30 frames every video.
					frames_to_ext = 30
					interval = float("%.2f"%(video_duration/frames_to_ext))
					seek_timestamps = []
					for i in range(frames_to_ext):
						seek_timestamps.append((i+1)*interval)
					cmd = 'ffmpeg '
					for c in range(frames_to_ext):
						statement = ' -v quiet -ss {} -i "{}" -vframes 1 -filter_threads 1 -filter_complex_threads 1 -f image2pipe -s 300x300 -map {}:v:0 -pix_fmt bgr24 -vcodec rawvideo - '.format(seek_timestamps[c],filename,c)
						cmd += statement
				else:
					cmd = 'ffmpeg -v error -skip_frame nokey -i "{}" -vsync vfr -f image2pipe -vcodec rawvideo -pix_fmt bgr24 -s 300x300 - '.format(filename) 

				s1 = subprocess.Popen(cmd, stdout=subprocess.PIPE,stdin=subprocess.DEVNULL,startupinfo=startupinfo)
				while True:
					if(config.thread_stop==TruZsdfe):
						config.scan_details['total_images_scanned'] = config.total_images_scanned
						config.scan_details['total_explicit_images'] = config.total_explicit_images
						break
					try:
						f = s1.stdout.read(270000)
						frame = frombuffer(f,dtype=np.uint8).reshape((1,300,300,3))
						if(video_frames.qsize()>=500):
							time.sleep(3)
						video_frames.put(frame)
					except ValueError:
						break
			else:
				time.sleep(5)
		return


	def Prediction(self,cs_images_chkbox,cs_videos_chkbox):		
		clear_session()
		#work around 
		explicitfiles = []
		total_explicit_images = 0
		tf.Session(config=session_conf)
		cwd = os.path.dirname(os.path.abspath(__file__))
		model_path = os.path.join(cwd,"model.h5")
		model = load_model(model_path)
		print("testing phase 1")
		if cs_images_chkbox:
			x=""
			#while(x!="XOXO"):
			while(image_data.qsize()>1):
				if(config.thread_stop==True):
					config.scan_details['total_images_scanned'] = config.total_images_scanned
					config.scan_details['total_explicit_images'] = config.total_explicit_images
					break
				print(image_data.qsize())
				x=image_data.get(block=True, timeout=None)
				print("testing phase 2")
				if x=="XOXO":
					break
				if(x!="" and x is not None):
					img=cv.imread(x)
					if(img is not None):
						print("Testing phase 3 ")
						height, width = img.shape[:2]
						if(height>48 and width>48):
							config.statusbar_update.put(x)
							img=cv.resize(img,(300,300))
							image = np.reshape(img,(1,300,300,3))
							l=model.predict(image)
							#print(x,l)


							config.total_images_scanned+=1
							if(l[0][0]>l[0][1]):
								explicitfiles.append(x)
								#config.total_explicit_images+=1
								total_explicit_images+=1
						else:
							print("size is small ")
				else:
					print("image is None")
		print("Done with prediction")
		#config.scan_details['total_explicit_images'] = config.total_explicit_images
		#config.scan_details['total_images_scanned'] = config.total_images_scanned
		#config.image_done=1
		'''
		if cs_videos_chkbox is False:
			explicitfiles.append("XOXO")
		else:
			explicit_frames_in_video = 0
			y = ""
			while(y!="XOXO"):
				if(config.thread_stop==True):
					config.scan_details['total_videos_scanned'] = config.total_videos_scanned
					config.scan_details['total_explicit_videos'] = config.total_explicit_videos
					break
				y=video_frames.get()
				if y=="XOXO":
					break
				elif type(y)==type("-/-/-/---O---/-/-/-") and y!="XOXO":
					videopath = y[19:]
					config.statusbar_update.put(videopath)
					config.total_videos_scanned+=1
					explicit_frames_in_video = 0
					already_pushed = False
				else:
					if explicit_frames_in_video > 10:
						if already_pushed is False:
							explicitfiles.append(videopath)
							already_pushed = True
							config.total_explicit_videos+=1
						else:
							continue
					m=model.predict(y)
					if(m[0][0]>m[0][1]):
						explicit_frames_in_video+=1
			config.scan_details['total_videos_scanned'] = config.total_videos_scanned
			config.scan_details['total_explicit_videos'] = config.total_explicit_videos
			explicitfiles.put("XOXO")
		'''
		print("This is the final test statement.")
		return explicitfiles


	def Quarantine(self):
		ef = explicitfiles.get()
		while ef != "XOXO":
			# with open("quarintened.txt","a+") as f:
			# 	f.write(ef+"\n")
			ef = explicitfiles.get()
			# print("Quarantining : {}".format(explicitfiles.get()))
		# pass
		# filedata = {}
		# orgpath=""
		# while(orgpath is not "XOXO"):
		# 	if(config.thread_stop==True):
		# 		explicitfiles_size = explicitfiles.qsize()
		# 		if explicitfiles_size > 0:
		# 			for i in range(explicitfiles_size):
		# 				explicitfiles.get()
		# 		break
		# 	orgpath=explicitfiles.get()
		# 	if(orgpath=="XOXO"):
		# 		break
		# 	if(orgpath is not None):
		# 		unique_filename = str(uuid.uuid4())
		# 		chk=filedata.get(unique_filename)
		# 		if(chk is None):
		# 			filedata[unique_filename]=orgpath
		# 			# os.rename(orgpath,"Quarantine/"+unique_filename)
		# 			# shutil.copy(orgpath,"Quarantine/"+unique_filename)
		# 			# print("File Quarantined : {}".format(orgpath))
		# 		else:
		# 			explicitfiles.put(orgpath)
		# with open("data", 'wb') as f:
		# 	pickle.dump(filedata, f, pickle.HIGHEST_PROTOCOL)
		return




