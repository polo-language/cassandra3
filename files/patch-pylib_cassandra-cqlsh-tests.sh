--- pylib/cassandra-cqlsh-tests.sh.orig	2022-01-03 17:11:14 UTC
+++ pylib/cassandra-cqlsh-tests.sh
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
@@ -24,9 +23,12 @@
 ################################
 
 WORKSPACE=$1
-PYTHON_VERSION=$2
-JAVA_HOME=$3
+JAVA_HOME=$2
+REPO_DIR=$3
+PYTHON_CMD=$4
 
+PYTHON_VERSION=python3
+
 if [ "${WORKSPACE}" = "" ]; then
     echo "Specify Cassandra source directory"
     exit
@@ -63,23 +65,23 @@ else
     TESTSUITE_NAME="${TESTSUITE_NAME}.jdk8"
 fi
 
-# Loop to prevent failure due to maven-ant-tasks not downloading a jar..
-for x in $(seq 1 3); do
-    ant -buildfile ${CASSANDRA_DIR}/build.xml realclean jar
-    RETURN="$?"
-    if [ "${RETURN}" -eq "0" ]; then
-        break
-    fi
-done
-# Exit, if we didn't build successfully
-if [ "${RETURN}" -ne "0" ]; then
-    echo "Build failed with exit code: ${RETURN}"
-    exit ${RETURN}
-fi
+## Loop to prevent failure due to maven-ant-tasks not downloading a jar..
+#for x in $(seq 1 3); do
+#    ant -buildfile ${CASSANDRA_DIR}/build.xml realclean jar
+#    RETURN="$?"
+#    if [ "${RETURN}" -eq "0" ]; then
+#        break
+#    fi
+#done
+## Exit, if we didn't build successfully
+#if [ "${RETURN}" -ne "0" ]; then
+#    echo "Build failed with exit code: ${RETURN}"
+#    exit ${RETURN}
+#fi
 
 # Set up venv with dtest dependencies
 set -e # enable immediate exit if venv setup fails
-virtualenv --python=$PYTHON_VERSION venv
+virtualenv --python=$PYTHON_CMD venv
 source venv/bin/activate
 pip install -r ${CASSANDRA_DIR}/pylib/requirements.txt
 pip freeze
@@ -120,7 +122,7 @@ case "${pre_or_post_cdc}" in
         ;;
 esac
 
-ccm start --wait-for-binary-proto
+ccm start --wait-for-binary-proto --root
 
 cd ${CASSANDRA_DIR}/pylib/cqlshlib/
 
