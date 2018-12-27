#!/bin/bash
xset r rate 250 30 &
xbindkeys &
/opt/IT4smart/sound.sh &
/opt/IT4smart/cleanup.sh &
/opt/IT4smart/StartPage.sh &
xfwm4
