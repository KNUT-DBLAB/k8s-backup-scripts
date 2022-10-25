#!/bin/bash
velero install \
    --provider aws \
    --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://172.30.0.100:9000,publicUrl=http://172.30.0.100:9000 \
    --bucket velero001 \
    --secret-file /home/oys/velero-workspace/credentials-minio \
    --image docker.io/velero/velero:v1.9.0 \
    --plugins docker.io/velero/velero-plugin-for-aws:v1.5.0 \
    --wait \
    --use-restic \
    --output yaml \
    >>/home/oys/velero-workspace/install-output.yaml
