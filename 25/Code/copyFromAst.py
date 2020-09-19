postData = dict(request.data) 
print("Post data: ",postData)
recordingDir = postData['recordingDir'] 

audioSource = 'root@192.168.1.254:/var/spool'\
    '/asterisk/recording/adh_recording/wav/{}'.format(recordingDir)

# Copying files from Asterisk server
subprocess.run([
    'scp',
    '-r',
    audioSource, 
    '/var/spool/adh_recordings'
])