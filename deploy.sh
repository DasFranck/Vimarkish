#!/bin/sh

git pull
git submodule update --init
hugo --quiet