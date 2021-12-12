--- pylib/cassandra-cqlsh-tests.sh.orig	2021-07-01 16:37:50.000000000 +0200
+++ pylib/cassandra-cqlsh-tests.sh	2021-12-12 12:31:23.815315000 +0100
@@ -1,4 +1,4 @@
-#!/bin/bash -x
+#!/usr/local/bin/bash -x
 #
 # Licensed to the Apache Software Foundation (ASF) under one
 # or more contributor license agreements.  See the NOTICE file
@@ -15,7 +15,6 @@
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
-#
 
 ################################
 #
@@ -24,12 +23,25 @@
 ################################
 
 WORKSPACE=$1
+PYTHON_VERSION=$2
+JAVA_HOME=$3
+REPO_DIR=$4
+PYTHON_CMD=$5
 
 if [ "${WORKSPACE}" = "" ]; then
     echo "Specify Cassandra source directory"
     exit
 fi
 
+if [ "${PYTHON_VERSION}" = "" ]; then
+    PYTHON_VERSION=python3
+fi
+
+if [ "${PYTHON_VERSION}" != "python3" -a "${PYTHON_VERSION}" != "python2" ]; then
+    echo "Specify Python version python3 or python2"
+    exit
+fi
+
 export PYTHONIOENCODING="utf-8"
 export PYTHONUNBUFFERED=true
 export CASS_DRIVER_NO_EXTENSIONS=true
@@ -39,11 +51,22 @@
 export CCM_CONFIG_DIR=${WORKSPACE}/.ccm
 export NUM_TOKENS="32"
 export CASSANDRA_DIR=${WORKSPACE}
-export TESTSUITE_NAME="cqlshlib.python2.jdk8"
+export TESTSUITE_NAME="cqlshlib.${PYTHON_VERSION}"
+export JAVA_HOME=$JAVA_HOME
 
+if [ -z "$CASSANDRA_USE_JDK11" ]; then
+    export CASSANDRA_USE_JDK11=false
+fi
+
+if [ "$CASSANDRA_USE_JDK11" = true ] ; then
+    TESTSUITE_NAME="${TESTSUITE_NAME}.jdk11"
+else
+    TESTSUITE_NAME="${TESTSUITE_NAME}.jdk8"
+fi
+
 # Loop to prevent failure due to maven-ant-tasks not downloading a jar..
 for x in $(seq 1 3); do
-    ant -buildfile ${CASSANDRA_DIR}/build.xml realclean jar
+    ant -buildfile ${CASSANDRA_DIR}/build.xml -Dmaven.repo.local=${REPO_DIR} -Dlocalm2=${REPO_DIR} -Dpycmd=${PYTHON_CMD} realclean jar
     RETURN="$?"
     if [ "${RETURN}" -eq "0" ]; then
         break
@@ -57,7 +80,7 @@
 
 # Set up venv with dtest dependencies
 set -e # enable immediate exit if venv setup fails
-virtualenv --python=python2 --no-site-packages venv
+virtualenv --python=${PYTHON_CMD} --no-site-packages venv
 source venv/bin/activate
 pip install -r ${CASSANDRA_DIR}/pylib/requirements.txt
 pip freeze
@@ -83,7 +106,7 @@
 
 version_from_build=$(ccm node1 versionfrombuild)
 export pre_or_post_cdc=$(python -c """from distutils.version import LooseVersion
-print \"postcdc\" if LooseVersion(\"${version_from_build}\") >= \"3.8\" else \"precdc\"
+print (\"postcdc\" if LooseVersion(\"${version_from_build}\") >= \"3.8\" else \"precdc\")
 """)
 case "${pre_or_post_cdc}" in
     postcdc)
@@ -98,7 +121,7 @@
         ;;
 esac
 
-ccm start --wait-for-binary-proto
+ccm start --wait-for-binary-proto --root
 
 cd ${CASSANDRA_DIR}/pylib/cqlshlib/
 
