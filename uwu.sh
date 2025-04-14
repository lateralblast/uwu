#!/usr/bin/env bash

# Name:         uwu (Ubuntu Working/Monitoring UPS)
# Version:      0.1.3
# Release:      1
# License:      CC-BA (Creative Commons By Attribution)
#               http://creativecommons.org/licenses/by/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          https://github.com/lateralblast/uwu
# Distribution: UNIX
# Vendor:       UNIX
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  A template for writing shell scripts

# Insert some shellcheck disables
# Depending on your requirements, you may want to add/remove disables
# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2129

# Grab arrays

declare -A os
declare -A new 
declare -A old 
declare -A nut 
declare -A ups 
declare -A slack 
declare -A script
declare -A options 
declare -A defaults 
declare -a option_flags
declare -a action_flags

# Grab script information and put it into an associative array

script['args']="$*"
script['file']="$0"
script['name']="uwu"
script['file']=$( realpath "${script['file']}" )
script['path']=$( dirname "${script['file']}" )
script['modulepath']="${script['path']}/modules"
script['bin']=$( basename "${script['file']}" )

# Function: set_defaults
#
# Set defaults

set_defaults () {
  ups['name']="cps"
  ups['port']="auto"
  nut['conf']="/etc/nut/nut.conf"
  ups['conf']="/etc/nut/ups.conf"
  ups['desc']="Cyber Power System, Inc. CP1500 AVR UPS"
  ups['param']="battery.charge"
  ups['driver']="usbhid-ups"
  ups['productid']="0501"
  nut['hostname']="localhost"
  slack['prefix']=""
  slack['message']=""
  slack['webhook']=""
  script['endpoint']="console"
  script['location']=""
  script['workdir']="$HOME/.${script['name']}"
  slack['webhookfile']="${script['workdir']}/slackwebhook"
  options["yes"]="false"      # option - Answer yes to all questions
  options["test"]="false"     # option - Run in test mode
  options["debug"]="false"    # option - Run in debug mode
  options["force"]="false"    # option - Force action
  options["print"]="false"    # option - Print to console
  options["strict"]="false"   # option - Run is strict mode
  options["dryrun"]="false"   # option - Run in dryrun mode
  options["verbose"]="false"  # option - Run in verbose mode
  options["masked"]="false"   # option - Mask sensitive information in console output where possible
  options["actions"]="false"  
  options["options"]="false"  
  os['name']=$( uname -s )
  if [ "${os['name']}" = "Linux" ]; then
    os['distro']=$( lsb_release -i -s 2> /dev/null )
  fi
}

set_defaults

# Function: print_message
#
# Print message

print_message () {
  message="$1"
  format="$2"
  if [ "${format}" = "verbose" ]; then
    echo "${message}"
  else
    if [[ "${format}" =~ warn ]]; then
      echo -e "Warning:\t${message}"
    else
      if [ "${options['verbose']}" = "true" ]; then
        if [[ "${format}" =~ ing$ ]]; then
          format="${format^}"
        else
          if [[ "${format}" =~ t$ ]]; then
            format="${format^}ting"
          else
            if [[ "${format}" =~ e$ ]]; then
              if [[ ! "${format}" =~ otice ]]; then
                format="${format::-1}"
                format="${format^}ing"
              fi
            fi
          fi
        fi 
        format="${format^}"
        length="${#format}"
        if [ "${length}" -lt 7 ]; then
          tabs="\t\t"
        else
          tabs="\t"
        fi
        echo -e "${format}:${tabs}${message}"
      fi
    fi
  fi
}

# Function: warning_message
#
# Warning message

warning_message () {
  message="$1"
  print_message "${message}" "warn"
}

# Function: execute_message
#
# Print command

execute_message () {
  message="$1"
  print_message "${message}" "execute"
}

# Enable verbose mode

if [[ "${script['args']}" =~ "verbose" ]]; then
  options["verbose"]="true"
  print_message "verbose to true" "set"
fi

# Load modules

