FROM debian:stable

MAINTAINER Yohann Lepage <yohann@lepage.info>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key update
RUN apt-get -q -y update

# Locales
RUN apt-get install -q -y locales
ADD conf/locale.gen /etc/locale.gen
RUN locale-gen
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

# Dependencies
RUN apt-get install -q -y apt-utils
RUN apt-get -q -y upgrade
RUN apt-get install -q -y python2.7 python2.7-dev python-pip curl pwgen libxml2 libxml2-dev python-libxml2 libxslt-dev python2.7-libxslt1
RUN (curl http://xmlsoft.org/sources/python/libxml2-python-2.6.21.tar.gz | tar xz \
	&& cd libxml2-python-2.6.21 \
	&& pip install . \
	&& cd /tmp && rm -rf libxml2-python-2.6.21)


RUN pip install --upgrade pip
RUN pip install uwsgi supervisor django-simple-menu

RUN mkdir -p /opt/apps
RUN (cd /opt/apps && curl -L https://github.com/siemens/django-mantis/archive/master.tar.gz |tar xz)
RUN (cd /opt/apps/django-mantis-master && pip install -r requirements.txt)

RUN (cd /opt/apps/django-mantis-master && python manage.py syncdb --noinput --traceback --settings=mantis.settings.local)
RUN (cd /opt/apps/django-mantis-master && python manage.py migrate dingos --traceback --settings=mantis.settings.local)
RUN (cd /opt/apps/django-mantis-master && python manage.py migrate mantis_core --traceback --settings=mantis.settings.local)
RUN (cd /opt/apps/django-mantis-master && python manage.py mantis_openioc_set_naming --settings=mantis.settings.local --trace)
RUN (cd /opt/apps/django-mantis-master && python manage.py mantis_stix_set_naming --settings=mantis.settings.local --trace)
RUN (cd /opt/apps/django-mantis-master && python manage.py collectstatic --noinput --settings=mantis.settings.local --trace)

RUN (cd /opt/apps/django-mantis-master && python -c "\
import os;\
os.environ['DJANGO_SETTINGS_MODULE'] = 'mantis.settings.local';\
from django.conf import settings;\
from django.contrib.auth.models import User;\
u = User(username='admin');\
u.set_password('admin');\
u.is_superuser = True;\
u.is_staff = True ;\
u.save()")

RUN chown daemon:daemon /tmp/django-mantis_test.db

ADD conf/supervisor.conf /opt/

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/supervisord"]
CMD ["-c", "/opt/supervisor.conf"]
