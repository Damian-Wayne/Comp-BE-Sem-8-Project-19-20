def getInputFromCaller(agiHandler: ADHHandler,
                       fileToPlay: str,
                       timeout=4000, numOfDigits=255) -> int:
    r'''
    Get input from the caller after playing the file.
    Arguments
    ---------
        - fileToPlay => File to be played
        - numOfDigits => Maximum number of digits to be expected
        - timeout => Time (in milliseconds) before the timer expires

    Returns
    -------
        Digits entered by the caller if the number is valid, otherwise -1 
    '''
    result = agiHandler.get_data(fileToPlay, timeout, numOfDigits)
    try:
        return int(result)
    except ValueError as e: return -1