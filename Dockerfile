FROM phusion/baseimage:0.9.22

ARG LIBRENMS_VERSION=b7a06045b01aa86e7eabef9e1018c3d34c190a2a
ENV TZ=CET
EXPOSE 80 443

RUN	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C C300EE8C && \
	echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/ondrej-php7.list && \
	echo 'deb http://ppa.launchpad.net/nginx/development/ubuntu xenial main' > /etc/apt/sources.list.d/nginx.list && \
	apt-get update && \
	apt-get -yq purge openssh-.* && \
	apt-get -yq autoremove --purge && \
	apt-get -yq dist-upgrade && \
	apt-get -yq install --no-install-recommends \
		dnsutils \
		nginx \
		php7.1-cli \
		php7.1-fpm \
		php7.1-mysql \
		php7.1-gd \
		php7.1-curl \
		php7.1-opcache \
		php7.1-ldap \
		php7.1-memcached \
		php7.1-snmp \
		php7.1-mcrypt \
		php-imagick \
		php-pear \
		php-net-ipv4 \
		php-net-ipv6 \
		snmp \
		graphviz \
		fping \
		imagemagick \
		whois \
		mtr-tiny \
		nagios-plugins \
		nmap \
		python-mysqldb \
		rrdcached \
		rrdtool \
		sendmail \
		smbclient \
		git \
		python-ipaddress \
		python-memcache \
		sudo && \
	rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/* && \
	sed -i 's/pm.max_children = 5/pm.max_children = 24/g' /etc/php/7.1/fpm/pool.d/www.conf && \
	sed -i 's/pm.start_servers = 2/pm.start_servers = 4/g' /etc/php/7.1/fpm/pool.d/www.conf && \
	sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 4/g' /etc/php/7.1/fpm/pool.d/www.conf && \
	sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 8/g' /etc/php/7.1/fpm/pool.d/www.conf && \
	sed -i 's/;clear_env/clear_env/g' /etc/php/7.1/fpm/pool.d/www.conf && \
	useradd librenms -d /opt/librenms -M -r && \
	usermod -a -G librenms www-data && \
	git clone -b master -n https://github.com/librenms/librenms.git /opt/librenms && \
	cd /opt/librenms && \
	git checkout "$LIBRENMS_VERSION" && \
	chown -R librenms:librenms /opt/librenms && \
	chmod u+s /usr/bin/fping /usr/bin/fping6 && \
	apt-get -yq autoremove --purge && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD files /
RUN	chmod -R +x /etc/my_init.d /etc/service && \
	find /opt/librenms \( ! -user librenms -o ! -group librenms \) -exec chown librenms:librenms {} \; && \
	chmod 644 /etc/cron.d/librenms

#VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/etc/nginx/ssl", "/var/log/nginx"]
