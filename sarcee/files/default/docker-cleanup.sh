#!/bin/bash
set -e

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock zzrot/docker-clean
