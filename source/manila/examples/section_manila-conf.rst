.. _manila-conf-ex:

``manila.conf``
===============

This section provides an example Manila configuration file
(``manila.conf``) that contains three backends - for clustered Data
ONTAP. Two without share server management. One with share server
management.

::

    [keystone_authtoken]
    signing_dir = /var/cache/manila
    admin_password = nomoresecrete
    admin_user = manila
    admin_tenant_name = service
    auth_protocol = http
    auth_port = 35357
    auth_host = 10.236.168.134

    [DEFAULT]
    rabbit_userid = stackrabbit
    rabbit_password = stackqueue
    rabbit_hosts = 10.236.168.134
    rpc_backend = rabbit
    enabled_share_backends = cdotSingleSVM01, cdotSingleSVM02, cdotMultipleSVM
    enabled_share_protocols = NFS,CIFS
    neutron_admin_password = nomoresecrete
    default_share_type = default
    state_path = /opt/stack/data/manila
    osapi_share_extension = manila.api.contrib.standard_extensions
    rootwrap_config = /etc/manila/rootwrap.conf
    api_paste_config = /etc/manila/api-paste.ini
    share_name_template = share-%s
    scheduler_driver = manila.scheduler.drivers.filter.FilterScheduler
    debug = True
    auth_strategy = keystone

    [DATABASE]
    connection = mysql://root:stackdb@127.0.0.1/manila?charset=utf8

    [oslo_concurrency]
    lock_path = /opt/stack/manila/manila_locks

    [cdotSingleSVM01]
    share_backend_name = cdotSingleSVM01
    share_driver = manila.share.drivers.netapp.common.NetAppDriver
    driver_handles_share_servers = False
    netapp_storage_family = ontap_cluster
    netapp_server_hostname = 10.63.40.150
    netapp_server_port = 443
    netapp_login = admin
    netapp_password = netapp1!
    netapp_vserver = manila-vserver-1
    netapp_transport_type = https
    netapp_aggregate_name_search_pattern = ^((?!aggr0).)*$

    [cdotSingleSVM02]
    share_backend_name = cdotSingleSVM02
    share_driver = manila.share.drivers.netapp.common.NetAppDriver
    driver_handles_share_servers = False
    netapp_storage_family = ontap_cluster
    netapp_server_hostname = 10.63.40.151
    netapp_server_port = 443
    netapp_login = admin
    netapp_password = netapp1!
    netapp_vserver = manila-vserver-2
    netapp_transport_type = https
    netapp_aggregate_name_search_pattern = ^((?!aggr0).)*$

    [cdotMultipleSVM]
    share_backend_name = cdotMultipleSVM
    share_driver = manila.share.drivers.netapp.common.NetAppDriver
    driver_handles_share_servers = True
    netapp_storage_family = ontap_cluster
    netapp_server_hostname = hostname
    netapp_server_port = 443
    netapp_login = admin
    netapp_password = netapp1!
    netapp_transport_type = https
    netapp_root_volume_aggregate = aggr1
    netapp_aggregate_name_search_pattern = ^((?!aggr0).)*$

``manila.conf`` with Replication
--------------------------------

This section provides an example Manila configuration file
(``manila.conf``) that contains one backend, ``cdotSingleSVM1``, that is
in the same replication domain as ``cdotSingleSVM02``. Therefore, both
backends must include their configuration stanzas so that
``cdotSingleSVM01`` can communicate with ``cdotSingleSVM02`` in order to
manage replication on ONTAP as needed; even though the only enabled
backend for this Manila share service instance is ``cdotSingleSVM01``.

.. important::

   SVM names must be unique, even accross clusters, in order to
   support replication between them.

::

    [keystone_authtoken]
    signing_dir = /var/cache/manila
    admin_password = nomoresecrete
    admin_user = manila
    admin_tenant_name = service
    auth_protocol = http
    auth_port = 35357
    auth_host = 10.236.168.134

    [DEFAULT]
    rabbit_userid = stackrabbit
    rabbit_password = stackqueue
    rabbit_hosts = 10.236.168.134
    rpc_backend = rabbit
    enabled_share_backends = cdotSingleSVM01
    enabled_share_protocols = NFS,CIFS
    neutron_admin_password = nomoresecrete
    default_share_type = default
    state_path = /opt/stack/data/manila
    osapi_share_extension = manila.api.contrib.standard_extensions
    rootwrap_config = /etc/manila/rootwrap.conf
    api_paste_config = /etc/manila/api-paste.ini
    share_name_template = share-%s
    scheduler_driver = manila.scheduler.filter_scheduler.FilterScheduler
    debug = True
    auth_strategy = keystone
    replica_state_update_interval = 300

    [DATABASE]
    connection = mysql://root:stackdb@127.0.0.1/manila?charset=utf8

    [oslo_concurrency]
    lock_path = /opt/stack/manila/manila_locks

    [cdotSingleSVM01]
    share_backend_name = cdotSingleSVM01
    share_driver = manila.share.drivers.netapp.common.NetAppDriver
    driver_handles_share_servers = False
    netapp_storage_family = ontap_cluster
    netapp_server_hostname = 10.63.40.150
    netapp_server_port = 80
    netapp_login = admin
    netapp_password = netapp1!
    netapp_vserver = manila-vserver-1
    netapp_transport_type = http
    netapp_aggregate_name_search_pattern = ^((?!aggr0).)*$
    replication_domain = replication_domain_1

    [cdotSingleSVM02]
    share_backend_name = cdotSingleSVM02
    share_driver = manila.share.drivers.netapp.common.NetAppDriver
    driver_handles_share_servers = False
    netapp_storage_family = ontap_cluster
    netapp_server_hostname = 10.63.40.151
    netapp_server_port = 80
    netapp_login = admin
    netapp_password = netapp1!
    netapp_vserver = manila-vserver-2
    netapp_transport_type = http
    netapp_aggregate_name_search_pattern = ^((?!aggr0).)*$
    replication_domaid = replication_domain_1
