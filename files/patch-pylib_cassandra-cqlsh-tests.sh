--- pylib/cassandra-cqlsh-tests.sh.orig	2021-07-01 14:37:50 UTC
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
@@ -39,25 +51,37 @@ export CCM_HEAP_NEWSIZE="200M"
 export CCM_CONFIG_DIR=${WORKSPACE}/.ccm
 export NUM_TOKENS="32"
 export CASSANDRA_DIR=${WORKSPACE}
-export TESTSUITE_NAME="cqlshlib.python2.jdk8"
+export TESTSUITE_NAME="cqlshlib.${PYTHON_VERSION}"
+export JAVA_HOME=$JAVA_HOME
 
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
+if [ -z "$CASSANDRA_USE_JDK11" ]; then
+    export CASSANDRA_USE_JDK11=false
 fi
 
+if [ "$CASSANDRA_USE_JDK11" = true ] ; then
+    TESTSUITE_NAME="${TESTSUITE_NAME}.jdk11"
+else
+    TESTSUITE_NAME="${TESTSUITE_NAME}.jdk8"
+fi
+
+## Loop to prevent failure due to maven-ant-tasks not downloading a jar..
+#for x in $(seq 1 3); do
+#    echo XXX: "${ANT_OPTS}"
+#    ${ANT_CMD} -buildfile ${CASSANDRA_DIR}/build.xml -Dmaven.repo.local=${REPO_DIR} -Dlocalm2=${REPO_DIR} -Dpycmd=${PYTHON_CMD} realclean jar
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
+
 # Set up venv with dtest dependencies
 set -e # enable immediate exit if venv setup fails
-virtualenv --python=python2 --no-site-packages venv
+virtualenv --python=${PYTHON_CMD} venv
 source venv/bin/activate
 pip install -r ${CASSANDRA_DIR}/pylib/requirements.txt
 pip freeze
@@ -83,7 +107,7 @@ ccm updateconf "enable_user_defined_functions: true"
 
 version_from_build=$(ccm node1 versionfrombuild)
 export pre_or_post_cdc=$(python -c """from distutils.version import LooseVersion
-print \"postcdc\" if LooseVersion(\"${version_from_build}\") >= \"3.8\" else \"precdc\"
+print (\"postcdc\" if LooseVersion(\"${version_from_build}\") >= \"3.8\" else \"precdc\")
 """)
 case "${pre_or_post_cdc}" in
     postcdc)
@@ -98,7 +122,7 @@ case "${pre_or_post_cdc}" in
         ;;
 esac
 
-ccm start --wait-for-binary-proto
+ccm start --wait-for-binary-proto --root
 
 cd ${CASSANDRA_DIR}/pylib/cqlshlib/
 
