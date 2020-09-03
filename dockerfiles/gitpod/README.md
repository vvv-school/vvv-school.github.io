🔽 Instructions to run the docker image locally
===============================================

This is the Docker description of the Stack of components required to run VVV School assignments on [Gitpod](https://gitpod.io).

To run the container using Docker, go through the following steps:
1. Pull the docker image:
    ```sh
    $ docker pull ghcr.io/vvv-school/gitpod:latest
    ```
1. Launch the container:
    ```sh
    $ docker run -it --rm -p 6080:6080 --user gitpod ghcr.io/vvv-school/gitpod:latest
    ```
1. From within the container shell, launch the following scripts:
    ```sh
    $ init-icubcontrib-local.sh
    $ start-vnc-session-local.sh
    ```
1. Open up the browser and connect to **`localhost:6080`** to get to the workspace desktop GUI.
1. Once done, from the container shell press **CTRL+D**.
