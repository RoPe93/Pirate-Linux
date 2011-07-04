#!/bin/bash

HOME=$(echo ~)
gconftool-2 -t string -s /desktop/gnome/background/color_shading_type "solid"
gconftool-2 -t bool -s /desktop/gnome/background/picture_filename "true"
gconftool-2 -t string -s /desktop/gnome/background/picture_filename "$HOME/piratepack/theme/boat.svg.png"
gconftool-2 -t int -s /desktop/gnome/background/picture_opacity "100"
gconftool-2 -t string -s /desktop/gnome/background/picture_options "scaled"
gconftool-2 -t string -s /desktop/gnome/background/primary_color "#a3a327272727"
gconftool-2 -t string -s /desktop/gnome/background/secondary_color "#000000000000"
