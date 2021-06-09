#!/usr/bin/env bash

###############################################################################
#
# demo-magic.sh
#
# Copyright (c) 2015 Paxton Hare
# Additional code copyright (c) 2020,2021 Joe Thompson
#
# This script lets you script demos in bash. It runs through your demo script 
# when you press ENTER. It simulates typing and runs commands.
#
###############################################################################

# the speed to "type" the text
TYPE_SPEED=${DEMO_TYPE_SPEED:-20}

# no wait after "p" or "pe"
NO_WAIT=${DEMO_NO_WAIT:-false}

# wait only "before" typing, only "after" typing, or "both" before and after
WAIT_AT=${DEMO_WAIT_AT:-"before"}

# if > 0, will pause for this amount of seconds before automatically proceeding with any p or pe
PROMPT_TIMEOUT=${DEMO_PROMPT_TIMEOUT:-0}

# don't show command number unless user specifies it
SHOW_CMD_NUMS=${DEMO_SHOW_CMD_NUMS:-false}

# clear the screen by default when the demo starts
INIT_CLEAR=${DEMO_INIT_CLEAR:-"true"}

# handy color vars for pretty prompts
BLACK="\033[0;30m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
GREY="\033[0;90m"
CYAN="\033[0;36m"
RED="\033[0;31m"
PURPLE="\033[0;35m"
BROWN="\033[0;33m"
WHITE="\033[1;37m"
COLOR_RESET="\033[0m"

# initialize command numbering
C_NUM=0

# prompt and command color which can be overriden
DEMO_PROMPT="$ "
DEMO_CMD_COLOR=$WHITE
DEMO_COMMENT_COLOR=$GREY

##
# print the prompt
##
function magic_prompt() {
  # render the prompt
  x=$(PS1="$DEMO_PROMPT" "$BASH" --norc -i </dev/null 2>&1 | sed -n '${s/^\(.*\)exit$/\1/p;}')

  # show command number is selected
  if $SHOW_CMD_NUMS; then
   printf "[$((++C_NUM))] '%s'" "$x"
  else
   printf '%s' "$x"
  fi
}

##
# prints the script usage
##
function usage() {
  echo -e ""
  echo -e "Usage: $0 [options]"
  echo -e ""
  echo -e "\tWhere options is one or more of:"
  echo -e "\t-h\tPrints Help text"
  echo -e "\t-a\tWhether to wait before or after simulated typing for user "
  echo -e "\t\tto hit enter (before, after, both; default: before)"
  echo -e "\t-c\tWhether to print command numbers (default: false)"
  echo -e "\t-d\tDebug mode. Disables simulated typing"
  echo -e "\t-n\tNo wait"
  echo -e "\t-s\tTyping speed (default: 20)"
  echo -e "\t-w\tWaits max the given amount of seconds before proceeding "
  echo -e "\t\twith demo (e.g. '-w5')"
  echo -e ""
}

##
# wait for user to press ENTER
# if $PROMPT_TIMEOUT > 0 this will be used as the max time for proceeding 
# automatically
##
function wait() {

  if [[ "$PROMPT_TIMEOUT" == "0" ]]; then
    read -rs
  else
    read -rst "$PROMPT_TIMEOUT"
  fi

}

##
# start the demo.  Clears the screen and prints a prompt.
##

function start_demo() {
  clear
  magic_prompt
}

##
# end the demo.  Echoes a blank line without printing any command.
##

function end_demo() {
  echo ""
}

##
# print the command supplied for pe or p
##
function magic_print() {

  if [[ ${1:0:1} == "#" ]]; then
    cmd=$DEMO_COMMENT_COLOR$1$COLOR_RESET
  else
    cmd=$DEMO_CMD_COLOR$1$COLOR_RESET
  fi

  # wait for the user to press a key before typing the command
  if ! $NO_WAIT && [[ "$WAIT_AT" =~ "both"|"before" ]]; then
    wait
  fi

  if [[ -z $TYPE_SPEED ]]; then
    echo -en "$cmd"
  else
    echo -en "$cmd" | pv -qL $(( TYPE_SPEED+(-2 + RANDOM%5) ));
  fi

  # wait for the user to press a key before moving on
  if ! $NO_WAIT && [[ "$WAIT_AT" =~ "both"|"after" ]]; then
    wait
  fi
  echo ""
}

##
# execute the command supplied for pe
##
function magic_exec() {
  eval "$@"
}

##
# print command only. Useful for when you want to pretend to run a command
#
# takes 1 param - the string command to print
#
# usage: p "ls -l"
#
##
function p() {
  magic_print "$@"
  magic_prompt
}

##
# Prints and executes a command
#
# takes 1 parameter - the string command to run
#
# usage: pe "ls -l"
#
##
function pe() {
  # print the command
  magic_print "$@"

  # execute the command
  magic_exec "$@"

  magic_prompt
}

##
# Prints and executes, but disables waiting for just this command
#
# takes 1 parameter - the string command to run
#
# usage: pei "ls -l"
#
##
function pei() {
  # print the command
  NO_WAIT=true magic_print "$@"

  # execute the command
  magic_exec "$@"

  magic_prompt
}

##
# Enters script into interactive mode
#
# and allows newly typed commands to be executed within the script
#
# usage : cmd
#
##
function cmd() {
  # render the prompt
  x=$(PS1="$DEMO_PROMPT" "$BASH" --norc -i </dev/null 2>&1 | sed -n '${s/^\(.*\)exit$/\1/p;}')
  printf "%s\033[0m" "$x"
  read command
  eval "${command}"
}


function check_pv() {
  command -v pv >/dev/null 2>&1 || {

    echo ""
    echo -e "${RED}##############################################################"
    echo "# HOLD IT!! I require pv but it's not installed.  Aborting." >&2;
    echo -e "${RED}##############################################################"
    echo ""
    echo -e "${COLOR_RESET}Installing pv:"
    echo ""
    echo -e "${BLUE}Mac:${COLOR_RESET} $ brew install pv"
    echo ""
    echo -e "${BLUE}Other:${COLOR_RESET} http://www.ivarch.com/programs/pv.shtml"
    echo -e "${COLOR_RESET}"
    exit 1;
  }
}

check_pv
#
# handle some default params
# -h for help
# -d for disabling simulated typing
#
while getopts ":a:dhncw:s:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    a)
      WAIT_AT=$OPTARG
      ;;
    d)
      unset TYPE_SPEED
      ;;
    n)
      NO_WAIT=true
      ;;
    c)
      SHOW_CMD_NUMS=true
      ;;
    w)
      PROMPT_TIMEOUT=$OPTARG
      ;;
    s)
      TYPE_SPEED=$OPTARG
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done
