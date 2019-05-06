# baxter-sim-demo

Requires install of docker-ce on your platform to build and run container.

Build using:

./build

Run using:

./run

This will start two containers in the background: an X11 display container and a Baxter simulator. Once started, do:

docker ps

to find out the name of the docker container running the Baxter simulator (vxlab-baxter2) image

Next, do:

docker exec -it vxlab-baxter2 bash

At the prompt, do:

source ./rosenv.sh

./simstart

Finally, to see the simulation window, run a browser on the same machine, with the URL: http://localhost:8080/vnc_auto.html

Once gazebo has fully loaded (the model of baxter will be displayed in gazebo) run:

./arm_track_sim

Wait for baxter to move arms into the starting position (extended fully out in both sides)

run:

rosbag play 2019-03-27-14-29-32.bag /tf:=/tf_old
