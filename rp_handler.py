import runpod
import os
import sys
import wget
import facefusion.globals
from facefusion.processors.frame import globals as frame_processors_globals
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

    face = input['frame_processors']

    wget.download(input['videoUrl'])
    wget.download(input['photoUrl'])

    facefusion.globals.source_paths = [input['photoUrlF']]
    facefusion.globals.target_path = input['videoUrlF']
    facefusion.globals.output_path = "./out.mp4"

    facefusion.globals.headless = True
    facefusion.globals.execution_providers = ['CUDAExecutionProvider']
    facefusion.globals.execution_thread_count = input['threadCount']
    facefusion.globals.execution_queue_count = input['queueCount']


    facefusion.globals.output_video_encoder = "libx264"
    facefusion.globals.output_video_preset = "veryfast"
    facefusion.globals.output_video_quality = 55




    facefusion.globals.face_selector_mode = "reference"
    if (input['faceSelectorMode'] == 'reference'):
        facefusion.globals.face_selector_mode = "reference"

    if (input['faceSelectorMode'] == 'one'):
        facefusion.globals.face_selector_mode = "one"

    if (input['faceSelectorMode'] == 'many'):
        facefusion.globals.face_selector_mode = "many"

    facefusion.globals.reference_face_distance = 0.6
    if (input['referenceFaceDistance'] > 0):
        facefusion.globals.reference_face_distance = input['referenceFaceDistance']

    facefusion.globals.face_detector_score = 0.5
    if (input['faceDetectorScore'] > 0):
        facefusion.globals.face_detector_score = input['faceDetectorScore']

    facefusion.globals.face_landmarker_score = 0.5
    if (input['faceLandmarkerScore'] > 0):
        facefusion.globals.face_landmarker_score = input['faceLandmarkerScore']


    facefusion.processors.frame.globals.face_swapper_model = input['faceSwapperModel']

    if face == "face_enhancer":
        facefusion.globals.frame_processors = ['face_swapper', 'face_enhancer']
    else:
        facefusion.globals.frame_processors = ['face_swapper']

    facefusion.processors.frame.globals.face_enhancer_model = input['faceEnhancerModel']
    facefusion.processors.frame.globals.face_enhancer_blend = input['faceEnhancerBlend']



    core.cli()



    outputFile = "generation/" + input['userID'] + "/" + input['documentID'] + input['fileFormat']
    print(upload_blob('out.mp4', outputFile))
    os.remove('out.mp4')

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
