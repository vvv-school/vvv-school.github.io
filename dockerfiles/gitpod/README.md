This is the Docker description of the Stack of components required to run VVV School assignments on [Gitpod](https://gitpod.io).

To run the container using Docker, go through the following steps:
1. Pull the docker image:
    ```sh
    $ docker pull docker.pkg.github.com/vvv-school/vvv-school.github.io/gitpod:{tag}
    ```
    ⚠ You may need to [authenticate to GitHub Packages][1] beforehand.
1. Launch the container:
    ```sh
    $ docker run -it --rm -p 6080:6080 --user gitpod docker.pkg.github.com/vvv-school/vvv-school.github.io/gitpod:{tag}
    ```
1. From within the container shell, launch the following scripts:
    ```sh
    $ init-icubcontrib-local.sh
    $ start-vnc-session-local.sh
    ```
1. Open up the browser and connect to **`localhost:6080`**.
1. Once done, from the container shell press **CTRL+D**.

[1]: https://docs.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-docker-for-use-with-github-packages#authenticating-to-github-packages
