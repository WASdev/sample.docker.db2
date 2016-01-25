#! /bin/sh
#
# (C) Copyright IBM Corporation 2016.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 

# Check arguments
if [ $# -eq 0 ]
  then
    echo "No arguments... Pass the number of agents required"
	exit 1
fi

# Set Up Key-Value Store
docker-machine create -d virtualbox mh-keystore
docker $(docker-machine config mh-keystore) run -d -p "8500:8500" -h "consul" progrium/consul -server -bootstrap

# Create A Swarm Cluster
docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-advertise=eth1:2376" swarm-master
for (( i=1; i<=$1; i++ ))
do
	echo "Creating Swarm Agent $i"
	docker-machine create -d virtualbox --swarm --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" --engine-opt="cluster-advertise=eth1:2376" swarm-agent$i
done

docker-machine ls