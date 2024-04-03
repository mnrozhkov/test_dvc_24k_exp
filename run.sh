#!/bin/bash

# Function to run DVC experiment in a temporary directory
run_experiment() {
    temp_dir="$1"
    (
        cd "$temp_dir" || exit
        git clone git@github.com:mnrozhkov/monorepo-multiproject-detached-exps.git
        cd monorepo-multiproject-detached-exps/project_a || exit
        dvc exp run -f
        dvc exp push
    )
}

# Function to remove temporary directories
cleanup() {
    rm -rf "${temp_dirs[@]}"
}

# Main function
main() {
    num_loops="$1"
    num_experiments="$2"

    # Initialize an array to store temporary directories
    declare -a temp_dirs

    # Trap to ensure cleanup even if script is interrupted
    trap cleanup EXIT

    # Run experiments in a loop
    for (( i = 1; i <= num_loops; i++ )); do
        echo "Loop $i"

        # Create temporary directories for experiments
        for (( j = 1; j <= num_experiments; j++ )); do
            temp_dir=$(mktemp -d)
            temp_dirs+=("$temp_dir")
            run_experiment "$temp_dir" &
        done

        # Wait for all experiments to finish
        wait

        # Remove temporary directories after each loop
        cleanup
    done
}

# Check if the number of arguments is correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <number of loops> <number of experiments>"
    exit 1
fi

main "$1" "$2"
