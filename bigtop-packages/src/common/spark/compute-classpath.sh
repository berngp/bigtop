#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script computes Spark's classpath and prints it to stdout; it's used by both the "run"
# script and the ExecutorRunner in standalone cluster mode.

SCALA_VERSION=2.9.3

# Figure out where Spark is installed
FWDIR="$(cd `dirname $0`/..; pwd)"

# Load environment variables from conf/spark-env.sh, if it exists
if [ -e $FWDIR/conf/spark-env.sh ] ; then
  . $FWDIR/conf/spark-env.sh
fi

CORE_DIR="$FWDIR/core"
REPL_DIR="$FWDIR/repl"
REPL_BIN_DIR="$FWDIR/repl-bin"
EXAMPLES_DIR="$FWDIR/examples"
BAGEL_DIR="$FWDIR/bagel"
MLLIB_DIR="$FWDIR/mllib"
STREAMING_DIR="$FWDIR/streaming"
PYSPARK_DIR="$FWDIR/python"

# Build up classpath
CLASSPATH="$SPARK_CLASSPATH"
CLASSPATH="$CLASSPATH:$FWDIR/conf"
CLASSPATH="$CLASSPATH:$CORE_DIR/lib/*"
CLASSPATH="$CLASSPATH:$REPL_DIR/lib/*"
CLASSPATH="$CLASSPATH:$EXAMPLES_DIR/lib/*"
CLASSPATH="$CLASSPATH:$BAGEL_DIR/lib/*"
CLASSPATH="$CLASSPATH:$MLLIB_DIR/lib/*"
CLASSPATH="$CLASSPATH:$STREAMING_DIR/lib/*"
CLASSPATH="$CLASSPATH:$FWDIR/lib/*"
#CLASSPATH="$CLASSPATH:$CORE_DIR/src/main/resources"
if [ -e "$PYSPARK_DIR" ]; then
  for jar in `find $PYSPARK_DIR/lib -name '*jar'`; do
    CLASSPATH="$CLASSPATH:$jar"
  done
fi

# Add hadoop conf dir - else FileSystem.*, etc fail !
# Note, this assumes that there is either a HADOOP_CONF_DIR or YARN_CONF_DIR which hosts
# the configuration files.

export DEFAULT_HADOOP=/usr/lib/hadoop
export DEFAULT_HADOOP_CONF=/etc/hadoop/conf
export HADOOP_HOME=${HADOOP_HOME:-$DEFAULT_HADOOP}
export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-$DEFAULT_HADOOP_CONF}

CLASSPATH="$CLASSPATH:$HADOOP_CONF_DIR"
if [ "x" != "x$YARN_CONF_DIR" ]; then
  CLASSPATH="$CLASSPATH:$YARN_CONF_DIR"
fi
# Let's make sure that all needed hadoop libs are added properly
CLASSPATH="$CLASSPATH:$HADOOP_HOME/lib/*:$HADOOP_HOME/*:${HADOOP_HOME}-hdfs/lib/*:${HADOOP_HOME}-hdfs/*:${HADOOP_HOME}-yarn/*:/usr/lib/hadoop-mapreduce/*"
# Add Scala standard library
if [ -z "$SCALA_LIBRARY_PATH" ]; then
  if [ -z "$SCALA_HOME" ]; then
    echo "SCALA_HOME is not set" >&2
    exit 1
  fi
  SCALA_LIBRARY_PATH="$SCALA_HOME/lib"
fi
CLASSPATH="$CLASSPATH:$SCALA_LIBRARY_PATH/scala-library.jar"
CLASSPATH="$CLASSPATH:$SCALA_LIBRARY_PATH/scala-compiler.jar"
CLASSPATH="$CLASSPATH:$SCALA_LIBRARY_PATH/jline.jar"

echo "$CLASSPATH"