if [ -d "${script['modulepath']}" ]; then
  modules=$( find "${script['modulepath']}" -name "*.sh" )
  for module in ${modules}; do
    if [[ "${script['args']}" =~ "verbose" ]]; then
     print_message "Module ${module}" "load"
    fi
    . "${module}"
  done
fi

# Function: reset_defaults
#
# Reset defaults based on command line options

reset_defaults () {
  if [ "${options['debug']}" = "true" ]; then
    print_message "Enabling debug mode" "notice"
    set -x
  fi
  if [ "${options['strict']}" = "true" ]; then
    print_message "Enabling strict mode" "notice"
    set -u
  fi
  if [ "${options['dryrun']}" = "true" ]; then
    print_message "Enabling dryrun mode" "notice"
  fi
}

# Function: do_exit
#
# Selective exit (don't exit when we're running in dryrun mode)

do_exit () {
  if [ "${options['dryrun']}" = "false" ]; then
    exit
  fi
}

# Function: check_value
#
# check value (make sure that command line arguments that take values have values)

check_value () {
  param="$1"
  value="$2"
  if [[ "${value}" =~ "--" ]]; then
    print_message "Value '$value' for parameter '$param' looks like a parameter" "verbose"
    echo ""
    if [ "${options['force']}" = "false" ]; then
      do_exit
    fi
  else
    if [ "${value}" = "" ]; then
      print_message "No value given for parameter $param" "verbose"
      echo ""
      if [[ "${param}" =~ "option" ]]; then
        print_options
      else
        if [[ "${param}" =~ "action" ]]; then
          print_actions
        else
          print_help
        fi
      fi
      exit
    fi
  fi
}

# Function: execute_command
#
# Execute command

execute_command () {
  command="$1"
  privilege="$2"
  if [[ "${privilege}" =~ su ]]; then
    command="sudo sh -c \"${command}\""
  fi
  if [ "${options['verbose']}" = "true" ]; then
    print_message "${command}" "execute"
  fi
  if [ "${options['dryrun']}" = "false" ] || [[ "${privilege}" =~ nodryrun ]]; then
    script['output']=$( eval ${command} )
  fi
}

# Function: print_info
#
# Print information

print_info () {
  info="$1"
  echo ""
  echo "Usage: ${script['bin']} --${info} [value]"
  echo ""
  echo "${info}(s):"
  echo "---------"
  while read line; do
    if [[ "${line}" =~ .*"# ${info}".* ]]; then
      if [[ "${info}" =~ option ]]; then
        IFS='-' read -r param desc <<< "${line}"
        IFS=']' read -r param default <<< ${param}
        IFS='[' read -r _ param <<< ${param}
        param="${param//\"/}"
        IFS='=' read -r _ default <<< ${default}
        default="${default//\"/}"
        default="${default// /}"
        param="${param} (default = ${default})"
      else
        IFS='#' read -r param desc <<< "${line}"
        desc="${desc/${info} -/}"
      fi
      echo "${param}"
      echo "  ${desc}"
    fi
  done < "${script['file']}"
  echo ""
}

# Function: print_help
#
# Print help/usage insformation

print_help () {
  print_info "switch"
}

# Function print_actions
#
# Print actions

print_actions () {
  print_info "action"
}

# Function: print_options
#
# Print options

print_options () {
  print_info "option"
}

# Function: print_usage
#
# Print Usage

print_usage () {
  usage="$1"
  case $usage in
    all|full)
      print_help
      print_actions
      print_options
      ;;
    help)
      print_help
      ;;
    action*)
      print_actions
      ;;
    option*)
      print_options
      ;;
    *)
      print_help
      shift
      ;;
  esac
}

# Function: print_version
#
# Print version information

print_version () {
  script['version']=$( grep '^# Version' < "$0" | awk '{print $3}' )
  echo "${script['version']}"
}

# Function: check_shellcheck
#
# Run Shellcheck

