#!/bin/bash
VERSION="v1.0.2"
rm *.xpkg
docker login
kubectl crossplane build configuration
kubectl crossplane push configuration driosalido/aws-rds-postresql:${VERSION}

#kubectl crossplane install configuration driosalido/aws-rds-postresql:${VERSION}
