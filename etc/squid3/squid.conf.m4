#acl all src 0.0.0.0/0.0.0.0
acl manager proto cache_object
acl localhost src 127.0.0.0/23
acl our_networks src 10.0.0.0/8 172.16.0.0/12 127.0.0.0/23
acl to_localhost dst 127.0.0.0/8
acl SSL_ports port 443		# https
acl SSL_ports port 563		# snews
acl SSL_ports port 873		# rsync
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http
acl Safe_ports port 631		# cups
acl Safe_ports port 873		# rsync
acl Safe_ports port 901		# SWAT
acl purge method PURGE
acl CONNECT method CONNECT

acl snmp snmp_community squidsnmp

icp_access allow all
icp_port 3130
## typically automatic - MILLISECONDS
icp_query_timeout 1000

## this effectively disables peer sharing
#always_direct allow all

http_access allow manager localhost
http_access deny manager
http_access allow purge localhost
http_access deny purge
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow our_networks
http_access deny all
http_reply_access allow all

## wait this long to declare a peer cache as "dead"
#dead_peer_timeout 3

# basically acting as an accelerator ("reverse" proxy) for google sites
http_port 80 defaultsite=kh.google.com vhost
cache_peer khmdb.google.com parent 80 0 no-query no-digest originserver name=googlekhm
cache_peer_domain googlekhm khmdb.google.com
cache_peer mw1.google.com parent 80 0 no-query no-digest originserver name=googlemw1
cache_peer_domain googlemw1 mw1.google.com
cache_peer mw2.google.com parent 80 0 no-query no-digest originserver name=googlemw2
cache_peer_domain googlemw2 mw2.google.com
cache_peer cbk0.google.com parent 80 0 no-query no-digest originserver name=googlecbk0
cache_peer_domain googlecbk0 cbk0.google.com
cache_peer kh.google.com parent 80 0 no-query no-digest originserver name=googlekh
cache_peer_domain googlekh kh.google.com
# we can use light-weight GET of robots.txt to monitor squid3
cache_peer www.endpoint.com parent 80 0 no-query no-digest originserver name=endpoint
cache_peer_domain endpoint www.endpoint.com

# display node cache peers
__CACHE_PEERS__

cache_mem 1024 MB
maximum_object_size_in_memory 64 KB
cache_dir aufs /var/spool/squid3 40000 256 256

#SNMP Opts
#snmp_incoming_address 10.42.42.1
snmp_port 3401
snmp_access allow snmp our_networks
snmp_access deny all

#LOG Opts
# use "-s -l local4" for syslog cache log
cache_log /dev/null
access_log syslog:local5 squid
cache_store_log none

client_db off
via off
strip_query_terms off
refresh_pattern ^http://www\.endpoint\.com/	0	0%	0
refresh_pattern ^http://kh\.google\.com/	2880	90%	21600 override-expire reload-into-ims ignore-private
refresh_pattern ^http://khmdb\.google\.com/dbRoot\.  0	0%	0
refresh_pattern ^http://khmdb\.google\.com/	2880	90%	21600 override-expire reload-into-ims ignore-private
refresh_pattern ^http://mw1\.google\.com/	2880	90%	21600 override-expire reload-into-ims ignore-private
refresh_pattern ^http://mw2\.google\.com/	2880	90%	21600 override-expire reload-into-ims ignore-private
refresh_pattern ^http://cbk0\.google\.com/  2880    90% 21600 override-expire reload-into-ims
refresh_pattern ^ftp:		1440	20%	10080
#refresh_pattern (cgi-bin|\?)	0	0%	0
refresh_pattern .		0	20%	4320
quick_abort_min 0 KB
quick_abort_max 9999 MB
quick_abort_pct 50
#acl apache rep_header Server ^Apache
#broken_vary_encoding allow apache
#collapsed_forwarding on
#extension_methods REPORT MERGE MKACTIVITY CHECKOUT
connect_timeout 5 seconds
request_timeout 5 seconds
shutdown_lifetime 1 seconds
#visible_hostname 10.42.42.1
digest_rebuild_period 3 minutes
hosts_file /etc/hosts.squid
coredump_dir /var/spool/squid3
