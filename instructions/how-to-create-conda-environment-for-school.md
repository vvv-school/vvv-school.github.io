## Conda instructions for VVV School Tutorial and Assignments

Beside the official Docker image based on the robotology-superbuild available at https://github.com/vvv-school/vvv-school.github.io/pkgs/container/gitpod, 
for some tutorial and assignments it is also possible to rely on conda to install the required dependencies.

To do so, create a dedicated conda environment with:
~~~
conda create -c conda-forge -c robotology -n vvvschool cmake ninja pkg-config make compilers yarp icub-contrib-common gazebo icub-models gazebo-yarp-plugins idyntree vvv-school-activation
~~~

Then, whenever to run a command, remember to run it in the `vvvschool` conda environment.

> [!WARNING]  
> Not all vvv-school repos may be working fine with conda. If you encounter problems, please open an issue in this repo, tagging @traversaro.
