#!/bin/bash
#
# Interactively delete volumes at Digitalocean, based on their tag.

set -e -u

progname="$(basename "$0")"
doctl="doctl"
doctl_json="$doctl -o json"
jq="jq"
jq_raw="$jq"

function usage() {
  echo "Usage: $progname [-f] [[TAG] ...]" >&2
  exit 1
}

function doctl_check() {
  if ! $doctl_json compute droplet list >/dev/null; then
    echo "doctl command test failed - are you logged in ('doctl auth init') ?" >&2
    exit 1
  fi
}

function fetch_tags() {
  local tags
  tags="$($doctl_json compute droplet list | $jq_raw --raw-output '.[] | .tags[]' | sort | uniq)"
  echo "$tags"
}

function delete_tag() {
  local tag tagged_name name
  tag="${1:-}"
  if [ -z "$1" ]; then
    echo "Function usage: ${FUNCNAME[0]} TAG" >&2
    exit 1
  fi
  tagged_id="$($doctl_json compute droplet list --tag-name "$tag" | $jq_raw --raw-output '.[] | .id' | sort)"
  for id in $tagged_id; do
    echo "Deleting $id"
    $doctl compute droplet rm -f "$id"
  done
}

doctl_check

force_mode=0
if [ "${1:-}" = "-f" ]; then
  force_mode=1
  shift
fi

tags="$*"
if [ -z "$tags" ]; then
  tags=$(fetch_tags)
fi

for tag in $tags; do
  if [ "$force_mode" -eq 1 ]; then
    echo "Deleting $tag"
    delete_tag "$tag"
  else
    read -rp "Delete droplets with tag '$tag'? [yn] " response
    case "$response" in
      [Yy]*)
        delete_tag "$tag"
        ;;
      *)
        echo "Did not delete droplets for tag '$tag'"
        ;;
    esac
  fi
done

exit 0
