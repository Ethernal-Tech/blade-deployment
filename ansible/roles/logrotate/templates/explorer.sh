#!/bin/bash

sudo chown root:root /var/log

echo "/var/log/syslog {
    rotate 3
	create
    hourly
    missingok
    notifempty
    delaycompress
    compress
    postrotate
       sudo /usr/lib/rsyslog/rsyslog-rotate
    endscript
}" | sudo tee /etc/logrotate.d/custom_logrotate_hourly.conf >/dev/null

(crontab -l 2>/dev/null | grep -Fq "*/20 * * * * logrotate -f /etc/logrotate.d/custom_logrotate_hourly.conf") || (crontab -l 2>/dev/null; echo "*/20 * * * * logrotate -f /etc/logrotate.d/custom_logrotate_hourly.conf") | crontab -
