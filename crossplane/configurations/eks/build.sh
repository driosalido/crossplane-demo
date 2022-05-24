#!/bin/bash
VERSION="v0.0.1"
rm *.xpkg
docker login
kubectl crossplane build configuration
kubectl crossplane push configuration driosalido/eks-cluster:${VERSION}
sleep 3
kubectl crossplane install configuration driosalido/eks-cluster:${VERSION}
