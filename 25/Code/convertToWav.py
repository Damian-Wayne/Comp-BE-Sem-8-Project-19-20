# Call a 'sox' subprocess to convert the raw audio to wav
subprocess.run([
    'sox', '--type', 'raw', '--rate', 
    str(settings.FREQ_SAMPLING), 
    '--encoding', 'signed', '--bits', 
    str(settings.BITS_PER_SAMPLE), 
    '--channels', '1',
    rawFile, wavFile,
])