check_shellcheck () {
  bin_test=$( command -v shellcheck | grep -c shellcheck )
  if [ ! "$bin_test" = "0" ]; then
    shellcheck "${script['file']}"
  fi
}

# Do some early command line argument processing

if [ "${script['args']}" = "" ]; then
  print_help
  exit
fi

# Function: get_slack_webhook
#
# Get Slack webhook

get_slack_webhook () {
  if [ "${options['masked']}" = "true" ]; then
    slack['webhook']="https://hooks.slack.com/services/FOO/BAH"
  else
    if [ -z "${slack['webhook']}" ]; then
      if [ ! -z "${slack['webhookfile']}" ]; then
        if [ -f "${slack['webhookfile']}" ]; then
          slack['webhook']=$(<"${slack['webhookfile']}")
        fi
      fi
    fi
  fi
}

# Function: post_to_slack
#
# Post to Slack

post_to_slack () {
  get_slack_webhook
  if [ ! -z "${slack['webhook']}" ]; then
    install_package "curl"
    execute_command "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"${slack['message']}\"}' ${slack['webhook']}"
  else
    warning_message "No slack webhook given"
  fi
}


# Function: post_ups_status
#
# Post UPS status

post_ups_status () {
  get_ups_status
  if [ "${script['endpoint']}" = "slack" ]; then
    if [ -z "${slack['message']}" ]; then
      slack['message']="UPS status:"
    fi
    if [ ! -z "${script['location']}" ]; then
      slack['message']="${script['location']}"
    fi
    if [ ! -z "${slack['prefix']}" ]; then
      slack['message']="${slack['prefix']} ${slack['message']}"
    fi
    if [ -z "${ups['param']}" ]; then
      slack['message']="${slack['message']} ${ups['status']}"
    else
      slack['message']="${slack['message']} ${ups['param']} ${ups['status']}"
    fi
    post_to_slack
  fi
}

# Function: check_ups_status
#
# Check UPS status

check_ups_status () {
  get_ups_status
  if [ "${ups['status']}" = "${ups['value']}" ]; then
    message="OK ${ups['param']} is ${ups['value']}"
  else
    message="ERROR ${ups['param']} is not ${ups['value']}"
    if [ "${script['endpoint']}" = "slack" ]; then
      slack['message']="${message}"
      post_to_slack
    fi
  fi
  if [ "${script['endpoint']}" = "console" ]; then
    print_message "${message}" "verbose"
  fi
}

# Function: print_environment
#
# Print environment

print_environment () {
  echo "Environment (Options):"
  for option in "${!options[@]}"; do
    value="${options[${option}]}"
    echo -e "Option ${option}\tis set to ${value}"
  done
}

# Function: print_defaults
#
# Print defaults

print_defaults () {
  echo "Defaults:"
  for default in "${!defaults[@]}"; do
    value="${defaults[${default}]}"
    echo -e "Default ${default}\tis set to ${value}"
  done
}

# Function: process_actions
#
# Handle actions

install_package () {
  package="$1"
  package_version=""
  print_message "Package ${package}" "Checking"
  if [ "${os['name']}" = "Darwin" ]; then
    version=$( brew info "${package}" --json |jq -r ".[0].versions.stable" )
  else
    if [[ "${os['distro']}" =~ Arch ]] || [[ "${os['distro']}" =~ Endeavour ]]; then
      version=$( sudo pacman -Q "${package}" 2> /dev/null |awk '{print $2}' )
    else
      version=$( sudo dpkg -l "${package}" 2>&1 |grep "^ii" |awk '{print $3}' )
    fi
  fi
  print_message "${version}" "Version"
  if [ -z "${version}" ]; then
    if [ "${options['dryrun']}" = "false" ]; then
      print_message "# Installing package ${package}"
      if [ "${os['name']}" = "Darwin" ]; then
        brew update
        brew install "${package}"
      else
        if [[ "${os['distro']}" =~ "Arch" ]] || [[ "${os['distro']}" =~ "Endeavour" ]]; then
          sudo pacman -Sy
          echo Y |sudo pacman -Sy "${package}"
        else
          sudo apt update
          sudo apt install -y "${package}"
        fi
      fi
    fi
  fi
}

