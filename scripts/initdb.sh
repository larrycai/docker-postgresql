#!/bin/bash

set -e

DATA_DIR=/data

if [[ ! -e $DATA_DIR/db_is_initialzed ]]; then
  source /scripts/first_run.sh
else
  source /scripts/normal_run.sh
fi

wait_for_postgres_and_run_post_start_action() {
  # Wait for postgres to finish starting up first.
  while [[ ! -e $DATA_DIR/postmaster.pid ]] ; do
  	  ls $DATA_DIR
      #inotifywait -q -e modify $DATA_DIR/postmaster.pid >> /dev/null
      inotifywait -q -e create $DATA_DIR >> /dev/null
  done
  post_start_action
  echo "Now press CTRL-C to stop postgresql or CTRL-P-Q to turn into daemon mode"
}

pre_start_action

wait_for_postgres_and_run_post_start_action &
# Start PostgreSQL
echo "PostgreSQL... is initialized to new place $DATA_DIR"
echo "Starting postgresql in background"
su postgres -c '/usr/pgsql-9.3/bin/postgres -D /data'
