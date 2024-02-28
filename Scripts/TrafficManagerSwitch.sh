#!/bin/bash

readonly DEFAULT_CURRENT_ENDPOINT="east-us"
readonly DEFAULT_NEW_ENDPOINT="central-us"
readonly RESOURSE_GROUP_TM="rnd-isurug-charindu"
readonly PROFILE_NAME="wso2-is"
readonly ENDPOINT_TYPE="azureEndpoints"

readonly AZURE_SQL_DATABASE_NAME="ismssqldbprimary"
readonly AZURE_SQL_SERVER_NAME="wso2is-db-secondary"
readonly AZURE_SQL_RESOURCE_GROUP="rnd-isurug-charindu"

spinner(){
    sleep 5 & pid=$!
 
    i=1
    sp="\|/-"
    while ps -p $pid > /dev/null
    do
        printf "\b%c" "${sp:i++%4:1}"
        sleep 0.1
    done

    printf "\b"
}

# Function to switch endpoints in Traffic Manager
switch_endpoints() {
    local current_endpoint=${1:-$DEFAULT_CURRENT_ENDPOINT}
    local new_endpoint=${2:-$DEFAULT_NEW_ENDPOINT}
    

    echo "Switching endpoints from $current_endpoint to $new_endpoint"

    spinner &
    # Enable DR endpoint
    output=$(az network traffic-manager endpoint update --endpoint-status Enabled --name $new_endpoint --profile-name $PROFILE_NAME --resource-group $RESOURSE_GROUP_TM --type $ENDPOINT_TYPE)

    name=$(echo "$output" | grep -o '"name": *"[^"]*"' | sed 's/"name": "\(.*\)"/\1/')
    endpoint_status=$(echo "$output" | grep -o '"endpointStatus": *"[^"]*"' | sed 's/"endpointStatus": "\(.*\)"/\1/')
    target=$(echo "$output" | grep -o '"target": *"[^"]*"' | sed 's/"target": "\(.*\)"/\1/')

    # Print formatted output
    echo "Endpoint \"$name\" is \"$endpoint_status\" in \"$target\""

    spinner &
    # Disable current endpoint
    output=$(az network traffic-manager endpoint update --endpoint-status Disabled --name $current_endpoint --profile-name $PROFILE_NAME --resource-group $RESOURSE_GROUP_TM --type $ENDPOINT_TYPE)

    wait $!

    name=$(echo "$output" | grep -o '"name": *"[^"]*"' | sed 's/"name": "\(.*\)"/\1/')
    endpoint_status=$(echo "$output" | grep -o '"endpointStatus": *"[^"]*"' | sed 's/"endpointStatus": "\(.*\)"/\1/')
    target=$(echo "$output" | grep -o '"target": *"[^"]*"' | sed 's/"target": "\(.*\)"/\1/')

    # Print formatted output
    echo "Endpoint \"$name\" is \"$endpoint_status\" in \"$target\""
}   
# Function to initiate failover in Azure SQL Database
initiate_failover() {
    local db_name=${1:-$AZURE_SQL_DATABASE_NAME}
    local server_name=${2:-$AZURE_SQL_SERVER_NAME}
    local resource_group=${3:-$AZURE_SQL_RESOURCE_GROUP}
    
    # Replace this placeholder logic with actual logic to initiate failover in Azure SQL Database
    echo "Initiating the failover of DATABASE: $db_name on SERVER: $server_name in RESOURCE GROUP: $resource_group"

    output=$(az sql db replica set-primary --name $db_name --resource-group $resource_group --server $server_name)
    partnerRole=$(echo "$output" | grep -o '"partnerRole": *"[^"]*"' | sed 's/"partnerRole": "\(.*\)"/\1/')
    partnerServer=$(echo "$output" | grep -o '"partnerServer": *"[^"]*"' | sed 's/"partnerServer": "\(.*\)"/\1/')
    role=$(echo "$output" | grep -o '"role": *"[^"]*"' | sed 's/"role": "\(.*\)"/\1/')
    percentComplete=$(echo "$output" | grep -o '"percentComplete": *[0-9]*' | sed 's/"percentComplete": *\([0-9]*\)/\1/')
    partnerLocation=$(echo "$output" | grep -o '"partnerLocation": *"[^"]*"' | sed 's/"partnerLocation": "\(.*\)"/\1/')

    # Print formatted output
    echo -e "Failover initiation successful $percentComplete%.\n"
    echo "Primary"
    # Print the header
    printf "%-16s : %s\n" "DB name" "$db_name"
    printf "%-16s : %s\n" "Server" "$server_name"
    printf "%-16s : %s\n" "Role" "$role"
    printf "%-16s : %s\n" "Resource Group" "$resource_group"
    printf "%-16s : %s\n" "Status" "ONLINE"

    # Print the secondary section
    echo -e "\nSecondary"
    printf "%-16s : %s\n" "DB name" "$db_name"
    printf "%-16s : %s\n" "Server" "$partnerServer"
    printf "%-16s : %s\n" "Role" "$partnerRole"
    printf "%-16s : %s\n" "Partner location" "$partnerLocation"
    printf "%-16s : %s\n" "Status" "READABLE"

    # Example: az sql db replica failover -g <resource-group> -s <server-name> -d <database-name> --partner-group <partner-resource-group> --location <failover-location>
}

