#!/bin/bash

# Function to ask for confirmation
ask_confirmation() {
    read -p "$1 (y/n) " response
    case "$response" in
        [Yy]* ) echo "yes";;
        [Nn]* ) echo "no";;
        * ) echo "Invalid input"; ask_confirmation "$1";;
    esac
}

# Check if CLUSTER_NAME environment variable is set
if [ -z "$CLUSTER_NAME" ]; then
    echo "Error: CLUSTER_NAME environment variable must be set."
    exit 1
fi

# Check if cluster with same name exists using AWS CLI and jq
CHECK_NAME=$(aws eks list-clusters | jq -r ".clusters[]" | grep "^$CLUSTER_NAME$" || true)

if [ "$CHECK_NAME" != "" ]; then
    echo "ERROR: There is already a cluster by this name; $CHECK_NAME."
    exit 1
fi

# Set default values
default_region="us-east-1"
default_nodegroup_name="default-nodegroup"
default_instance_type="t3.medium"
default_desired_capacity=3

# Ask for Region
echo "The default region is set to $default_region."
if [[ $(ask_confirmation "Is this the correct region?") == "no" ]]; then
    echo "Enter the new region:"
    read region
else
    region=$default_region
fi

# Ask for Node Group Name
echo "The default node group name is $default_nodegroup_name."
if [[ $(ask_confirmation "Would you like to input a new nodegroup name?") == "yes" ]]; then
    echo "Enter the node group name:"
    read nodegroup_name
else
    nodegroup_name=$default_nodegroup_name
fi

# Ask for Node Type
echo "The default node type is $default_instance_type."
if [[ $(ask_confirmation "Would you like to input a new node type?") == "yes" ]]; then
    echo "Enter the node type:"
    read instance_type
else
    instance_type=$default_instance_type
fi

# Ask for Number of Nodes
echo "The default number of nodes is $default_desired_capacity."
if [[ $(ask_confirmation "Would you like to input a new number of nodes?") == "yes" ]]; then
    echo "Enter the desired number of nodes:"
    read desired_capacity
else
    desired_capacity=$default_desired_capacity
fi

# Create the cluster
echo "Creating an EKS cluster with the following settings:"
echo "Region: $region"
echo "Node Group Name: $nodegroup_name"
echo "Node Type: $instance_type"
echo "Number of Nodes: $desired_capacity"

eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $region \
  --nodegroup-name $nodegroup_name \
  --node-type $instance_type \
  --nodes $desired_capacity

echo "Cluster creation completed."

