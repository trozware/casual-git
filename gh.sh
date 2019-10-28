#!/bin/bash

# Shows help to the user.
function _show_usage() {
  _print_empty_line
  _print_newline_message "\033[1;33mBranch: \033[1;31m`_current_branch` `_branch_is_clean`"
  _print_empty_line

  _print_newline_message "\033[1;31ms \033[0m - status"
  _print_newline_message "\033[1;31ml \033[0m - log"
  _print_newline_message "\033[1;31m+ \033[0m - add"
  _print_newline_message "\033[1;31mc \033[0m - commit"
  _print_newline_message "\033[1;31mp \033[0m - push"
  _print_newline_message "\033[1;31mu \033[0m - pull"
  _print_newline_message "\033[1;31mt \033[0m - tag & push"
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

# Prints a message with a line break but no leading spaces.
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

# Prints all the local branches, excluding the current branch
function _all_git_branches() {
  git branch \
  | sed 's/^[[:space:]][[:space:]][[:alnum:]]*\/[[:alnum:]]*\///g' \
  | sed '/HEAD -> [[:alnum:]/]*/d' \
  | sed '/^* [[:alnum:]]*/d'
}

# Counts the amount of the branches
function _how_many_branches_match() {
  local _matching_branches_count=0
  local -a _all_branches=(`_all_git_branches`)

  # iterating over all branches and counting
  # no longer checking for matching name, so there is probably a better way to do this
  for i in "${_all_branches[@]}"
  do
      ((_matching_branches_count++))
  done

  echo ${_matching_branches_count}
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
  --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold cyan)<%an>%Creset' \
  --abbrev-commit
}

function _command_git_add_all() {
  _print_startline_message "Adding all..."
  git add .
}

function _command_git_commit() {
  local -a _comment
  local status
  local len_status

  status=`_git_status_short`
  len_status=${#status}

  if [ $len_status -lt 2 ]
  then
    _print_startline_message "Nothing to commit, working tree clean"
  else
    _print_input_request_message "If applied, this commit will: "

    read _comment

    if [[ -n ${_comment} ]];
    then
      git commit -am "${_comment}"
    fi
  fi
}

function _command_git_tag_push() {
  local -a _tag
  local -a _do_push

  _print_input_request_message "Enter tag description: "
  read _tag

  if [[ -n ${_tag} ]];
  then
    _print_startline_message "Applying tag '${_tag}'..."
    git tag "${_tag}"

    _print_input_request_message "Push tag? y/n "
    read _do_push

    if [[ ${_do_push} = 'y' ]];
    then
      _print_startline_message "Pushing tag '${_tag}'..."
      git push origin "${_tag}"
    fi
  fi
}

function _command_new_branch() {
  local -a _branch_name

  _print_input_request_message "Create new branch named: "

  read _branch_name

  if [[ -n ${_branch_name} ]];
  then
    git checkout -b "${_branch_name}" > /dev/null
  fi
}

function _command_git_list_branches() {
  _print_startline_message "Branches:"
  _print_empty_line

  git branch
}

function _command_git_checkout() {
  local    _user_choice_branch_counter=1
  local    _desired_branch_index
  local -a _matching_branches

  # there is more than one other branch
  if [[ `_how_many_branches_match` -gt 0 ]]; then
    _print_startline_message "Please choose a branch to checkout: "
    _print_empty_line

    # all the branches except the current
    _matching_branches=(`_all_git_branches`)

    while [[ 1 -eq 1 ]];
    do
      _user_choice_branch_counter=0

      # printing all the branches
      for branch in "${_matching_branches[@]}";
      do
          _print_newline_message "[${_user_choice_branch_counter}] \033[1;31m"${branch}"\033[0m"
          ((_user_choice_branch_counter++))
      done

      _print_empty_line

      # ask the user to input a branch index
      _desired_branch_index=`_ask_for_a_char`

        # if the branch exists with the entered index
        if [[ -n "${_matching_branches[${_desired_branch_index}]}" ]];
        then
          git checkout "${_matching_branches[${_desired_branch_index}]}"
          return 0
        else
          return 1
        fi
    done
  fi

  _print_newline_message "No other local branches found."
}

# This duplicates a lot of the code from _command_git_checkout
# but I haven't worked out how to separate out the branch selection
function _command_git_merge() {
  local    _user_choice_branch_counter=1
  local    _desired_branch_index
  local -a _matching_branches

  # there is more than one other branch
  if [[ `_how_many_branches_match` -gt 0 ]]; then
    _print_startline_message "Current branch: \033[1;31m`_current_branch`\033[0m"
    _print_startline_message "Please choose a branch to merge in: "
    _print_empty_line

    # all the branches except the current
    _matching_branches=(`_all_git_branches`)

    while [[ 1 -eq 1 ]];
    do
      _user_choice_branch_counter=0

      # printing all the branches
      for branch in "${_matching_branches[@]}";
      do
          _print_newline_message "[${_user_choice_branch_counter}] \033[1;31m"${branch}"\033[0m"
          ((_user_choice_branch_counter++))
      done

      _print_empty_line

      # ask the user to input a branch index
      _desired_branch_index=`_ask_for_a_char`

        # if the branch exists with the entered index
        if [[ -n "${_matching_branches[${_desired_branch_index}]}" ]];
        then
          git merge "${_matching_branches[${_desired_branch_index}]}"
          return 0
        else
          return 1
        fi
    done
  fi

  _print_newline_message "No other local branches found."
}

# This duplicates a lot of the code from _command_git_checkout
# but I haven't worked out how to separate out the branch selection
function _command_git_delete_branch() {
  local    _user_choice_branch_counter=1
  local    _desired_branch_index
  local -a _matching_branches

  # there is more than one other branch
  if [[ `_how_many_branches_match` -gt 0 ]]; then
    _print_startline_message "Please choose a branch to delete: "
    _print_empty_line

    # all the branches except the current
    _matching_branches=(`_all_git_branches`)

    while [[ 1 -eq 1 ]];
    do
      _user_choice_branch_counter=0

      # printing all the branches
      for branch in "${_matching_branches[@]}";
      do
          _print_newline_message "[${_user_choice_branch_counter}] \033[1;31m"${branch}"\033[0m"
          ((_user_choice_branch_counter++))
      done

      _print_empty_line

      # ask the user to input a branch index
      _desired_branch_index=`_ask_for_a_char`

        # if the branch exists with the entered index
        if [[ -n "${_matching_branches[${_desired_branch_index}]}" ]];
        then
          git branch -d "${_matching_branches[${_desired_branch_index}]}"
          return 0
        else
          return 1
        fi
    done
  fi

  _print_newline_message "No other local branches found."
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
    t|T)
      _command_git_tag_push
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
