#!/bin/bash
# Send metrics to opentsdb on cassini.fgci.csc.fi
#
# We use these to build a dashboard showing the status and runtime of FGCI's 
#  ansible-pull-script.sh
# API documentation: 
#  http://opentsdb.net/docs/build/html/api_http/put.html#example-multiple-data-point-put

timestamp="$(date +%s)"
host="$(hostname -s)"
DOMAINNAME="$(domainname)"
domain="${DOMAINNAME:-UNDEFINED}"
runtime="${2:-""}"

SUCCEEDED=0
STARTED=1
FAILED=2

safety() {

which curl 2>&1 >/dev/null
if [ "$?" != 0 ]; then
	echo "could not find curl, exiting grafana_ansible_pull.sh"
	exit 2
fi

}

pull_runtime() {
curl -f -H "Content-Type: application/json" -X POST -d '[ 
  {
      "metric": "pull_runtime",
      "value": '$runtime',
      "timestamp": '$timestamp',
      "tags": {
         "pull_runtime": "pull_runtime",
         "node": "'"$host"'",
         "state": "'"$1"'",
         "sitename": "'"$domain"'"
      }
  }
]
  ' http://cassini.fgci.csc.fi:4242/api/put
}

pull_state() {
curl -f -H "Content-Type: application/json" -X POST -d '[ 
  {
      "metric": "ansible_pull",
      "text": "'"$1"'",
      "value": '$2',
      "timestamp": '$timestamp',
      "state": "'"$1"'",
      "tags": {
         "node": "'"$host"'",
         "state": "'"$1"'",
         "sitename": "'"$domain"'"
      }
  }
]
  ' http://cassini.fgci.csc.fi:4242/api/put
}

safety

case "$1" in
        started)
            pull_state $1 $STARTED
	    if [ "$2" != "" ]; then 
		pull_runtime $1
	    fi
            ;;
        failed)
            pull_state $1 $FAILED
	    if [ "$2" != "" ]; then 
		pull_runtime $1
	    fi
            ;;
        succeeded)
            pull_state $1 $SUCCEEDED
	    if [ "$2" != "" ]; then 
		pull_runtime $1
	    fi
            ;;
        *)
            echo $"Usage: $0 {started|failed|succeeded} [optional runtime in seconds in a second metric/API call]"
            exit 1

esac
