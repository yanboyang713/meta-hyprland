#!/bin/bash

function move() {
    # move a workspace to the appropriate monitor
    local workspace_id=$1
    shift
    local monitors=($@)

    if [[ ${#monitors[@]} == 0 ]]; then
        monitors=($(hyprctl monitors -j | jq -r '.[].name'))
    fi

    echo "Moving workspace $workspace_id in ${#monitors[@]} monitors"

    if [[ ${#monitors[@]} == 1 ]]; then
        hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[1]}" > /dev/null
    elif [[ ${#monitors[@]} == 2 ]]; then
        if [[ $workspace_id -le 5 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[1]}" > /dev/null
        else
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[2]}" > /dev/null
        fi
    elif [[ ${#monitors[@]} == 3 ]]; then
        if [[ $workspace_id -le 3 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[0]}" > /dev/null
        elif [[ $workspace_id -le 7 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[1]}" > /dev/null
        else
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[2]}" > /dev/null
        fi
    elif [[ ${#monitors[@]} == 4 ]]; then
        if [[ $workspace_id -le 2 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[1]}" > /dev/null
        elif [[ $workspace_id -le 5 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[2]}" > /dev/null
        elif [[ $workspace_id -le 8 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[3]}" > /dev/null
        else
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[4]}" > /dev/null
        fi
    elif [[ ${#monitors[@]} == 5 ]]; then
        if [[ $workspace_id -le 2 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[1]}" > /dev/null
        elif [[ $workspace_id -le 4 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[2]}" > /dev/null
        elif [[ $workspace_id -le 6 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[3]}" > /dev/null
        elif [[ $workspace_id -le 8 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[4]}" > /dev/null
        else
            hyprctl dispatch moveworkspacetomonitor "$workspace_id ${monitors[5]}" > /dev/null
        fi
    else
        echo "Not moving your workspaces."
        exit 1
    fi
}

function rearrange() {
    # rearrange workspaces in all monitors
    workspaces=($(hyprctl workspaces -j | jq '.[] | select(.name != "special") | .id'))
    monitors=($(hyprctl monitors -j | jq -r '.[].name'))

    echo "Rearranging ${#workspaces[@]} workspaces in ${#monitors[@]} monitors"

    for workspace_id in ${workspaces[@]}; do
        echo "Rearranging workspace $workspace_id"
        move $workspace_id ${monitors[@]}
    done
}

function handle {
    # handle events from hypr
    if [[ ${1:0:12} == "monitoradded" ]]; then
        rearrange
    fi
    if [[ ${1:0:14} == "monitorremoved" ]]; then
        rearrange
    fi
    if [[ ${1:0:15} == "createworkspace" ]]; then
        workspace_id=$(( ${1:17:18} ))
        move $workspace_id
    fi
    # if [[ ${1:0:9} == "workspace" ]]; then
    #     workspace_id=$(( ${1:11:13} ))
    #     move $workspace_id
    # fi
}

echo "Started!"

socat - UNIX-CONNECT:/tmp/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock | while read line; do handle $line; done
