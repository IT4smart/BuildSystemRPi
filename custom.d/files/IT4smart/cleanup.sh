#!/bin/bash
logger -t "it4s-cleanup" "Start cleaning some directories after boot"

# remove cache and config folder from user's home directory for citrix receiver
logger -t "it4s-cleanup" "Remove folder $HOME/.ICAClient/cache"
rm -r $HOME/.ICAClient/cache

logger -t "it4s-cleanup" "Remove folder $HOME/.ICAClient/config"
rm -r $HOME/.ICAClient/config

