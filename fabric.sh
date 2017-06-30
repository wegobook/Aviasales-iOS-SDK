if [ "$CONFIGURATION" != "Debug" ]; then
API_KEY=""
BUILD_SECRET=""
${PODS_ROOT}/Fabric/run ${API_KEY} ${BUILD_SECRET}
fi
