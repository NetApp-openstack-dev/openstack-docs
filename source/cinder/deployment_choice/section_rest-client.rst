Deployment Choices: REST Communication Mode
===========================================

From Zed cycle, NetApp drivers NFS, iSCSI and FCP have the option to request
ONTAP operations through REST API. By default, the drivers keep working as
before using ZAPI communication. If desired, the REST communication can be
selected. However, this REST client still relies on ZAPI calls for consistency
group snapshot operation.

.. important::

   The REST mode still relies on ZAPI for some calls, so the ONTAP
   administrative user account must have access for running ``ONTAPI``
   application even when using the drivers with REST communication mode.

.. important::

   The drivers can only be configured with REST communication with ONTAP
   storage 9.11.1 or newer.

.. caution::

   Enabling ONTAP REST client changes the behavior of QoS specs. Earlier,
   QoS values could be represented in BPS (bytes per second), but now REST
   client only supports integer values represented in MBPS (Megabytes per
   second). It means that though the operators specify the QoS value in BPS,
   it will be converted to MBPS and rounded up. It only affects new volumes.

Configuration Options
---------------------

To enable REST client for the NetApp ONTAP drivers (iSCSI, FCP or NFS), the
following option should be added to the appropriate NetApp
stanza in the Cinder configuration file (cinder.conf).

::

    [myONTAPBackend]
    netapp_use_legacy_client =  False

.. note::

   Operations running with REST client may take some time to be finished. The
   option ``netapp_async_rest_timeout`` configures the time to wait for the
   completion. Default is 60 seconds.