# Display usage instructions
usage() {
    echo "Usage: $0 [-h] [-c <current endpoint>] [-n <new endpoint>] [-s <server name>] [-r <resource group>] [-d <dbname>]"
    echo "Options:"
    echo "  -h    Display this help message"
    echo "  -c    Specify the current endpoint"
    echo "  -n    Specify the new endpoint"
    echo "  -s    Specify the Azure SQL server name"
    echo "  -r    Specify the Azure SQL resource group"
    echo "  -d    Specify the database name"
}


# Parse command-line options
while getopts "hc:n:s:r:d:" opt; do
    case ${opt} in
        h )
            usage
            exit 0
            ;;
        c )
            current_endpoint=$OPTARG
            ;;
        n )
            new_endpoint=$OPTARG
            ;;
        s )
            server_name=$OPTARG
            ;;
        r )
            resource_group=$OPTARG
            ;;
        d )
            db_name=$OPTARG
            ;;
        \? )
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        : )
            echo "Invalid option: -$OPTARG requires an argument" >&2
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Visual interaction to choose the action
printf "Current endpoint        : %-30s\n" "${current_endpoint:-$DEFAULT_CURRENT_ENDPOINT}"
printf "New endpoint            : %-30s\n" "${new_endpoint:-$DEFAULT_NEW_ENDPOINT}"
printf "Azure SQL Server Name   : %-30s\n" "${server_name:-$AZURE_SQL_SERVER_NAME}"
printf "Azure SQL Resource Group: %-30s\n" "${resource_group:-$AZURE_SQL_RESOURCE_GROUP}"
printf "Database Name           : %-30s\n" "${db_name:-$AZURE_SQL_DATABASE_NAME}"

echo -e "\nChoose action:\n\t1 - Switch Traffic Manager endpoints:\n\t2 - Initiate failover in Azure SQL Database:\n\t3 - Switch Traffic Manager endpoints & \n\t    Initiate failover in Azure SQL Database:\n\t4 - Switch Traffic Manager endpoints WHILE \n\t    Initiating failover in Azure SQL Database:"
echo "[_]"
tput cuu 1
tput cuf 1
input=""

# Loop until Enter is pressed or the input reaches 1 characters
while IFS= read -r -s -n 1 char; do
    # Handle backspace (^H) and delete (^?) characters
    if [[ $char == $'\x08' || $char == $'\177' ]]; then
        if [ ${#input} -gt 0 ]; then
            input="${input%?}"  # Remove the last character from input
            echo -n $'\b_\b'  # Move the cursor left, clear the character, and move the cursor left again
        fi
    elif [[ $char == $'\0' ]]; then
        break  
    elif [[ ${#input} -ge 1 ]]; then
        continue
    else
        input+="$char"
        echo -n "$char"  # Echo the character to the terminal
    fi
done

tput cud 1
tput cub 2

# Perform the chosen action
case $input in
    1)
        start_time=$(date +%s)

        # Switch endpoints in Traffic Manager
        if switch_endpoints "$current_endpoint" "$new_endpoint"; then
            echo "Endpoints switched in Traffic Manager"
        fi

        end_time=$(date +%s)

        ;;
    2)
        start_time=$(date +%s)

        # Initiate failover in Azure SQL Database
        if initiate_failover "$db_name" "$server_name" "$resource_group"; then
            echo "Failover initiated in Azure SQL Database"
        fi

        end_time=$(date +%s)

        ;;
    3)
        start_time=$(date +%s)

        # Do both
        if switch_endpoints "$current_endpoint" "$new_endpoint"; then
            echo -e "Endpoints switched in Traffic Manager\n"
        fi

        if initiate_failover "$db_name" "$server_name" "$resource_group"; then
            echo "Failover initiated in Azure SQL Database"
        fi

        end_time=$(date +%s)

        ;;
    4)
        # Do both in parallel
        echo "Please wait while the tasks are being performed..."

        # Execute tasks in parallel and store their outputs in temporary files
        switch_output_file=$(mktemp)
        initiate_output_file=$(mktemp)

        start_time=$(date +%s)

        spinner &
        switch_endpoints "$current_endpoint" "$new_endpoint" > "$switch_output_file" &
        initiate_failover "$db_name" "$server_name" "$resource_group" > "$initiate_output_file" &

        # Wait for both tasks to finish
        wait

        end_time=$(date +%s)


        # Print the output of each task sequentially
        if [[ -s $switch_output_file ]]; then
            cat "$switch_output_file"
            echo
        fi

        if [[ -s $initiate_output_file ]]; then
            cat "$initiate_output_file"
            echo
        fi

        rm "$switch_output_file" "$initiate_output_file"

        ;;
    *)
        echo "Invalid option selected"
        ;;
esac


# Calculate the duration
duration=$((end_time - start_time))
echo "Time taken: $duration seconds"