#!/bin/bash
# This sends an annotation to opentsdb on cassini.fgci.csc.fi

timestamp="$(date +%s)"
host="$(hostname -s)"
DOMAINNAME="$(domainname)"
domain="${DOMAINNAME:-UNDEFINED}"

safety() {

which curl 2>&1 >/dev/null
if [ "$?" != 0 ]; then
	echo "could not find curl, halting"
	exit 2
fi

}

started() {
curl -H "Content-Type: application/json" -X POST -d '{
      "metric": "ansible_pull",
      "text": "started",
      "value": 1,
      "timestamp": '$timestamp',
      "state": "started",
      "tags": {
         "fqdn": "'"$host"'",
         "state": "started",
         "site": "'"$domain"'"
      }
  }
  ' http://cassini.fgci.csc.fi:4242/api/put
}

failed() {
curl -H "Content-Type: application/json" -X POST -d '{
      "metric": "ansible_pull",
      "text": "failed",
      "value": 2,
      "timestamp": '$timestamp',
      "state": "failed",
      "tags": {
         "fqdn": "'"$host"'",
         "state": "failed",
         "site": "'"$domain"'"
      }
  }
  ' http://cassini.fgci.csc.fi:4242/api/put
}

succeeded() {
curl -H "Content-Type: application/json" -X POST -d '{
      "metric": "ansible_pull",
      "text": "succeeded",
      "value": 0,
      "timestamp": '$timestamp',
      "state": "succeeded",
      "tags": {
         "fqdn": "'"$host"'",
         "state": "succeeded",
         "site": "'"$domain"'"
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
