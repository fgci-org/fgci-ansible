#!/bin/bash
# This sends an annotation to opentsdb on cassini.fgci.csc.fi
# Can be used to indicate on graphs that an acceptance test has started

timestamp="$(date +%s)"

start() {
  curl -H "Content-Type: application/json" -X POST -d '{
      "metric": "acceptance_test",
      "value": 1,
      "timestamp": '$timestamp',
      "tags": {
         "fqdn": "'"$hostname"'",
         "site": "io"
      }
  }
  ' http://cassini.fgci.csc.fi:4242/api/put
}
stop() {
  curl -H "Content-Type: application/json" -X POST -d '{
      "metric": "acceptance_test",
      "value": 0,
      "timestamp": '$timestamp',
      "tags": {
         "fqdn": "'"$hostname"'",
         "site": "io"
      }
  }
  ' http://cassini.fgci.csc.fi:4242/api/put
}


case "$1" in
        start)
            start
            ;;

        stop)
            stop
            ;;

        *)
            echo $"Usage: $0 {start|stop}"
            exit 1

esac
