#!/bin/sh

git pull
hugo --quiet
chown -R www:www /srv/http/Vimarkish/