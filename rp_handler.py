import runpod
import os
import sys


def process_input(input):
    """
    Execute the application code
    """

    videoUrl = input['videoUrl']
    photoUrl = input['photoUrl']
    params = input['params']
    outputFile = input['outputFile']

    os.system("sh ./upload.sh " + videoUrl + " " + photoUrl + " " + params + " " + outputFile)
    # subprocess.call(shlex.split('./upload.sh param1 param2'))

    return {
        "success": "Start"
    }
    

# ---------------------------------------------------------------------------- #
#                                RunPod Handler                                #
# ---------------------------------------------------------------------------- #
def handler(event):
    """
    This is the handler function that will be called by RunPod serverless.
    """
    return process_input(event['input'])


if __name__ == '__main__':
    runpod.serverless.start({'handler': handler})
