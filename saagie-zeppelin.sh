#!/bin/bash

# As we sould run this container in HOST mode to be able to access the Spark cluster,
# we need to parse arguments to get a port on which to run Zeppelin.
# If no port provided, let it run on default port (8080)
# If you want to change Zeppelin log level,
# you can also pass a '-d' or '--debug' option and give it the requested log level.

TEMP=`getopt -o p:d: --long port:,debug: -- "$@"`
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -d|--debug)
      case "$2" in
        "") shift 2 ;;
        *) DEBUG=$2 ; shift 2 ;;
      esac ;;
    -p|--port)
      case "$2" in
        "") shift 2 ;;
        *) PORT=$2 ; shift 2 ;;
      esac ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

echo "" > /zeppelin/conf/zeppelin-env.sh
if [ -z $PORT ]
then
  echo "WARNING: no port given. Zeppelin will run on default port."
else
  # Set the PORT0 variable used in spark-env.sh
  export PORT0=$(( $PORT+1 ))
  echo "export ZEPPELIN_PORT=$PORT" >> /zeppelin/conf/zeppelin-env.sh
fi

if [ -z $DEBUG ]
then
  echo "INFO: Zeppelin will log with default log level."
else
  echo "INFO: Zeppelin will log with $DEBUG log level."
  sed -i -e "s/INFO/$DEBUG/g" /zeppelin/conf/log4j.properties
fi

# As volumes are mounted at container startup,
# we need to grab mounted Spark conf and overwrite the default one before
# before running Zepplin
if [ -f "/usr/local/spark/conf/spark-env.sh" ]
then
  # overwrite Spark 2.1.0 config
  echo "INFO: ovewriting default spark-env.sh"
  cp /usr/local/spark/conf/spark-env.sh /usr/local/spark/2.1.0/conf
  chmod 755 /usr/local/spark/2.1.0/conf/spark-env.sh
  #FIXME: Spark UI hard coded port
  # sed -i -e 's/\$PORT0/12121/g' /usr/local/spark/2.1.0/conf/spark-env.sh
else
  # use default config
  echo "WARNING: NO CUSTOM spark-env.sh PROVIDED. USING DEFAULT TEMPLATE."
  cp /usr/local/spark/2.1.0/conf/spark-env.sh.template /usr/local/spark/2.1.0/conf/spark-env.sh
fi

# Create Zeppelin conf
#FIXME: do not hard code
echo "export MASTER=mesos://zk://zk1:2181,zk2:2181,zk3:2181,zk4:2181,zk5:2181,zk6:2181,zk7:2181/mesos" >> /zeppelin/conf/zeppelin-env.sh

# Run Zeppelin
echo "Running Apache Zeppelin..."
/zeppelin/bin/zeppelin.sh
