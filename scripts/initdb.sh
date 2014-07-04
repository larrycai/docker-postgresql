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
      inotifywait -q -e create $DATA_DIR/postmaster.pid >> /dev/null
  done

  post_start_action
}

pre_start_action

#wait_for_postgres_and_run_post_start_action &

# Start PostgreSQL
echo "PostgreSQL... is initialized to new place $DATA_DIR"
#echo "Start postgresql in background"
#su postgres -c '/usr/pgsql-9.3/bin/postgres -D /var/lib/pgsql/9.3/data'