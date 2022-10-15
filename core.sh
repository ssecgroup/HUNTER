#!/usr/bin/env bash

HISTCONTROL=erasedups
dns_server=8.8.8.8

header() {
  echo "${1}" #-e "${blue}${1}${end}"
}

records() {
  if [[ -n "${1}" ]]; then
    echo "${1}" #-e "${darkyellow}${1}${end}"
  fi
}

ipinfo_records() {
  if [[ -n "${1}" ]]; then
    echo "${1}" #-e "${lightred}${1}${end}"
  fi
}

yellow() {
  echo "${1}" #-e "${yellow}${1}${end}"
}

red() {
  echo -e "${1}\n" #-e "${red}${1}${end}\n"
}

check_valid_ip() {
  grep -oE "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])"
}

check_ptr() {
  if [[ -n "${1}" ]]; then
    local ptr
    echo "${1}" | check_valid_ip | while read -r ptr; do
      dig -4 +noall +answer -x "${ptr}" @"${dns_server}"
    done
  fi
}

ipinfo_org_only() {
  if [[ -n "${1}" ]]; then
    local ipinfo
    echo "${1}" | check_valid_ip | while read -r ipinfo; do
      curl -4s ipinfo.io/"${ipinfo}" | grep "\"org\":" | xargs | sed 's/.$//'
    done
  fi
}

dig_short() {
  dig -4 +short @"${dns_server}" "${1}" "${2}" 2>&1 | grep -v "empty label" | sort -h
}

