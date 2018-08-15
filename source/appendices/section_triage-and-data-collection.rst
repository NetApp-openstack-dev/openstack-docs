.. _triage_and_data_collection:

Triage and Data Collection
==========================

When you run into an issue with the NetApp OpenStack integrations, you may

- seek help in the
  `NetApp OpenStack Communities <https://community.netapp.com>`_ site, or
- open a support request through the
  `NetApp Support portal <https://support.netapp.com>`_, or
- contact your NetApp account representative.

OpenStack log and configuration files provide information that aid in triaging
bugs. As a rule of thumb log files need to be collected for the processes
that were involved. You may enable logging at the ``debug`` level and
attempt to reproduce the issue to trace through the logs. The option to
toggle debug logging is called ``debug`` in the respective configuration
file. This option defaults to ``False`` and can be set to ``True`` when
troubleshooting.

Be aware that debug logging will result in bloated log files and is
typically turned off except when identifying root cause for failures or
unexpected behavior. Also be aware of log rotation settings and attempt to
collate archived log files as necessary.

If using Cinder, the following processes log into individual files:

-  ``cinder-api``

-  ``cinder-backup``

-  ``cinder-scheduler``

-  ``cinder-volume``

.. note::

   When using ONTAP as your block storage back end, you can add the following
   lines to your NetApp backend stanza(s) in cinder.conf to capture more
   debug logging around the driver’s interaction with ONTAP in the
   cinder-volume log::

    trace_flags = method,api

.. note::

   To trace specific ONTAP APIs, add the following line to your NetApp backend
   stanza(s) in cinder.conf. The following line lists all APIs beginning with
   ``volume``::

    netapp_api_trace_pattern = ^volume-.*$

.. note::

   To trace all ONTAP APIs with exception of those beginning with ``perf``
   add the following line to your NetApp backend stanza(s) in cinder.conf::

    netapp_api_trace_pattern = ^(?!(perf)).*$

If using Manila, the following processes log into individual files:

-  ``manila-api``

-  ``manila-scheduler``

-  ``manila-share``

-  ``manila-data``

.. note::

   When using ONTAP as your shared filesystems storage back end, you can add
   the following lines to your NetApp backend stanza(s) in manila.conf to
   capture more debug logging around the driver’s interaction with ONTAP in
   the manila-share log::

    netapp_trace_flags = method,api

.. note::

   To trace specific ONTAP APIs, add the following line to your NetApp
   backend stanza(s) in manila.conf::

    netapp_api_trace_pattern  =  ^volume-.*$

.. note::

   To trace all ONTAP APIs with exception of those that start with
   ``perf``, add the following line to your NetApp backend
   stanza(s) in manila.conf::

    netapp_api_trace_pattern  =  ^(?!(perf)).*$

If using Nova, the following processes log into individual files:

-  ``nova-api``

-  ``nova-scheduler``

-  ``nova-cpu``

If using Glance, the following processes log into individual files:

-  ``glance-api``

-  ``glance-registry``

If using Swift, the following processes log into individual files:

-  ``swift-object-server``

-  ``swift-object-replicator``

-  ``swift-object-updator``

-  ``swift-object-auditor``

-  ``swift-container-server``

-  ``swift-container-replicator``

-  ``swift-container-updator``

-  ``swift-container-auditor``

-  ``swift-account-server``

-  ``swift-account-replicator``

-  ``swift-account-auditor``

Besides log files, a support engineer would ask you to provide your
Configuration files, with any sensitive information removed as necessary.
The default location of the configuration files are in ``/etc`` directory
on the controller nodes running those processes. For example, the default
configuration files for Cinder are in ``/etc/cinder/`` directory.
