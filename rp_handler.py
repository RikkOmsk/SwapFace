import runpod
import os
import sys
import wget
import roop.globals
from google.cloud import storage
from roop import core

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

    manyFaces = input['many_faces']
    face      = input['frame_processors']

    wget.download(input['videoUrl'])
    wget.download(input['photoUrl'])

    roop.globals.source_path = input['photoUrlF']
    roop.globals.target_path = input['videoUrlF']
    roop.globals.output_path = "out.mp4"

    if face == "face_enhancer":
        roop.globals.frame_processors = [ 'face_swapper', 'face_enhancer']
    else:
        roop.globals.frame_processors = [ 'face_swapper']
    
    if manyFaces == "true":
        roop.globals.many_faces = "store_true"
        
    
    roop.globals.reference_face_position = input['referenceFacePosition']
    roop.globals.reference_frame_number = input['referenceFrameNumber']
    roop.globals.similar_face_distance = input['similarFaceDistance']
    roop.globals.execution_providers = ['CUDAExecutionProvider']
    roop.globals.output_video_quality = input['outputVideoQuality']
    roop.globals.output_video_encoder = input['outputVideoEncoder']
    # CoreMLExecutionProvider
    # CPUExecutionProvider
    roop.globals.execution_threads = input['executionThreads']

    core.run()
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
