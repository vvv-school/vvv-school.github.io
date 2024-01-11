## Conda instructions for VVV School Tutorial and Assignments

Beside the official Docker image based on the robotology-superbuild available at https://github.com/vvv-school/vvv-school.github.io/pkgs/container/gitpod, 
for some tutorial and assignments it is also possible to rely on conda to install the required dependencies.

To do so, create a dedicated conda environment with:
~~~
conda create -c conda-forge -c robotology -n vvvschool cmake ninja pkg-config make compilers yarp icub-contrib-common gazebo icub-models gazebo-yarp-plugins idyntree
~~~

The `vvv-school` tutorials also need some additional environmental variable to be set. 
In particular, you can ensure that are set automatically in the environment by creating a `vvvschool_activate.sh` script with the following two lines:
~~~
export GAZEBO_MODEL_PATH=${CONDA_PREFIX}/share/gazebo/models:${GAZEBO_MODEL_PATH}
export GAZEBO_RESOURCE_PATH=${CONDA_PREFIX}/share/gazebo/worlds:${GAZEBO_RESOURCE_PATH}
~~~

and adding it in the `${CONDA_PREFIX}/etc/conda/activate.d` directory.

Then, whenever to run a command, remember to run it in the `vvvschool` conda environment.

> [!WARNING]  
> Not all vvv repos may not be working fine with conda. If you encounter problems, please open an issue in this repo, tagging @traversaro .
