.. _triage_and_data_collection:

Triage and Data Collection
==========================

Please use the NetApp OpenStack Communities site to track or report
issues related to the NetApp drivers in Cinder and Manila. When an issue is
encountered, log files provide information that may aid in triaging. As a
rule of thumb Logs files need to be collected for the processes that were
involved. You may enable debug logging and attempt to reproduce the issue to
trace through the logs. The option to toggle debug logging is called ``debug``
in the respective configuration file. This option defaults to ``False`` and
can be set to ``True`` when troubleshooting.

If using Cinder, the following processes log into individual files:

-  ``cinder-api``

-  ``cinder-backup``

-  ``cinder-scheduler``

-  ``cinder-volume``

.. note::

   When using ONTAP as your block storage back end, you can add the following
   line to your NetApp backend stanza(s) in cinder.conf to capture more
   debug logging around the driver’s interaction with ONTAP in the
   cinder-volume log::

    ``trace_flags`` = method,api

   Please note that this tends to bloat up the log files and hence you
   should only do this for problem resolution.

If using Manila, the following processes log into individual files:

-  ``manila-api``

-  ``manila-scheduler``

-  ``manila-share``

- ``manila-data``

.. note::

   When using ONTAP as your shared filesystems storage back end, you can add
   the following line to your NetApp backend stanza(s) in manila.conf to
   capture more debug logging around the driver’s interaction with ONTAP in
   the manila-share log::

    ``netapp_trace_flags`` = method,api

   Please note that this tends to bloat up the log files and hence you
   should only do this for problem resolution.

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
