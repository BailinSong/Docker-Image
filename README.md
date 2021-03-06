# Blueline Docker images



## [Alpine](https://github.com/BailinSong/docker-image/tree/master/alpine)

* Alpine Version 3.7.0 (Released Jun 17, 2017)


* This Docker image [(blueline/alpine)](https://hub.docker.com/r/blueline/alpine/) is based on the minimal [Alpine Linux](https://alpinelinux.org/)
* This Docker  image uses Ali as a source of updates
* Optimize software updates and installation speed for Chinese users

### What is Alpine Linux?

Alpine Linux is a Linux distribution built around musl libc and BusyBox. The image is only 5 MB in size and has access to a package repository that is much more complete than other BusyBox based images. This makes Alpine Linux a great image base for utilities and even production applications. Read more about Alpine Linux here and you can see how their mantra fits in right at home with Docker images.

----------------





## [Alpine-OpenJRE](https://github.com/BailinSong/docker-image/tree/master/alpine-openjre)

* This Docker image [(blueline/alpine_jre)](https://hub.docker.com/r/blueline/alpine-openjre/) is based on the minimal [(blueline/alpine)](https://hub.docker.com/r/blueline/alpine/)
* Add OpenJDK JRE8.

### What is OpenJDK?

The place to collaborate on an open-source implementation of the Java Platform, Standard Edition, and related projects. [(Learn more.)](http://www.planetjdk.org/faq/)

-------------------------





## [Alpine-MariaDB](https://github.com/BailinSong/docker-image/tree/master/alpine-mariadb)

* This Docker image[(blueline/alpine_mariadb)](https://hub.docker.com/r/blueline/alpine-mariadb/)  is based on the minimal [(blueline/alpine)](https://hub.docker.com/r/blueline/alpine/)
* Add [MariaDB v10.1.28](https://mariadb.org/) (MySQL Compatible) database server.
* Base on [__Github - yobasystems/alpine-mariadb__](https://github.com/yobasystems/alpine-mariadb) modification

### What is MariaDB?

MariaDB Server is one of the most popular database servers in the world. It’s made by the original developers of MySQL and guaranteed to stay open source. Notable users include Wikipedia, WordPress.com and Google.

MariaDB turns data into structured information in a wide array of applications, ranging from banking to websites. It is an enhanced, drop-in replacement for MySQL. MariaDB is used because it is fast, scalable and robust, with a rich ecosystem of storage engines, plugins and many other tools make it very versatile for a wide variety of use cases.

MariaDB is developed as open source software and as a relational database it provides an SQL interface for accessing data. The latest versions of MariaDB also include GIS and JSON features.

### Volume structure

- `/var/lib/mysql`: Database files
- `/var/lib/mysql/mysql-bin`: MariaDB logs

### Environment Variables:

#### Main Mariadb parameters:

- `MYSQL_DATABASE`: specify the name of the database
- `MYSQL_USER`: specify the User for the database
- `MYSQL_PASSWORD`: specify the User password for the database
- `MYSQL_ROOT_PASSWORD`: specify the root password for Mariadb

> https://mariadb.org/

### Creating an instance

```bash
docker run -it --name mysql -p 3306:3306 -v /var/lib/mysql:/var/lib/mysql -e MYSQL_DATABASE=wordpressdb -e MYSQL_USER=wordpressuser -e MYSQL_PASSWORD=oJudbf84J7rI95jUh3 -e MYSQL_ROOT_PASSWORD=ik78ksejIsdfqh2Jhd blueline/alpine-mariadb

```

It will create a new db, and set mysql root password (default is RaNd0MpA$$W0Rd generated by pwgen) unless the data already exists.

### Docker Compose example:

#### (Please pass your own credentials or let them be generated automatically, don't use these ones for production!!)

```yalm
mysql:
  image: blueline/alpine-mariadb
  environment:
    MYSQL_ROOT_PASSWORD: ik78ksejIsdfqh2Jhd
    MYSQL_DATABASE: wordpressdb
    MYSQL_USER: wordpressuser
    MYSQL_PASSWORD: oJudbf84J7rI95jUh3
  expose:
    - "3306"
  volumes:
    - /data/example/mysql:/var/lib/mysql
  restart: always
```