# Function: get_ups_name
#
# Get UPS name

get_ups_name () {
  if [ "${ups['name']}" = "" ]; then
    command="grep '^\[' ${ups['conf']} |tr -cd '[:alnum:]'" 
    execute_command "$command" "su"
    ups['name']="${script['output']}"
  fi
}

# Function: get_ups_status
#
# Get UPS status

get_ups_status () {
  get_ups_name
  command="upsc ${ups['name']} ${ups['param']} 2> /dev/null"
  execute_command "$command" "nodryrun"
  ups['status']="${script['output']}"
  if [ "${options['print']}" = "true" ]; then
    print_message "${ups['status']}" "verbose" 
  fi
}

# Function: add_ups
#
# Add UPS

add_ups () {
  get_ups
}

# Function: set_mode
#
# Set nut mode

set_mode () {
  get_mode
  old['mode']="${nut['mode']}"
  if [ ! "${old['mode']}" = "${new['mode']}" ]; then
    sudo sh -c "sed -i 's/^MODE.*/MODE=${new['mode']}/g' ${nut['conf']}"
  fi
}

# Function: get_mode
#
# Get nut mode

get_mode () {
  if [ -f "${nut['conf']}" ]; then
    nut['mode']=$( sudo sh -c "grep ^MODE ${nut['conf']} 2> /dev/null |cut -f2 -d=" )
    if [ -z "${nut['mode']}" ]; then
      echo "none"
    else
      echo "${nut['mode']}" 
    fi
  else
    warning_message "${nut['conf']} does not exist"
  fi
}

# Function: check_environment
#
# Check environment

check_environment () {
  for package in nut nut-client nut-server; do
    install_package "${package}"
  done
  get_mode
}

# Function: process_options
#
# Handle options

process_options () {
  option_flag="$1"
  if [[ "${option_flag}" =~ ^no ]]; then
    option_flag="${option_flag:2}"
    value="false"
  else
    value="true"
  fi
  options["${option_flag}"]="true"
  print_message "${option_flag} to ${value}" "set"
}

# Handle actions

process_actions () {
  actions="$1"
  case $actions in
    addups)                         # action - Add UPS
      add_ups
      ;;
    alertstatus|checkstatus)        # action - Get UPS info
      check_ups_status 
      ;;
    checkenv*)                      # action - Check environment
      check_environment
      ;;
    getmode)                        # action - Get mode
      get_mode 
      ;;
    getfullupsstatus|getfullstatus) # action - Get Full UPS status
      script['endpoint']="console"
      options['print']="true"
      ups['param']=""
      get_ups_status 
      ;;
    getupsinfo|getinfo)             # action - Get UPS info
      options['print']="true"
      get_ups_info 
      ;;
    getupsname|getname)             # action - Get UPS name
      get_ups_name 
      ;;
    getupsstatus|getstatus)         # action - Get UPS status
      script['endpoint']="console"
      options['print']="true"
      get_ups_status 
      ;;
    help)                           # action - Print actions help
      print_actions
      exit
      ;;
    version)                        # action - Print version
      print_version
      exit
      ;;
    postalertstatus)                # action - Get UPS info
      check_ups_status 
      ;;
    postupsstatus|poststatus)       # action - Post UPS status
      post_ups_status 
      ;;
    printenv*)                      # action - Print environment
      print_environment
      exit
      ;;
    printdefaults)                  # action - Print defaults
      print_defaults
      exit
      ;;
    setmode)                        # action - Set nut mode
      set_mode "${nut['mode']}"
      ;;
    slackalertstatus|slackalert)    # action - Post UPS status to slack
      script['endpoint']="slack"
      check_ups_status 
      ;;
    slackupsstatus|slackstatus)     # action - Post UPS status to slack
      script['endpoint']="slack"
      post_ups_status 
      ;;
    shellcheck)                     # action - Shellcheck script
      check_shellcheck
      exit
      ;;
    *)
      print_actions
      exit
      ;;
  esac
}

