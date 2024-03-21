#download face_enhancer
echo "### Start ###"
curl -# $1 --output fileIn.mp4
echo "### Downloaded video ###"
curl -# $2 --output face.jpg
echo "### Downloaded face image ###"

#generation
#python -m venv venv
#source ./venv/bin/activate
#echo "### Start of generation ###"
python run.py -s "face.jpg" -t "fileIn.mp4" -o "fileOut.mp4" $3
echo "### Generation ended ###"

#upload
echo "### Upload video ###"
curl -X POST --data-binary @fileOut.mp4\
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: video/mp4" \
    $4
echo "### End ###"
