# Zabbix Template for PingCastle Reporting

# What is PingCastle
[Ping Castle](https://www.pingcastle.com/) is a tool designed to assess quickly the Active Directory security level with a methodology based on risk assessment and a maturity framework. It does not aim at a perfect evaluation but rather as an efficiency compromise.

# What is Zabbix Template for PingCastle Reporting
This is a template for collecting high level overview of the status reported by PingCastle. It is intended as basis for C-level reporting dashboard. It includes the most important metrics (scores in PingCastle terminology).

Here you can find the template itself and a sample bash script [`process.sh`](process.sh) for parsing reports and sending to Zabbix.

# How is this template Designed
The template is designed with Zabbix [Trapper](https://www.Zabbix.com/documentation/current/en/manual/config/items/itemtypes/trapper) items. This choice is dictated by the fact that AD scanning by pingcastle is performed on a machine separate from the Zabbix server/agent/proxy and then possibly processed on another machine.

It is possible to operate with regular items but this is not easily coordinated on a general basis and needs tuning.

## What is monitored
Currently only key indicators are monitored

| Item | Key | Description |
| ---- | --- | ----------- |
| Engine Version | pingcastle.EngineVersion | Version of the PingCastle tool used to generate the report |
| Latest Version | pingcastle.EngineVersionLatest | Latest Version of the PingCastle (extracted from Github releases) |
| GlobalScore | pingcastle.GlobalScore | Max of all other scores |
| PrivilegiedGroupScore | pingcastle.PrivilegiedGroupScore | Score about privileges
| StaleObjectsScore | pingcastle.StaleObjectsScore | Score about stale objects |
| TrustScore | pingcastle.TrustScore | Score about trusted domains and issues therein |
| AnomalyScore | pingcastle.AnomalyScore | Anomalies not fitting in any of the rest |
| DomainAdministrators | pingcastle.DomainAdministrators | Number of Domain Administrators |
| TotalRiskPoints | pingcastle.TotalRiskPoints | Sum of all matched RiskRule's ponts |

## Available Triggers
For every score (Global, Privileged, Stale, Trust, Anomaly) there are 4 triggers according to PingCastle documentation

 * 0 - no risk identified but some improvements detected
 * between 1 and 10 - a few actions have been identified
 * between 10 and 30 - rules should be looked with attention
 * score higher than 30 - major risks identified

Macros have been provided to tune the thresholds per host

For Domain Administrators there is a single non recovering trigger that fires on change. The event must be manually acknoleged and closed.

There is also a trigger for stale data.

## Available Macros

| Macros | Default | Description |
| ------ | ------- | ----------- |
| `{$PINGCASTLE_NODATA_DAYS}`       | 21d |Threshold to alert if no data received for XX days (default 21d) |
| `{$PINGCASTLE_THRESHOLD_WARNING}` | 10  | Threshold for firing warning trigger (default 10) |
| `{$PINGCASTLE_THRESHOLD_AVERAGE}` | 30  | Threshold for firing average trigger (default 30) |
| `{$PINGCASTLE_THRESHOLD_HIGH}`    | 50  | Threshold for firing high trigger (default 50) |

## How to Use

 * Import Template into Zabbix (will go in `Templates/PingCastle` group)
 * Create a host with `DomainSID` as hostname. Use any custom nice looking name in the display name field
 * Make sure you have `zabbix_send` and xmllint installed on the machine doing the processing
 * Run [`process.sh`](process.sh)

# `process.sh`
A sample [`process.sh`](process.sh) bash script is included for parsing the Pingcastle reports and submitting them to Zabbix.

## Requirements
`process.sh` - requires as a minimum `xmllint` from `libxml2-utils`, `zabbix_send` and `awk`

# Questions / Issues / Others
Feel free to use the issues system for requests and others
