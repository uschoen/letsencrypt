# letsencrypt
A script to create or renew a letsencrypt crtificate for a UniFi [Ubiquiti] wifi ontroller on a rasperry pi (use DNS for letsencrypt)

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
