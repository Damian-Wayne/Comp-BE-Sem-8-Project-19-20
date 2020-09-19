import queue

thread_stop = False
total_images_scanned = 0
total_videos_scanned = 0
total_explicit_images = 0
total_explicit_videos = 0
scan_details = {}
single_file = False
filename=None
statusbar_update = queue.Queue()
unsupported_file=False
scan_now=False
scan_type="quick"
scan_images=False
scan_videos=False
sensitivity=0
image_done=0