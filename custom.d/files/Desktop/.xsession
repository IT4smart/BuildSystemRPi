#!/bin/bash
xset r rate 250 30 &
xbindkeys &
/opt/IT4S/cleanup.sh &
/opt/IT4S/StartPage.sh &
xfwm4