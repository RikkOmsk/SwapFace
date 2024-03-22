export PYTHONUNBUFFERED=1
echo $GCP_CRED | base64 -d > /opt/creds.json
# gcloud auth activate-service-account face-swap-writer-gcloud@face-swap-415709.iam.gserviceaccount.com --key-file=/opt/creds.json
python3 -u rp_handler.py
