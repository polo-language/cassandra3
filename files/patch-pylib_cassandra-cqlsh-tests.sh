--- pylib/cassandra-cqlsh-tests.sh.orig	2020-08-28 13:15:14 UTC
+++ pylib/cassandra-cqlsh-tests.sh
@@ -1,4 +1,4 @@
-#!/bin/bash -x
+#!/usr/local/bin/bash -x
 
 ################################
 #
@@ -7,6 +7,9 @@
 ################################
 
 WORKSPACE=$1
+REPO_DIR=$2
+PYTHON_CMD=$3
+JAVA_HOME=$4
 
 if [ "${WORKSPACE}" = "" ]; then
     echo "Specify Cassandra source directory"
@@ -23,10 +26,11 @@ export CCM_CONFIG_DIR=${WORKSPACE}/.ccm
 export NUM_TOKENS="32"
 export CASSANDRA_DIR=${WORKSPACE}
 export TESTSUITE_NAME="cqlshlib.python2.jdk8"
+export JAVA_HOME=${JAVA_HOME}
 
 # Loop to prevent failure due to maven-ant-tasks not downloading a jar..
 for x in $(seq 1 3); do
-    ant -buildfile ${CASSANDRA_DIR}/build.xml realclean jar
+    ant -buildfile ${CASSANDRA_DIR}/build.xml -Dmaven.repo.local=${REPO_DIR} -Dlocalm2=${REPO_DIR} -Dpycmd=${PYTHON_CMD} realclean jar
     RETURN="$?"
     if [ "${RETURN}" -eq "0" ]; then
         break
@@ -40,7 +44,7 @@ fi
 
 # Set up venv with dtest dependencies
 set -e # enable immediate exit if venv setup fails
-virtualenv --python=python2 --no-site-packages venv
+virtualenv --python=${PYTHON_CMD} --no-site-packages venv
 source venv/bin/activate
 pip install -r ${CASSANDRA_DIR}/pylib/requirements.txt
 pip freeze
@@ -81,7 +85,7 @@ case "${pre_or_post_cdc}" in
         ;;
 esac
 
-ccm start --wait-for-binary-proto
+ccm start --wait-for-binary-proto --root
 
 cd ${CASSANDRA_DIR}/pylib/cqlshlib/
 
