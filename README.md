docker-mantis
=============

Automated build of "MANTIS Cyber Threat Intelligence Management Framework" with Docker.io


Dockerfile
----------
Use this to build a new image

	$ git clone https://github.com/2xyo/docker-mantis.git
    $ sudo docker build .

With a tag for easier reuse

    $ sudo docker build  -t 2xyo/docker-mantis .

Running the container

    $ sudo docker run -d -p :8000 2xyo/docker-mantis

Get your container's IP Address:

    sudo docker inspect <container_id> | grep IPAddress | cut -d '"' -f 4

Now go to `<your container's ip>:8000/admin/` in your browser (admin:admin)

