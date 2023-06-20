#!/bin/bash

[[ -z "$CONCURRENCY_TYPE" ]] && { echo "Set CONCURRENCY_TYPE env var to either 'multithreaded' or 'multiprocess'" ; exit 1; }

# Create lighttpd config with TRex instances
configfile=/srv/lighttpd/lighttpd.conf

echo '
server.modules += ( "mod_setenv" )
server.modules += ( "mod_proxy" )
server.modules += ( "mod_rewrite" )
server.modules += ( "mod_accesslog" )

server.document-root = "/var/www/"
server.port = 80

server.username = "www"
server.groupname = "www"

server.errorlog = "/dev/stderr"

accesslog.filename = "/dev/fd/2"

proxy.server = (
  "" => (' > $configfile # overwrite current config file

for i in $(seq 1 $PROCESS_COUNT)
do
  let PORT=6000+$i
  if [ ! $i -eq $PROCESS_COUNT ]
  then
    echo "    ( \"host\" => \"127.0.0.1\", \"port\" => $PORT )," >> $configfile # append to new config file
  else
    echo "    ( \"host\" => \"127.0.0.1\", \"port\" => $PORT )" >> $configfile # append to new config file
  fi
done

echo '  )
)
' >> $configfile # append to new config file

cat $configfile

if [[ "$CONCURRENCY_TYPE" == "multiprocess" ]]; then
  # Start TRex instances
  for i in $(seq 1 $PROCESS_COUNT)
  do
    let PORT=6000+$i
    echo "Starting Trex $i..."
    PORT=$PORT /usr/bin/t_rex serve --config=/var/data/in/config.toml &
  done
elif [[ "$CONCURRENCY_TYPE" == "multithreaded" ]]; then
    PORT=$PORT /usr/bin/t_rex serve --config=/var/data/in/config.toml &
fi


echo "Starting Lighttpd..."
lighttpd -D -f /srv/lighttpd/lighttpd.conf &

ps -aux

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