# Handle command line arguments

while test $# -gt 0; do
  case $1 in
    --action*)                        # switch - Action to perform
      check_value "$1" "$2"
      action_flags+=("$2")
      options["actions"]="true"
      shift 2
      ;;
    --debug)                          # switch - Enable debug mode
      options["debug"]="true"
      shift
      ;;
    --desc)                           # switch - UPS description
      check_value "$1" "$2"
      ups["desc"]="$2"
      shift 2
      ;;
    --driver)                         # switch - UPS driver
      check_value "$1" "$2"
      ups["driver"]="$2"
      shift 2
      ;;
    --endpoint)                       # switch - Post endpoint
      check_value "$1" "$2"
      script["endpoint"]="$2"
      shift 2
      ;;
    --force)                          # switch - Enable force mode
      options["force"]="true"
      shift
      ;;
    --hostname)                       # switch - Nuts mode
      check_value "$1" "$2"
      nut["hostname"]="$2"
      shift 2
      ;;
    --location)                       # switch - Location to prefix message with
      check_value "$1" "$2"
      script["location"]="$2"
      shift 2
      ;;
    --mode)                           # switch - Nuts mode
      check_value "$1" "$2"
      new["mode"]="$2"
      shift 2
      ;;
    --strict)                         # switch - Enable strict mode
      options["strict"]="true"
      shift
      ;;
    --verbose)                        # switch - Enable verbos e mode
      options["verbose"]="true"
      shift
      ;;
    --version|-V)                     # switch - Print version information
      print_version
      exit
      ;;
    --option*)                        # switch - Action to perform
      check_value "$1" "$2"
      option_flags+=("$2")
      options["options"]="true"
      shift 2
      ;;
    --param)                          # switch - UPS param to get
      check_value "$1" "$2"
      ups["param"]="$2"
      shift 2
      ;;
    --port)                           # switch - UPS port
      check_value "$1" "$2"
      ups["port"]="$2"
      shift 2
      ;;
    --productid)                      # switch - UPS product
      check_value "$1" "$2"
      ups["productid"]="$2"
      shift 2
      ;;
    --usage*)                         # switch - Action to perform
      check_value "$1" "$2"
      usage="$2"
      print_usage "${usage}"
      shift 2
      exit
      ;;
    --value)                          # switch - UPS value to check
      check_value "$1" "$2"
      ups["value"]="$2"
      shift 2
      ;;
    --webhook|--slackwebhook)         # switch - Slack webhook
      check_value "$1" "$2"
      slack["webhook"]="$2"
      shift 2
      ;;
    --webhookfile|--slackwebhookfile) # switch - Slack webhook file
      check_value "$1" "$2"
      slack["webhookfile"]="$2"
      shift 2
      ;;
    --help|-h)                        # switch - Print help information
      print_help
      shift
      exit
      ;;
    *)
      print_help
      shift
      exit
      ;;
  esac
done

if [ ! -s "${script['workdir']}" ]; then
  mkdir -p "${script['workdir']}"
fi

# Process options

if [ "${options['options']}" = "true" ]; then
  for option_flag in "${option_flags[@]}"; do
    if [[ "${option_flag}" =~ "," ]]; then
      IFS="," read -r -a array <<< "${option_flag}"
      for option in "${array[@]}"; do
        process_options "${option}"
      done
    else
      process_options "${option_flag}"
    fi
  done
fi

# Reset defaults based on switches

reset_defaults

# Process actions

if [ "${options['actions']}" = "true" ]; then
  for action_flag in "${action_flags[@]}"; do
    if [[ "${action_flag}" =~ "," ]]; then
      IFS="," read -r -a array <<< "${action_flag}"
      for action in "${array[@]}"; do
        process_actions "${action}"
      done
    else
      process_actions "${action_flag}"
    fi
  done
fi
