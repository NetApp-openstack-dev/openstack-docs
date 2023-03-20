
.. _manila_rest_communication:

Deployment Choices: REST Communication Mode
===========================================

From Antelope cycle, NetApp driver has the option to request ONTAP operations
through REST API. By default, the driver keeps working as before using ZAPI
communication. If desired, the REST communication can be selected. However,
this REST client still relies on ZAPI calls for consistency group snapshot
operation.

.. important::

   The REST mode still relies on ZAPI for some calls, so the ONTAP
   administrative user account must have access for running ``ONTAPI``
   application even when configuring the driver with REST communication mode.

.. important::

   The driver can only be configured with REST communication with ONTAP
   storage 9.12.1 or newer.

.. caution::

   Enabling ONTAP REST client changes the behavior of QoS specs. Earlier,
   QoS values could be represented in BPS (bytes per second), but now REST
   client only supports integer values represented in MBPS (Megabytes per
   second). It means that though the operators specify the QoS value in BPS,
   it will be converted to MBPS and rounded up. It only affects new shares.

.. caution::

   If running with REST mode, the extra spec configuration
   ``netapp:udp_max_xfer_size`` is not applied.

Configuration Options
---------------------

To enable REST client for the NetApp ONTAP driver, the following option should
be added to the appropriate NetApp stanza in the Manila configuration file
(manila.conf).

::

    [myONTAPBackend]
    netapp_use_legacy_client =  False

.. note::

   Operations running with REST client may take some time to be finished. The
   option ``netapp_rest_operation_timeout`` configures the time to wait for the
   completion. Default is 60 seconds.

