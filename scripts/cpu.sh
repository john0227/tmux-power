#!/usr/bin/env bash

# From https://github.com/2KAbhishek/tmux2k/blob/main/scripts/cpu.sh

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

get_percent() {
    case $(uname -s) in
    Linux)
        percent=$(LC_NUMERIC=en_US.UTF-8 top -bn2 -d 0.01 | grep "Cpu(s)" | tail -1 | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
        normalize_padding "$percent"
        ;;

    Darwin)
        cpuvalue=$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')
        cpucores=$(sysctl -n hw.logicalcpu)
        cpuusage=$((cpuvalue / cpucores))
        percent="$cpuusage%"
        normalize_padding "$percent"
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

get_load() {
    case $(uname -s) in
    Linux | Darwin)
        loadavg=$(uptime | awk -F'[a-z]:' '{ print $2}' | sed 's/,//g')
        echo "$loadavg"
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

main() {
    RATE=$(tmux_get "@tmux2k-refresh-rate" 5)
    cpu_load=$(tmux_get "@tmux2k-cpu-display-load" false)
    if [ "$cpu_load" = true ]; then
        echo "$(get_load)"
    else
        cpu_label=$(tmux_get "@tmux2k-cpu-usage-label" "")
        cpu_percent=$(get_percent)
        echo "$cpu_label $cpu_percent"
    fi
    sleep "$RATE"
}

main