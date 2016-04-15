#!/bin/bash
# This sends an annotation to opentsdb on cassini.fgci.csc.fi

timestamp="$(date +%s)"
host="$(hostname -s)"
DOMAINNAME="$(domainname)"
domain="${DOMAINNAME:-UNDEFINED}"

safety() {

which curl 2>&1 >/dev/null
if [ "$?" != 0 ]; then
	echo "could not find curl, exiting grafana_ansible_pull.sh"
	exit 2
fi

}

started() {
curl -f -H "Content-Type: application/json" -X POST -d '{
      "metric": "ansible_pull",
      "text": "started",
      "value": 1,
      "timestamp": '$timestamp',
      "state": "started",
      "tags": {
         "node": "'"$host"'",
         "state": "started",
         "sitename": "'"$domain"'"
      }
  }
  ' http://cassini.fgci.csc.fi:4242/api/put
}

failed() {
curl -f -H "Content-Type: application/json" -X POST -d '{
      "metric": "ansible_pull",
      "text": "failed",
      "value": 2,
      "timestamp": '$timestamp',
      "state": "failed",
      "tags": {
         "node": "'"$host"'",
         "state": "failed",
         "sitename": "'"$domain"'"
      }
  }
  ' http://cassini.fgci.csc.fi:4242/api/put
}

succeeded() {
curl -f -H "Content-Type: application/json" -X POST -d '{
      "metric": "ansible_pull",
      "text": "succeeded",
      "value": 0,
      "timestamp": '$timestamp',
      "state": "succeeded",
      "tags": {
         "node": "'"$host"'",
         "state": "succeeded",
         "sitename": "'"$domain"'"
      }
  }
  ' http://cassini.fgci.csc.fi:4242/api/put
}

safety

case "$1" in
        started)
	    safety
            started
            ;;
        failed)
	    safety
            failed
            ;;
        succeeded)
	    safety
            succeeded
            ;;
        *)
            echo $"Usage: $0 {started|failed|succeeded}"
            exit 1

esac
