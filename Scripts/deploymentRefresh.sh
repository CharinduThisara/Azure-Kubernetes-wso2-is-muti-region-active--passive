# delete the is-deployment.yaml file in IS/templates folder

rm -f ./templates/is_deployment.yaml
echo "read-only is-configmap.yaml file deleted successfully."
echo " "
echo " "

echo "replacing deployment with read-write deployment"
cp ./deployments/read_write/is-deployment.yaml ../IS/templates/
echo "read-write is-deployment.yaml file copied successfully."
echo " "
echo " "

echo "upgrading the IS deployment"
helm upgrade is-release ../IS 
echo "IS deployment upgraded successfully."
echo " "
echo " "

echo "replacing configmap with read-only is-configmap again"
rm -f ../IS/templates/is-deployment.yaml
cp deployments/read_only/is-deployment.yaml ../IS/templates/
echo "read-only is-configmap.yaml file copied successfully."
echo " "
echo " "

echo "deployment refreshed"