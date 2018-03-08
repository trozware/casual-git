#!/bin/bash

# Shows help to the user.
function _show_usage() {
  _print_empty_line
  _print_newline_message "\033[1;34mBranch: \033[1;31m`_current_branch` `_branch_is_clean`"
  _print_empty_line

  _print_newline_message "\033[1;31ms \033[0m - status"
  _print_newline_message "\033[1;31ml \033[0m - log"
  _print_newline_message "\033[1;31m+ \033[0m - add"
  _print_newline_message "\033[1;31mc \033[0m - commit"
  _print_newline_message "\033[1;31mp \033[0m - push"
  _print_newline_message "\033[1;31mu \033[0m - pull"
  _print_newline_message "\033[1;31mb \033[0m - list branches"
  _print_newline_message "\033[1;31mn \033[0m - create new branch"
  _print_newline_message "\033[1;31mk \033[0m - checkout branch"
  _print_newline_message "\033[1;31mm \033[0m - merge"
  _print_newline_message "\033[1;31md \033[0m - delete branch"
  _print_newline_message "... any other key to exit"
  _print_empty_line
}

# Formatted cross or tick to put after current branch name
function _branch_is_clean() {
  local status
  local len_status

  status=`_git_status_short`
  len_status=${#status}

  if [ $len_status -lt 2 ]
  then
    echo "\033[1;32m√"
  else
    echo "\033[1;33mX"
  fi
}

# Get short form which will be empty if the branch is clean
function _git_status_short() {
  git status -s
}

# Prints the current project's branch.
function _current_branch() {
  git rev-parse --abbrev-ref HEAD
}

# User input is shown.
function _turn_on_user_input() {
  stty echo
}

# User input is not shown.
function _turn_off_user_input() {
  stty -echo
}

# Clear Terminal window.
function _clear_screen() {
  printf "\033c"
}

# Prints a message with a line break.
function _print_newline_message() {
  printf "  $1\n"
}

function _print_startline_message() {
  printf "$1\n"
}

# Prints a message with no line break.
function _print_input_request_message() {
  printf "$1"
}

# Prints a line break.
function _print_empty_line() {
  printf "\n"
}

# Asks the user to enter any character.
function _ask_for_a_char() {
  local _answer;

  read -r -s -n 1 _answer

  echo ${_answer}
}

function _command_git_status() {
  git status
}

function _command_git_push() {
  _print_startline_message "Pushing..."
  git push origin "`_current_branch`"
}

function _command_git_pull() {
  _print_startline_message "Pulling..."
  git pull origin "`_current_branch`"
}

function _command_git_pretty_log() {
  git log \
  --color \
  --graph \
  --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' \
  --abbrev-commit
}

function _command_git_add_all() {
  _print_startline_message "Adding all..."
  git add .
}

function _command_git_commit() {
  local -a _comment

  _print_empty_line
  _print_input_request_message "If applied, this commit will: "

  read _comment

  if [ "${_comment}" != '' ]
  then
    git commit -m "${_comment}"
  fi
}

function _command_new_branch() {
  local -a _branch_name

  _print_empty_line
  _print_input_request_message "Create new branch named: "

  read _branch_name

  if [ "${_branch_name}" != '' ]
  then
    git checkout -b "${_branch_name}" > /dev/null
  fi
}

function _command_git_list_branches() {
  _print_startline_message "Branches:"
  _print_empty_line

  git branch

  _print_empty_line
}

function _command_git_checkout() {
  local -a _branch_name

  _print_empty_line
  _print_input_request_message "Checkout branch named: "

  read _branch_name

  if [ "${_branch_name}" != '' ]
  then
    git checkout "${_branch_name}" > /dev/null
  fi
}

function _command_git_merge() {
  local -a _branch_name

  _print_empty_line
  _print_startline_message "Current branch: `_current_branch`"
  _print_input_request_message "Branch to merge in: "

  read _branch_name

  if [ "${_branch_name}" != '' ]
  then
    git merge "${_branch_name}" > /dev/null
  fi
}

function _command_git_delete_branch() {
  local -a _branch_name

  _print_empty_line
  _print_startline_message "Current branch: `_current_branch`"
  _print_input_request_message "Branch to delete: "

  read _branch_name

  if [ "${_branch_name}" != "" ]
  then
    git branch -d "${_branch_name}" > /dev/null
  fi
}

_clear_screen

while [[ 1 -eq 1 ]];
do

  _show_usage

  case `_ask_for_a_char` in
    s|S)
      _command_git_status
      ;;
    l|L)
      _command_git_pretty_log
      ;;
    p|P)
      _command_git_push
      ;;
    u|U)
      _command_git_pull
      ;;
    +|=)
      _command_git_add_all
      ;;
    c|C)
      _turn_on_user_input
      _command_git_commit
      ;;
    n|N)
      _turn_on_user_input
      _command_new_branch
      ;;
    b|B)
      _command_git_list_branches
      ;;
    k|K)
      _turn_on_user_input
      _command_git_checkout
      ;;
    m|M)
      _turn_on_user_input
      _command_git_merge
      ;;
    d|D)
      _turn_on_user_input
      _command_git_delete_branch
      ;;
    *)
      exit 0;
    esac

  _turn_on_user_input

done
