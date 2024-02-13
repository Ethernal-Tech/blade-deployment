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
        {{ blade_home_dir }}/move_logs.sh
    endscript
}" | sudo tee /etc/logrotate.d/custom_logrotate_hourly.conf >/dev/null

echo "#!/bin/bash
datetime=\$(date +'%Y-%m-%d-%H')
destination=\"{{ blade_home_dir }}/logs/\$(date +'%Y/%m/%d')\"
mkdir -p {{ blade_home_dir }}/logs
mkdir -p \"\$destination\"
mv \"/var/log/syslog.1\" \"\$destination/\$datetime.log\"
/usr/lib/rsyslog/rsyslog-rotate
" | sudo tee {{ blade_home_dir }}/move_logs.sh >/dev/null

sudo chmod +x {{ blade_home_dir }}/move_logs.sh

(crontab -l 2>/dev/null | grep -Fq "0 * * * * logrotate -f /etc/logrotate.d/custom_logrotate_hourly.conf") || (crontab -l 2>/dev/null; echo "0 * * * * logrotate -f /etc/logrotate.d/custom_logrotate_hourly.conf") | crontab -
