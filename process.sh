#!/usr/bin/env bash
#
# Sample script to process pingcastle reports
#

#set -x

# Variables
_ZABBIX_SERVER='zabbix.example.com'

_scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
_workdir=$(mktemp -d)
_inputfile=$1
_processstamp=$(date '+%F_%R')

function cleanup() {
	rm -rf "${_workdir}"
}

trap cleanup ERR EXIT SIGINT SIGHUP SIGQUIT SIGTERM

# Get some nice stuff around the domain
# descriptive info
_domain_name=$(xmllint --xpath '/HealthcheckData/DomainFQDN/text()' "${_inputfile}")
_domain_sid=$(xmllint --xpath '/HealthcheckData/DomainSid/text()' "${_inputfile}")

# timestamp when the report was generated (for zabbix trapper)
_t=$(xmllint --xpath '/HealthcheckData/GenerationDate/text()' "${_inputfile}")
_unixtimestamp=$(date -d "${_t}" +%s)

for _key in EngineVersion GlobalScore StaleObjectsScore PrivilegiedGroupScore TrustScore AnomalyScore ; do
	echo "${_domain_sid}" pingcastle."${_key}" "${_unixtimestamp}" "$(xmllint \
		--xpath "/HealthcheckData/${_key}/text()" \
		"${_inputfile}")" >> "${_workdir}"/zabbix_data
done

echo "${_domain_sid}" pingcastle.PrivilegiedGroups.DomainAdministrators "${_unixtimestamp}" "$(xmllint \
	--xpath '/HealthcheckData/PrivilegedGroups/HealthCheckGroupData/GroupName[contains(text(),"Domain Administrators")]/following-sibling::NumberOfMemberEnabled/text()' \
	"${_inputfile}")" >> "${_workdir}"/zabbix_data

zabbix_sender -z "${_ZABBIX_SERVER}" -T -i "${_workdir}"/zabbix_data
