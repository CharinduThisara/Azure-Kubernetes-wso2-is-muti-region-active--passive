loadTestResource="JmeterTest-charindut-isuru"
resourceGroup="rnd-charindut-isuru"
location="East US 2"

az load create --name $loadTestResource --resource-group $resourceGroup --location $location

az load show --name $loadTestResource --resource-group $resourceGroup

testId="wso2-is"
testPlan="wso2-is.jmx"

az load test create --load-test-resource  $loadTestResource --test-id $testId  --display-name "My CLI Load Test" --description "Created using Az CLI" --test-plan $testPlan --engine-instances 1

testRunId="run_"`date +"%Y%m%d%_H%M%S"`
displayName="Run"`date +"%Y/%m/%d_%H:%M:%S"`

az load test-run create --load-test-resource $loadTestResource --test-id $testId --test-run-id $testRunId --display-name $displayName --description "Test run from CLI"
az load test-run metrics list --load-test-resource $loadTestResource --test-run-id $testRunId --metric-namespace LoadTestRunMetrics
