# create a Vnet EastUs2
az network vnet create --name vnetEastUs2 --location eastus2 --resource-group rnd-charindut-isuru --address-prefix 10.0.0.0/16 --subnet-name dedicated-subnet

# create a Vnet CentralUs
az network vnet create --name vnetCentralUs --location centralus --resource-group rnd-isurug-charindu --address-prefix 192.168.0.0/16 --subnet-name dedicated-subnet

# create peering between Vnet EastUs2 and CentralUs
az network vnet peering create --resource-group rnd-charindut-isuru --name eastVnetTocentralVnet --vnet-name vnetEastUs2 --remote-vnet vnetCentralUs --allow-vnet-access --allow-forwarded-traffic

# create peering between Vnet CentralUs and EastUs2
az network vnet peering create --resource-group rnd-isurug-charindu --name centralVnetToeastVnet --vnet-name vnetCentralUs --remote-vnet vnetEastUs2 --allow-vnet-access --allow-forwarded-traffic

# check peering status (Connected)
az network vnet peering show --name MyVnet1ToMyVnet2 --resource-group cassandra-mi-multi-region --vnet-name vnetEastUs2 --query peeringState

# give permission to the user to create a managed cassandra cluster
az role assignment create --assignee a232010e-820c-4083-83bb-3ace5fc29d0b --role 4d97b98b-1d4f-4787-a291-c67834d212e7 --scope /subscriptions/38785beb-5019-4896-8679-3d41ddacc4b1/resourceGroups/rnd-charindut-isuru/providers/Microsoft.Network/virtualNetworks/vnetEastUs2

az role assignment create --assignee a232010e-820c-4083-83bb-3ace5fc29d0b --role 4d97b98b-1d4f-4787-a291-c67834d212e7 --scope /subscriptions/38785beb-5019-4896-8679-3d41ddacc4b1/resourceGroups/rnd-charindut-isuru/providers/Microsoft.Network/virtualNetworks/vnetCentralUs



# create a  multi region cassandra cluster in EastUs2

resourceGroupName='rnd-charindut-isuru'
clusterName='test-multi-region'
location='eastus2'
delegatedManagementSubnetId='/subscriptions/<SubscriptionID>/resourceGroups/cassandra-mi-multi-region/providers/Microsoft.Network/virtualNetworks/vnetEastUs2/subnets/dedicated-subnet'
initialCassandraAdminPassword='nimda@1234'

az managed-cassandra cluster create --cluster-name $clusterName --resource-group $resourceGroupName --location $location --delegated-management-subnet-id $delegatedManagementSubnetId --initial-cassandra-admin-password $initialCassandraAdminPassword --debug

resourceGroupName='rnd-charindut-isuru'
clusterName='test-multi-region'
dataCenterName='dc-eastus2'
dataCenterLocation='eastus2'
delegatedManagementSubnetId='/subscriptions/<SubscriptionID>/resourceGroups/cassandra-mi-multi-region/providers/Microsoft.Network/virtualNetworks/vnetEastUs2/subnets/dedicated-subnet'

az managed-cassandra datacenter create --resource-group $resourceGroupName --cluster-name $clusterName --data-center-name $dataCenterName --data-center-location $dataCenterLocation --delegated-subnet-id $delegatedManagementSubnetId --node-count 3


# create a  multi region cassandra cluster in CentralUs

resourceGroupName='cassandra-mi-multi-region'
clusterName='test-multi-region'
dataCenterName='dc-centralus'
dataCenterLocation='centralus'
delegatedManagementSubnetId='/subscriptions/<SubscriptionID>/resourceGroups/cassandra-mi-multi-region/providers/Microsoft.Network/virtualNetworks/vnetEastUs/subnets/dedicated-subnet'
virtualMachineSKU='Standard_D8s_v4'
noOfDisksPerNode=4

az managed-cassandra datacenter create --resource-group $resourceGroupName --cluster-name $clusterName --data-center-name $dataCenterName --data-center-location $dataCenterLocation --delegated-subnet-id $delegatedManagementSubnetId --node-count 3 --sku $virtualMachineSKU --disk-capacity $noOfDisksPerNode --availability-zone false

# check the status of the cluster

resourceGroupName='cassandra-mi-multi-region'
clusterName='test-multi-region'

az managed-cassandra cluster node-status --cluster-name $clusterName --resource-group $resourceGroupName

cqsh -e "ALTER KEYSPACE "ks" WITH REPLICATION = {'class': 'NetworkTopologyStrategy', 'dc-eastus2': 3, 'dc-eastus': 3};"

# rebuild the cluster
az managed-cassandra cluster invoke-command --resource-group $resourceGroupName --cluster-name $clusterName --host <ip address> --command-name nodetool --arguments rebuild="" "dc-eastus2"=""