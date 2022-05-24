#!/bin/bash
VERSION="v0.1.0"
rm *.xpkg
docker login
kubectl crossplane build configuration
kubectl crossplane push configuration driosalido/postgresql-rds-aws:${VERSION}
