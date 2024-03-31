import runpod
import os
import sys
import wget
import facefusion.globals
import facefusion.processors.frame.globals
from google.cloud import storage
from facefusion import core

os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="/opt/creds.json"
# /opt/creds.json 

def upload_blob(source_file_name, destination_blob_name):
    """Uploads a file to the bucket."""
    storage_client = storage.Client()
    bucket = storage_client.get_bucket("face-swap-images")
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(source_file_name)
    return blob.public_url


def process_input(input):
    """
    Execute the application code
    """

    # manyFaces = input['many_faces']
    # face      = input['frame_processors']

    wget.download(input['videoUrl'])
    wget.download(input['photoUrl'])

    facefusion.globals.source_paths = input['photoUrlF']
    facefusion.globals.target_path = input['videoUrlF']
    facefusion.globals.output_path = "./out.mp4"

    facefusion.globals.headless = True
    facefusion.globals.execution_providers = ['CUDAExecutionProvider']
    facefusion.globals.execution_thread_count = input['threadCount']
    facefusion.globals.execution_queue_count = input['queueCount']
    facefusion.processors.frame.globals.face_swapper_model = input['faceSwapperModel']
    

    core.cli()
    outputFile = "generation/" + input['userID'] + "/" + input['documentID'] + input['fileFormat']
    print(upload_blob('out.mp4', outputFile))


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