check_hostname() {
  local hostnamedotcount roothostname ns_record a_record mx_record mail_record webmail_record txt_record ptr_a_record ptr_mail_record ptr_webmail_record ipinfo_a_record ipinfo_mail_record ipinfo_webmail_record
  # Checking for root hostname without subdomain
  hostnamedotcount=$(echo "${1}" | grep -o "\." | wc -l)
  roothostname="${1}"
  if [[ ${hostnamedotcount} -gt 1 ]]; then
    roothostname=$(echo "${1}" | cut -d'.' -f"${hostnamedotcount}"-)
    if [[ ${#roothostname} == 6 ]] && [[ ${roothostname:0:3} =~ com|org|net|int|edu|gov|mil|biz ]]; then
      roothostname=$(echo "${1}" | cut -d'.' -f"$(("${hostnamedotcount}" - 1))"-)
    fi
  fi
  # GATHERING INFO
  ns_record=$(dig_short NS "${roothostname}")
  a_record=$(dig_short A "${1}")
  mx_record=$(dig_short MX "${1}")
  mail_record=$(dig_short A "mail.${1}")
  webmail_record=$(dig_short A "webmail.${1}")
  txt_record=$(dig_short TXT "${1}")
  # Error If No Info Found
  if [[ -z ${ns_record} ]] && [[ -z ${a_record} ]] && [[ -z ${mx_record} ]] && [[ -z ${mail_record} ]] && [[ -z ${webmail_record} ]] && [[ -z ${txt_record} ]]; then
    # history -d "$(history 1 | awk '{print $1}')" - Uncomment to delete the last invalid entry from history
    red "Please Input Valid IP / Hostname... or Domain ${1} Not Found or No DNS Records"
    return
  fi
  ptr_a_record=$(check_ptr "${a_record}")
  ptr_mail_record=$(check_ptr "${mail_record}")
  ptr_webmail_record=$(check_ptr "${webmail_record}")
  ipinfo_a_record=$(ipinfo_org_only "${a_record}")
  ipinfo_mail_record=$(ipinfo_org_only "${mail_record}")
  ipinfo_webmail_record=$(ipinfo_org_only "${webmail_record}")
  # OUTPUT BELOW
  echo
  header "NS record for ${roothostname}"
  records "${ns_record}"
  echo
  header "A record for ${1}"
  records "${a_record}"
  records "${ptr_a_record}"
  ipinfo_records "${ipinfo_a_record}"
  echo
  header "MX record for ${1}"
  records "${mx_record}"
  echo
  header "A record for mail.${1}"
  records "${mail_record}"
  records "${ptr_mail_record}"
  ipinfo_records "${ipinfo_mail_record}"
  echo
  header "A record for webmail.${1}"
  records "${webmail_record}"
  records "${ptr_webmail_record}"
  ipinfo_records "${ipinfo_webmail_record}"
  echo
  header "TXT record for ${1}"
  records "${txt_record}"
 echo 
 
  echo "NS record for : ${roothostname}">temp.txt
  echo "records : ${ns_record}">temp.txt
echo
  echo  "A record for : ${1}">temp.txt
  echo  "records : ${a_record}">temp.txt
  echo " PTR RECORD : ${ptr_a_record}">temp.txt
  echo "ipinfo_records : ${ipinfo_a_record}">temp.txt

  echo  "MX record for : ${1}">temp.txt
  echo  "Mx Record : ${mx_record}">temp.txt
  
  echo  "A record for mail: ${1}">temp.txt
  echo  "Mail records : ${mail_record}">temp.txt
  echo " PTR MAIL RECORD : ${ptr_mail_record}">temp.txt
  echo " ipinfo_records : ${ipinfo_mail_record}">temp.txt
 
  echo  "A record for webmail: ${1}">temp.txt
  echo  "WEBMAIL RECORD : ${webmail_record}">temp.txt
  echo "PTR-WEB-MAIL-RECORD : ${ptr_webmail_record}">temp.txt
  echo "ipinfo_records: ${ipinfo_webmail_record}">temp.txt
 
  echo  "TXT record for: ${1}">temp.txt
  echo  " TXT records: ${txt_record}">temp.txt
  

echo
echo -e "\e[1;34mMAKE SURE YOU INSTALL nmap \e[0m"
# just some url
 
curl ${a_record} -I -o headers -s
# download file
cat headers
nmap  -p 1-1000 ${a_record} -A
echo

echo -e "\e[1;34mMAKE SURE YOU INSTALL wafw00f \e[0m"
# just some url
 
wafw00f ${a_record} 
# download file
echo
echo

echo -e "\e[1;34m if any update need for  HUNTER. feel free to mail ssecgroup08@gmail.com \e[0m"

echo
echo 

echo  -e "\e[1;34m BYE!!!!!!! \e[0m" 

echo
echo

exit 0
}

check_ip() {
  local ptr_a_record ipinfo_a_record
  # GATHERING INFO
  ptr_a_record=$(check_ptr "${1}")
  ipinfo_a_record=$(curl -4s "ipinfo.io/${1}" | sed 's/\"/ /g')
  # OUTPUT BELOW
  echo
  header "PTR and IPInfo for ${1}"
  records "${ptr_a_record}"
  ipinfo_records "${ipinfo_a_record}"
  echo
}

additional_functions() {
  if [[ ${1} == "?" ]]; then
    echo -e "\nFunctions Available :\n  pmp - Today's PMP Code\n  pass - Password Generator ( 16 Characters - 5x )\n  ip - Your Current Public IP\n  whois <domainname> - WHOIS info for the domain\n"
  elif [[ ${1} == "pmp" ]]; then
    echo -e "\n$(curl -4s pmp.matrixevo.com)\n"
  elif [[ ${1} == "pass" ]]; then
    echo -e "\n$(tr -dc 'a-zA-Z0-9#$' < /dev/urandom | tr -d 'iI1lLoO0' | tr -s 'a-zA-Z0-9#$' | fold -w "16" | head -n "5")\n"
  elif [[ ${1} == "ip" ]]; then
    echo -e "\n$(curl -4s ip.matrixevo.com)\n"
  elif [[ ${1} =~ ^"whois " ]]; then
    if [[ ! "$(command -v whois)" ]]; then
      echo "whois not found... attempting to install..."
      sudo apt install whois -y
    fi
    local temp
    temp=$(whois "$(awk '{print $2}' <<< "${1}")" | grep -v "   ")
    echo -e "\n$(grep "Domain Name:" <<< "${temp}")\n$(grep "Registrar" <<< "${temp}" | grep -v "Registrars." | sort -h)\n$(grep "Date:" <<< "${temp}" | sort -h)\n$(grep "Name Server:" <<< "${temp}" | sort -h)\n"
  fi
}

filter() {
  if [[ ${1} == "?" ]] || [[ ${1} == "pmp" ]] || [[ ${1} == "pass" ]] || [[ ${1} == "ip" ]] || [[ ${1} =~ ^"whois " ]]; then
    history -s "${1}"
    additional_functions "${1}"
    return
  fi

  local ip hostname
  ip=$(echo "${1}" | check_valid_ip | head -n1)
  hostname=$(echo "${1}" | tr '[:upper:]' '[:lower:]' | cut -d'@' -f2 | tr -c '0-9a-z._\-' '\n' | grep "\." | head -n1 )

  if [[ -z ${ip} ]] && [[ -z ${hostname} ]] || [[ ${#hostname} -le 3 ]] || [[ -z $(echo "${hostname}" | cut -d'.' -f1) ]] || [[ -z $(echo "${hostname}" | cut -d'.' -f2) ]];then
    red "Please Input Valid IP / Hostname..."
  elif [[ -n ${ip} ]]; then
    history -s "${ip}"
    check_ip "${ip}"
  elif [[ -n ${hostname} ]] ; then
    if [[ ${hostname: -1} == "." ]]; then
      hostname="${hostname%?}"
    fi
    history -s "${hostname}"
    check_hostname "${hostname}"
  fi
}
start() {
  local user_input
  if [[ $1 ]]; then
    filter "${1}"
  else
    while IFS= read -rep "$(yellow "Input IP / Hostname : ")" user_input </dev/tty ; do
      filter "${user_input}"
    done
  fi
}
start "${1}"

echo "exit $?"
