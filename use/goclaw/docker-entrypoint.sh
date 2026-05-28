#!/bin/sh
set -e

case "${1:-serve}" in
  serve)
    /bin/goclaw
    ;;
  upgrade)
    shift
    /bin/goclaw upgrade "$@"
    ;;
  migrate)
    shift
    /bin/goclaw migrate "$@"
    ;;
  onboard)
    /bin/goclaw onboard
    ;;
  version)
    /bin/goclaw version
    ;;
  *)
    /bin/goclaw "$@"
    ;;
esac
