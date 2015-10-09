#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME targetIp targetPort
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery, S.L. http://www.acm-sl.com
    Distributed under the terms of the GNU General Public License v3

Finds out the IPs which are allowed to connect to a certain IP-port combination.

Where:
    - targetIp: The target IP.
    - targetPort: The target port.
Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Declares the requirements.
## dry-wit hook
function checkRequirements() {
  checkReq netcat GNU_NETCAT_NOT_AVAILABLE;
  checkReq ifconfig IFCONFIG_NOT_AVAILABLE;
  checkReq grep GREP_NOT_AVAILABLE;
  checkReq bc BC_NOT_AVAILABLE;
  checkReq cut CUT_NOT_AVAILABLE;
  checkReq ping PING_NOT_AVAILABLE;
  checkReq sudo SUDO_NOT_AVAILABLE;
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export GNU_NETCAT_NOT_AVAILABLE="netcat not found";
  export IFCONFIG_NOT_AVAILABLE="ifconfig not found";
  export GREP_NOT_AVAILABLE="grep not found";
  export AWK_NOT_AVAILABLE="awk not found";
  export BC_NOT_AVAILABLE="bc not found";
  export CUT_NOT_AVAILABLE="cut not found";
  export PING_NOT_AVAILABLE="ping not found";
  export SUDO_NOT_AVAILABLE="sudo not found";
  export TARGET_IP_IS_MANDATORY="targetIP is mandatory";
  export TARGET_PORT_IS_MANDATORY="targetPort is mandatory";
  export NETWORK_INTERFACE_IS_DOWN="${NETWORK_INTERFACE} is down";
  export NO_SOURCE_IP_FOUND="No source IP found";
  
  ERROR_MESSAGES=(\
    NO_SOURCE_IP_FOUND \
    INVALID_OPTION \
    GNU_NETCAT_NOT_AVAILABLE \
    IFCONFIG_NOT_AVAILABLE \
    GREP_NOT_AVAILABLE \
    AWK_NOT_AVAILABLE \
    BC_NOT_AVAILABLE \
    CUT_NOT_AVAILABLE \
    PING_NOT_AVAILABLE \
    TARGET_IP_IS_MANDATORY \
    TARGET_PORT_IS_MANDATORY \
    NETWORK_INTERFACE_IS_DOWN \
  );

  export ERROR_MESSAGES;
}

## Validates the input.
## dry-wit hook
function checkInput() {

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;
  logDebug -n "Checking input";

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q | --quiet)
         shift;
         ;;
      *) logDebugResult FAILURE "failed";
         exitWithErrorCode INVALID_OPTION;
         ;;
    esac
  done

  if [ -z ${TARGET_IP} ]; then
      if [ -z ${1} ]; then
      exitWithErrorCode TARGET_IP_IS_MANDATORY;
    else
      shift;
    fi
  fi

  if [ -z ${TARGET_PORT} ]; then
    if [ -z ${1} ]; then
      exitWithErrorCode TARGET_PORT_IS_MANDATORY;
    fi
  fi

  logDebugResult SUCCESS "done";
}

## Parses the input
## dry-wit hook
function parseInput() {

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q | --quiet)
         shift;
         ;;
    esac
  done

  if [ -z ${TARGET_IP} ]; then
    TARGET_IP="${1}";
    shift;
  fi

  if [ -z ${TARGET_PORT} ]; then
    TARGET_PORT="${1}";
    shift;
  fi
}

## Retrieves the IP of given interface.
## -> 1: The network interface.
## <- RESULT: the IP.
## <- 0 if the interface is up; 1 otherwise.
## Example:
##  if retrieve_ip_for_network_interface eth0; then
##    echo "IP for eth0 is ${RESULT}";
##  else
##    echo "eth0 is not up"
##  fi
function retrieve_ip_for_network_interface() {
  local _eth="${1}";
  local _result;
  local _rescode;
  logDebug -n "Retrieving IP for ${_eth}";
  ifconfig ${_eth} 2>&1 | grep netmask > /dev/null;
  _rescode=$?;
  _result="$(ifconfig ${_eth} | grep netmask | awk '{print $2;}')";
  if [ ${_rescode} -eq 0 ]; then
    logDebugResult SUCCESS "${_result}";
  else
    logDebugResult FAILURE "failed";
  fi
  export RESULT="${_result}";
  return ${_rescode};
}

