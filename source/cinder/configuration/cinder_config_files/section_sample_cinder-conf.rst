.. _cinder-conf:

Sample cinder.conf
==================

This section provides an example Cinder configuration file
(``cinder.conf``) that contains three backends - one for
SolidFire, one for ONTAP with the NFS storage protocol,
and one for ONTAP with the iSCSI storage protocol.

::

    [DEFAULT]
    rabbit_password=netapp123
    rabbit_hosts=192.168.33.40
    rpc_backend=cinder.openstack.common.rpc.impl_kombu
    notification_driver=cinder.openstack.common.notifier.rpc_notifier
    periodic_interval=60
    enable_v2_api=false
    enable_v3_api=true
    lock_path=/opt/stack/data/cinder
    state_path=/opt/stack/data/cinder
    osapi_volume_extension=cinder.api.contrib.standard_extensions
    rootwrap_config=/etc/cinder/rootwrap.conf
    api_paste_config=/etc/cinder/api-paste.ini
    sql_connection=mysql://root:netapp123@127.0.0.1/cinder?charset=utf8
    iscsi_helper=tgtadm
    my_ip=192.168.33.40
    volume_name_template=volume-%s
    verbose=True
    debug=True
    auth_strategy=keystone
    #ceilometer settings
    cinder_volume_usage_audit=True
    cinder_volume_usage_audit_period=hour
    control_exchange=cinder

    enabled_backends=solidfire,cdot-iscsi,cdot-nfs

    [solidfire]
    volume_backend_name=solidfire
    volume_driver=cinder.volume.drivers.solidfire.SolidFireDriver
    san_ip=172.17.1.182
    san_login=login
    san_password=password

    [cdot-iscsi]
    volume_backend_name=cdot-iscsi
    volume_driver=cinder.volume.drivers.netapp.common.NetAppDriver
    netapp_server_hostname=10.63.40.150
    netapp_server_port=80
    netapp_storage_protocol=iscsi
    netapp_storage_family=ontap_cluster
    netapp_login=admin
    netapp_password=netapp123
    netapp_vserver=demo-iscsi-svm

    [cdot-nfs]
    volume_backend_name=cdot-nfs
    volume_driver=cinder.volume.drivers.netapp.common.NetAppDriver
    netapp_server_hostname=10.63.40.150
    netapp_server_port=80
    netapp_storage_protocol=nfs
    netapp_storage_family=ontap_cluster
    netapp_login=admin
    netapp_password=netapp123
    netapp_vserver=demo-nfs-svm
    nfs_shares_config=/etc/cinder/nfs.shares
    nfs_mount_options=lookupcache=pos
