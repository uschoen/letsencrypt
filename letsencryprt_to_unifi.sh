#!/bin/bash

#Copyright 20202 Ullrich Schoen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a  copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations
# under the License. The domain for which acme.sh generated/generates a certificate
#
# 1)
# install acme.sh (as root)
#
# git clone https://github.com/Neilpang/acme.sh.git
# cd acme.sh/
# ./acme.sh --install \
#          --home /etc/acme \
#          --config-home /etc/acme/conf \
#          --cert-home /etc/acme/cert \
#          --accountemail "hi@acme.sh" \
#          --accountkey /etc/acme/conf/myaccount.key \
#          --accountconf /etc/acme/conf/myaccount.conf
#
#
# 2)
# add a crontap job
# crontap 
# 0 0 * * * "/home/user/.acme.sh"/acme.sh --cron --home "/home/user/.acme.sh" > /dev/null
#
# *)to uninstall acme.sh (as root)
#
# cd /root/acme.sh/
# ./acme.sh --uninstall
# rm -R /etc/acme



############## konfiguration ####
# enter the domain name
DOMAIN="free-wifi.test.de"

# keylength of the certificate
#
# KEYLENGTH=
#                       2048,
#                       3072,
#                       4096,
#                       8192
#                       ec-256,
#                       ec-384
#
KEYLENGTH=4069

# script Home
WORKDIR="/etc/acme"

# where ar store the certiface
CERT_HOME="/etc/acme/cert"

# your E-mail
MAIL="mail@test.de"

# Hetzer API Token
HETZNER_API_TOKEN="insert token"

# Logfile
LOGFILE="/var/log/acme.log"

# loglevel
# log level = 1|2
LOG_LEVEL=1

# DNS timeout
# The time in seconds to wait for all the txt records to propagate in dns api mode.
DNSSLEP=60


# !!!! STOP no change #####

export CF_Email=${MAIL}
export HETZNER_Token=${HETZNER_API_TOKEN}

# Find out what user we are
CURRENT_USER="$(whoami)";
echo "current user is : ${CURRENT_USER}";


# backup log
if [ -d "${LOGFILE}"]; then
	echo "remove old logfile: ${LOGFILE}";
	rm (${LOGFILE});
fi

# request a new certifikate

#
# ceck if certificate location specified
#
if [ -d "${CERT_HOME}/${DOMAIN}/" ]; then
        echo "request a new cerficate for ${DOMAIN}, no dir ${CERT_HOME}/${DOMAIN}";
        XX= ${WORKDIR}/acme.sh  --dnssleep  ${DNSSLEP} \
                --log ${LOGFILE} \
                --log-level ${LOG_LEVEL} \
                --renew \
                --dns dns_hetzner \
                -d ${DOMAIN} \
                --keylength ${KEYLENGTH}
else
        echo "found dir ${CERT_HOME}/${DOMAIN}, renew cerficate";
        XX= ${WORKDIR}/acme.sh --dnssleep  ${DNSSLEP} \
                --log ${LOGFILE} \
                --log-level ${LOG_LEVEL} \
				--issue \
                --dns dns_hetzner \
                -d ${DOMAIN} \
                --keylength ${KEYLENGTH}
fi
printf '%s\n' "$XX"

if [[ $XX == *"Skip"* ]]; then
    echo "finish no new certificate";
	exit 1
fi


echo "finish request. Store request in ${CERT_HOME}/${DOMAIN}";

# convert certifikate

echo "* Creating PKCS12 keystore... in ${WORKDIR}/${DOMAIN}";
openssl pkcs12 -export -passout pass:aircontrolenterprise \
 -in "${CERT_HOME}/${DOMAIN}/${DOMAIN}.cer" \
 -inkey "${CERT_HOME}/${DOMAIN}/${DOMAIN}.key" \
 -out "${CERT_HOME}/${DOMAIN}/keystore.pkcs12" -name unifi \
 -CAfile "${CERT_HOME}/${DOMAIN}/fullchain.cer" -caname root


#stop unifi controller
echo "* Stopping UniFi Controller...";
systemctl stop unifi

# make backup from keystore
mv /var/lib/unifi/keystore /var/lib/unifi/keystore.backup

# import certificate to unifi controler
echo "copy new PKCS12 file in ${CERT_HOME}/${DOMAIN}/keystore.pkcs12";
keytool -noprompt -trustcacerts -deststorepass aircontrolenterprise -importkeystore  \
 -destkeypass aircontrolenterprise -destkeystore /usr/lib/unifi/data/keystore \
 -srckeystore "${CERT_HOME}/${DOMAIN}/keystore.pkcs12" -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -alias unifi

#start unifi controller
echo "* Starting UniFi Controller...";
systemctl start unifi

echo "finish";
exit 1;
 