## Retrieves the first IP for given IP range and netmask.
## -> 1: The IP range.
## -> 2: The netmask.
## <- RESULT: the first IP.
## Example:
##  if retrieve_first_ip_for_ip_range_and_netmask 10.0.0.0 255.255.255.0; then
##    echo "First IP for 10.0.0.0/24 is ${RESULT}";
##  else
##    echo "eth0 is not up"
##  fi
function retrieve_first_ip_for_ip_and_netmask() {
  local _ip="${1}";
  local _netmask="${2}";
  local _ipBlocks=(${_ip//./ });
  local _netmaskBlocks=(${_netmask//./ });
  local _aux=();
  local _result;
  for i in 0 1 2 3; do
      _aux[${i}]=$((${_ipBlocks[${i}]} & ${_netmaskBlocks[${i}]}));
  done
  _aux[$((${#_aux[@]}-1))]="$((${_aux[${#_aux[@]}-1]}+1))";
  _result="${_aux[@]}";
  _result="${_result// /.}";
  export RESULT="${_result}";
}

## Retrieves the last IP for given IP range and netmask.
## -> 1: The IP range.
## -> 2: The netmask.
## <- RESULT: the first IP.
## Example:
##  if retrieve_last_ip_for_ip_range_and_netmask 10.0.0.0 24; then
##    echo "Last IP for 10.0.0.0/24 is ${RESULT}";
##  else
##    echo "eth0 is not up"
##  fi
function retrieve_last_ip_for_ip_and_netmask() {
  local _ip="${1}";
  local _netmask="${2}";
  local _ipBlocks=(${_ip//./ });
  local _netmaskBlocks=(${_netmask//./ });
  local _negatedMaskBlock;
  local _aux=();
  local _last;
  local _result;
  for i in $(seq 0 3); do
    _negatedNetmaskBlock=$((255-${_netmaskBlocks[${i}]}));
    _aux[${i}]=$((${_ipBlocks[${i}]} | ${_negatedNetmaskBlock}));
  done
  _aux[$((${#_aux[@]}-1))]="$((${_aux[${#_aux[@]}-1]}-1))";
  _result="${_aux[@]}";
  export RESULT="${_result// /.}";
}

## Retrieves the netmask of given interface.
## -> 1: The network interface.
## <- RESULT: The netmask.
## Example:
##   if retrieve_netmask_for_network_interface eth0; then
##     echo "Netmask for eth0 is ${RESULT}";
##   else
##     echo "eth0 is not up";
##   fi
function retrieve_netmask_for_network_interface() {
  local _eth="${1}";
  local _result;
  local _rescode;
  logDebug -n "Retrieving netmask for ${_eth}";
  ifconfig ${_eth} 2>&1 | grep netmask > /dev/null;
  _rescode=$?;
  _result="$(ifconfig ${_eth} | grep netmask | awk '{print $4;}')";
  if [ ${_rescode} -eq 0 ]; then
    logDebugResult SUCCESS "${_result}";
  else
    logDebugResult FAILURE "failed";
  fi
  export RESULT="${_result}";
  return ${_rescode};  
}

## Copied from
## http://stackoverflow.com/questions/10278513/bash-shell-decimal-to-binary-conversion
## Converts given integer value to another base.
## -> 1: The value to convert.
## -> 2: The base;
## <- RESULT: The base value.
## Example
##   convert_integer_to_base 33 16
##   echo "33 in base 16 is ${RESULT}"
function convert_integer_to_base()
{
   _val=$1;
   _base=$2;
   _result="";
   if [ "x${_val}" == "x0" ]; then
     _result=0;
   else
     while [ ${_val} -ne 0 ] ; do
        _result=$(( ${_val} % ${_base} ))${_result} #residual is next digit
        _val=$(( ${_val} / ${_base} ))
     done;
   fi
   export RESULT="${_result}";
}

## Converts given IP to binary.
## -> 1: The IP to convert.
## <- RESULT: The binary.
## Example
##   convert_ip_to_binary 10.0.0.1;
##   echo "10.0.0.1 in binary is ${RESULT}";
function convert_ip_to_binary() {
  local _ip="${1}";
  local _result="";
  for i in ${_ip//\./ }; do
      _result="${_result}$(echo "obase=2;$i" | bc | awk '{printf("%08d\n", $0);'})";
  done
  export RESULT="${_result}";
}

## Converts given binary to IP.
## -> 1: The binary value.
## <- RESULT: The IP.
## Example
##   convert_binary_to_ip "1111001110101010111100101110000";
##   echo "1111001110101010111100101110000 corresponds to IP ${RESULT}";
function convert_binary_to_ip() {
  local _binary="${1}";
  convert_binary_to_decimal "${_binary}";
  local _decimal="${RESULT}";
  local _result="";
  local _aux;
  local _shifts=(24 16 8 0);
  local _masks=(4278190080 16711680 65280 255);
  for _i in $(seq 0 3); do
    _aux="$((${_decimal} & ${_masks[${_i}]}))";
    _result="${_result}.$((${_aux} >> ${_shifts[${_i}]}))";
  done
  export RESULT="${_result#\.}";
}

## Converts given binary to decimal.
## -> 1: The binary value.
## <- RESULT: The decimal value.
## Example
##   convert_binary_to_decimal 11110110;
##   echo "The decimal value for 11110110 is ${RESULT}";
function convert_binary_to_decimal() {
  local _binary="${1}";
  local _result="$(echo "ibase=2;${_binary}" | bc)";
  export RESULT="${_result}";
}

## Converts given decimal to binary.
## -> 1: The decimal value.
## <- RESULT: The binary value.
## Example
##   convert_decimal_to_binary 311357;
##   echo "The binary value for 311357 is ${RESULT}";
function convert_decimal_to_binary() {
  local _decimal="${1}";
  convert_integer_to_base ${_decimal} 2;
}

## Builds a list of all IPs in between.
## -> 1: The first IP.
## -> 2: The second IP.
## <- RESULT: The list of IPs.
## Example:
##   build_ip_list 10.0.0.1 10.0.0.3
##   echo "IPs -> ${RESULT}";
function build_ip_list() {
  local _first="${1}";
  local _last="${2}";
  local _result=("");
  local _firstBinary;
  local _lastBinary;
  local _firstDecimal;
  local _lastDecimal;
  local _currentIp;
  local _j=0;
  convert_ip_to_binary "${_first}";
  _firstBinary="${RESULT}";
  convert_ip_to_binary "${_last}";
  _lastBinary="${RESULT}";
  convert_binary_to_decimal "${_firstBinary}";
  _firstDecimal="${RESULT}";
  convert_binary_to_decimal "${_lastBinary}";
  _lastDecimal="${RESULT}";
  for i in $(seq ${_firstDecimal} ${_lastDecimal}); do
    convert_decimal_to_binary "${i}";
    convert_binary_to_ip "${RESULT}";
    _currentIp="${RESULT}";
    _result[$((_j++))]="${_currentIp}";
  done
  # TODO: Find out why ${_result[0]} becomes ${_firstBinary}
  _result[0]="${_first}";
  export RESULT="${_result[*]}";
}

## Retrieves the source IPs.
## -> 1: The network interface.
## <- RESULT: The list of valid IPs.
## Example:
##   retrieve_source_ip_list eth0;
##   echo "The list of IPs in eth0's IP range is: ${RESULT// /,/}"
function retrieve_source_ip_list() {
  local _eth="${1}";
  local _ownIp;
  local _netmask;
  local _result;
  if retrieve_ip_for_network_interface "${_eth}"; then
      _ownIp="${RESULT}";
      if retrieve_netmask_for_network_interface "${_eth}"; then
          _netmask="${RESULT}";
          retrieve_first_ip_for_ip_and_netmask "${_ownIp}" "${_netmask}";
          _firstIp="${RESULT}";
          retrieve_last_ip_for_ip_and_netmask "${_ownIp}" "${_netmask}";
          _lastIp="${RESULT}";
          build_ip_list "${_firstIp}" "${_lastIp}";
          _result="${RESULT}";
      else
          exitWithErrorCode NETWORK_INTERFACE_IS_DOWN;
      fi
  else
    exitWithErrorCode NETWORK_INTERFACE_IS_DOWN;
  fi
  export RESULT="${_result}";
}

## Checks whether given IP is already used.
## -> 1: The IP to check.
## -> 2: The interface to use.
## <- 0 if used; 1 otherwise.
## Example
##   if is_ip_already_used "10.0.0.33"; then
##     echo "10.0.0.33 is already used";
function is_ip_already_used() {
  local _ip="${1}";
  local _iface="${2}";
  local _rescode;
  logDebug -n "Checking if ${_ip} is already used";
  ping -W ${TIMEOUT} -c 1 -I ${_iface} ${_ip} 2>&1 > /dev/null;
  _rescode=$?;
  if [ ${_rescode} -eq 0 ]; then
    logDebugResult FAILURE "used";
  else
    logDebugResult SUCCESS "unused";
  fi
  return ${_rescode};
}

## Creates a network alias for given IP.
## -> 1: The network interface.
## -> 2: The virtual IP.
## <- 0 if the virtual interface could be set up; 1 otherwise.
## Example
##   if ! create_network_alias_for_ip eth0 10.0.0.15; then
##     echo "Could not create network alias";
function create_network_alias_for_ip() {
    local _iface="${1}";
    local _ip="${2}";
    local _name="${_iface}:${_ip//\./_}";
    local _logFile;
    local _result;
    local _rescode;
    createTempFile;
    _logFile="${RESULT}";
    logTrace -n "Adding ${_name} interface for IP ${_ip}";
    sudo ifconfig ${_name} ${_ip} 2>&1 > "${_logFile}";
    _rescode=$?;
    if [ ${_rescode} -eq 0 ]; then
        logTraceResult SUCCESS "done";
        _result="${_name}";
        export RESULT="${_result}";
    else
        logTraceResult FAILURE "failed";
        logTraceFile "${_logFile}";
    fi
    return ${_rescode};
}

## Creates a network alias for given IP.
## -> 1: The network interface.
## -> 2: The virtual IP.
## <- 0 if the virtual interface could be set up; 1 otherwise.
## Example
##   if ! delete_network_alias_for_ip eth0 10.0.0.15; then
##     echo "Could not delete network alias";
function delete_network_alias_for_ip() {
    local _iface="${1}";
    local _ip="${2}";
    local _name="${_iface}:${_ip//\./_}";
    local _rescode;
    logTrace -n "Removing ${_name} interface, for IP ${_ip}";
    sudo ifconfig ${_name} down 2>&1 > /dev/null;
    _rescode=$?;
    if [ ${_rescode} -eq 0 ]; then
        logTraceResult SUCCESS "done";
    else
        logTraceResult FAILURE "failed";
    fi
    return ${_rescode};
}

## Checks whether the target is reachable.
## -> 1: The source IP.
## -> 2: The target IP.
## -> 3: The target port.
## <- 0 if it's reachable; 1 otherwise.
## Example
##   if target_reachable 10.0.4.100 10.0.4.1 80; then
##     echo "10.0.4.1:80 within reach"
function target_reachable() {
    local _sourceIp="${1}";
    local _targetIp="${2}";
    local _targetPort="${3}";
    local _rescode;
    logInfo -n "Attempting to connect to ${_targetIp}:${_targetPort} from ${_sourceIp}";
    netcat -w ${TIMEOUT} -s ${_sourceIp} ${_targetIp} ${_targetPort} 2>&1 > /dev/null;
    _rescode=$?;
    if [ ${_rescode} -eq 0 ]; then
        logInfoResult SUCCESS "worked";
    else
        logInfoResult FAILURE "failed";
    fi
    return ${_rescode};
}

## Attempts to connect to given target IP:port from a source IP.
## -> 1: The source IP.
## -> 2: The network interface.
## -> 3: The target IP.
## -> 4: The target port.
## <- 0 if the connection succeeds; 1 otherwise.
## Example
##    if attempt_connection 10.0.0.33 eth0 10.0.0.254 80; then
##      echo "Connection succeed"
function attempt_connection() {
    local _ip="${1}";
    local _eth="${2}";
    local _targetIp="${3}";
    local _targetPort="${4}";
    local _iface;
    local _rescode;
    if create_network_alias_for_ip "${_eth}" "${_ip}"; then
        _iface="${RESULT}";
        target_reachable "${_ip}" "${_targetIp}" "${_targetPort}";
        _rescode=$?;
        delete_network_alias_for_ip "${_iface}" "${_ip}"
    else
        _rescode=1;
    fi
    return ${_rescode};
}

## Main logic
## dry-wit hook
function main() {
  local _sourceIPs;
  local _usedIPs=();
  local _failedIPs=();
  logInfo "Retrieving IPs to test...";
  retrieve_source_ip_list "${NETWORK_INTERFACE}";
  _sourceIPs="${RESULT}";
  for _ip in ${_sourceIPs}; do
    if [ "x${_ip}" != "x${TARGET_IP}" ]; then
      if is_ip_already_used ${_ip} ${NETWORK_INTERFACE}; then
        _usedIPs[${#_usedIPs}]="${_ip}";
      else
        if attempt_connection "${_ip}" ${NETWORK_INTERFACE} "${TARGET_IP}" "${TARGET_PORT}"; then
          logInfo -n "Granted IP found!";
          logInfoResult SUCCESS "${_ip}";
          break;
        else
          _failedIPs[${#_failedIPs}]="${_ip}";
        fi
      fi
    fi
  done
  logInfo -n "Number of IPs already used";
  logInfoResult SUCCESS "${#_usedIPs}";
  logDebug "IPs already used:";
  logDebug "${_usedIPs[@]}";
  logInfo -n "IPs attempted";
  logInfoResult SUCCESS "${#_failedIPs}";
  logDebug "IPs failed:";
  logDebug "${_failedIPs[@]}";
  exitWithErrorCode NO_SOURCE_IP_FOUND;
}
