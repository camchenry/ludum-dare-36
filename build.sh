#!/bin/bash
echo "Removing old releases"
rm -r releases
love-release -D -M -W 64 -W 32 releases .
