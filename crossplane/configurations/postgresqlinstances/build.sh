#!/bin/bash
rm *.xpkg
docker login
kubectl crossplane build configuration
kubectl crossplane push configuration driosalido/aws-rds-postresql:v1.0.1

