#!/bin/bash

# mc config host add <别名> <服务器URL> <访问键> <秘密键>
mc config host add test_minio http://minio.huolan.io admin admin123

# mc rm --recursive --older-than <时间间隔> --force <MinIO别名>/<桶名>/<路径>
mc rm --recursive --older-than 30d --force test_minio/fsc/
