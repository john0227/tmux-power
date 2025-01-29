#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-05 17:37
#===============================================================================

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/scripts/utils.sh

# Options
rarrow=$(tmux_get '@tmux_power_right_arrow_icon' '')
rarrow_tail=$(tmux_get '@tmux_power_right_arrow_tail_icon' '')
larrow=$(tmux_get '@tmux_power_left_arrow_icon' '')
larrow_tail=$(tmux_get '@tmux_power_left_arrow_tail_icon' '')
upload_speed_icon=$(tmux_get '@tmux_power_upload_speed_icon' '󰕒')
download_speed_icon=$(tmux_get '@tmux_power_download_speed_icon' '󰇚')
session_icon="$(tmux_get '@tmux_power_session_icon' '')"
window_icon="$(tmux_get '@tmux_power_window_icon' '')"
user_icon="$(tmux_get '@tmux_power_user_icon' '')"
time_icon="$(tmux_get '@tmux_power_time_icon' '')"
date_icon="$(tmux_get '@tmux_power_date_icon' '')"
show_user="$(tmux_get @tmux_power_show_user true)"
show_host="$(tmux_get @tmux_power_show_host true)"
show_session="$(tmux_get @tmux_power_show_session true)"
show_upload_speed="$(tmux_get @tmux_power_show_upload_speed false)"
show_download_speed="$(tmux_get @tmux_power_show_download_speed false)"
show_web_reachable="$(tmux_get @tmux_power_show_web_reachable false)"
show_git_status="$(tmux_get @tmux_power_show_git_status true)"
show_cpu_status="$(tmux_get @tmux_power_show_cpu_status true)"
show_ram_status="$(tmux_get @tmux_power_show_ram_status true)"
show_battery_status="$(tmux_get @tmux_power_show_battery_status true)"
prefix_highlight_pos=$(tmux_get @tmux_power_prefix_highlight_pos)
time_format=$(tmux_get @tmux_power_time_format '%T')
date_format=$(tmux_get @tmux_power_date_format '%F')

# short for Theme-Colour
# TC=$(tmux_get '@tmux_power_theme' 'gold')
TC=$(theme2color)

BG=$(tmux_get @tmux_power_bg "default")
G0=$(tmux_get @tmux_power_g0 "#262626")
G1=$(tmux_get @tmux_power_g1 "#303030")
G2=$(tmux_get @tmux_power_g2 "#3a3a3a")
G3=$(tmux_get @tmux_power_g3 "#444444")
G4=$(tmux_get @tmux_power_g4 "#626262")
G5=$(tmux_get @tmux_power_g5 "#B8DB70")
G6=$(tmux_get @tmux_power_g6 "#C870DB")

# Status options
tmux_set status-interval 1
tmux_set status on

# Basic status bar colors
tmux_set status-style "bg=$BG"
tmux_set status-bg "$BG"
tmux_set status-fg "$G4"
tmux_set status-attr none

# tmux-prefix-highlight
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$BG,bold"
tmux_set @prefix_highlight_output_prefix "#[fg=$TC]#[bg=$BG] #[bg=$TC]#[fg=$G0]"
tmux_set @prefix_highlight_output_suffix "#[fg=$TC]#[bg=$BG] "

#     
# Left side of status bar
tmux_set status-left-length 150

# user@host
if "$show_user" && "$show_host"; then
    LS="#[fg=$G0,bg=$TC,bold] $user_icon $(whoami)@#h #[fg=$TC,bg=$BG,nobold]$rarrow"
elif "$show_user"; then
    LS="#[fg=$G0,bg=$TC,bold] $user_icon $(whoami) #[fg=$TC,bg=$BG,nobold]$rarrow"
elif "$show_host"; then
    LS="#[fg=$G0,bg=$TC,bold] #h #[fg=$TC,bg=$BG,nobold]$rarrow"
fi

# git status (shows origin and branch names)
if "$show_git_status"; then
    # If .git is not found, just show cwd
    git_info="#($current_dir/scripts/git.sh)"
    LS="$LS$git_info"
fi

# session
if "$show_session"; then
    LS="$LS#[fg=$G6,bg=$BG]$larrow_tail#[fg=$G0,bg=$G6] $session_icon #S #[fg=$G6,bg=$BG]$rarrow"
fi

# upload speed
if "$show_upload_speed"; then
    LS="$LS#[fg=$G2,bg=$G1]$rarrow#[fg=$TC,bg=$G1] $upload_speed_icon #{upload_speed} #[fg=$G1,bg=$BG]$rarrow"
fi

if [[ $prefix_highlight_pos == 'L' || $prefix_highlight_pos == 'LR' ]]; then
    LS="$LS#{prefix_highlight}"
fi

tmux_set status-left "$LS"

# Right side of status bar
tmux_set status-right-length 150
RS="#[fg=$TC,bg=$BG] $time_icon $time_format  $date_icon $date_format #[fg=$TC,bg=$BG]$larrow#[fg=$G2,bg=$TC,bold] 🧁cupcakes  "
if "$show_download_speed"; then
    RS="#[fg=$G1,bg=$BG]$larrow#[fg=$TC,bg=$G1] $download_speed_icon #{download_speed} $RS"
fi
if "$show_web_reachable"; then
    RS=" #{web_reachable_status} $RS"
fi
if "$show_battery_status"; then
    battery_info="#($current_dir/scripts/battery.sh)"
    RS="#[fg=$TC,bg=$BG] $battery_info $RS"
fi
if "$show_cpu_status"; then
    cpu_info="#($current_dir/scripts/cpu.sh)"
    RS="#[fg=$TC,bg=$BG] $cpu_info$RS"
fi
if "$show_ram_status"; then
    ram_info="#($current_dir/scripts/ram.sh)"
    RS="#[fg=$TC,bg=$BG] $ram_info$RS"
fi

if [[ $prefix_highlight_pos == 'R' || $prefix_highlight_pos == 'LR' ]]; then
    RS="#{prefix_highlight}$RS"
fi

tmux_set status-right "$RS"

# Window status format
tmux_set window-status-format         "#[fg=$G3,bg=$BG]#[fg=$TC,bg=$G3] $window_icon #I:#W#F #[fg=$G3,bg=$BG]$rarrow"
tmux_set window-status-current-format "#[fg=$TC,bg=$BG]#[fg=$G0,bg=$TC,bold] $window_icon #I:#W#F #[fg=$TC,bg=$BG,nobold]$rarrow"

# Window status style
tmux_set window-status-style          "fg=$TC,bg=$BG,none"
tmux_set window-status-last-style     "fg=$TC,bg=$BG,bold"
tmux_set window-status-activity-style "fg=$TC,bg=$BG,bold"

# Window separator
tmux_set window-status-separator ""

# Pane border
tmux_set pane-border-style "fg=$G3,bg=default"

# Active pane border
tmux_set pane-active-border-style "fg=$TC,bg=default"

# Pane number indicator
tmux_set display-panes-colour "$G3"
tmux_set display-panes-active-colour "$TC"

# Clock mode
tmux_set clock-mode-colour "$TC"
tmux_set clock-mode-style 24

# Message
tmux_set message-style "fg=$TC,bg=$BG"

# Command message
tmux_set message-command-style "fg=$TC,bg=$BG"

# Copy mode highlight
tmux_set mode-style "bg=$TC,fg=$G4"
