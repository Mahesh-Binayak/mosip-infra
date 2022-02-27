#!/bin/sh
# Installs all PreReg helm charts
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=prereg
CHART_VERSION=1.1.5

echo Create namespace
kubectl create ns $NS

echo Istio label
kubectl label ns $NS istio-injection=disabled --overwrite
helm repo update

echo Copy configmaps
./copy_cm.sh

API_HOST=`kubectl get cm global -o jsonpath={.data.mosip-api-host}`
PREREG_HOST=`kubectl get cm global -o jsonpath={.data.mosip-prereg-host}`

echo Install prereg-gateway
helm -n $NS install prereg-gateway mosip/prereg-gateway --set istio.hosts[0]=$PREREG_HOST --version $CHART_VERSION

echo Installing prereg-application
helm -n $NS install prereg-application mosip/prereg-application --version $CHART_VERSION

echo Installing prereg-booking
helm -n $NS install prereg-booking mosip/prereg-booking --version $CHART_VERSION

echo Installing prereg-datasync
helm -n $NS install prereg-datasync mosip/prereg-datasync --version $CHART_VERSION

echo Installing prereg-batchjob
helm -n $NS install prereg-batchjob mosip/prereg-batchjob --version $CHART_VERSION

echo Installing prereg-ui
helm -n $NS install prereg-ui mosip/prereg-ui --set prereg.apiHost=$PREREG_HOST --version $CHART_VERSION

echo Installing Prereg rate-control Envoyfilter
kubectl apply -n $NS -f rate-control-envoyfilter.yaml
