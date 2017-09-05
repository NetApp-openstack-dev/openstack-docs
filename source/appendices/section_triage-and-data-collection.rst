.. _triage_and_data_collection:

Triage and Data Collection
==========================

Please use the NetApp OpenStack Communities site to track or report
issues related to Cinder. In case of issues, the data can be collected
from logs printed by each of the below mentioned process. Logs need to
be collected for Cinder related processes. For Glance and Nova verifying
the service up status is sufficient.

-  ``cinder-api``

-  ``cinder-backup``

-  ``cinder-scheduler``

-  ``cinder-volume``

.. note::

   You can add the following line to your NetApp backend stanza(s) in
   cinder.conf to capture much more detail about the driver’s
   interaction with Data ONTAP in the cinder-volume log:

   -  ``trace_flags``\ = method,api

   Please note that this tends to bloat up the log files and hence you
   should only do this for problem resolution.

-  ``manila-api``

-  ``manila-scheduler``

-  ``manila-share``

-  ``nova-api``

-  ``nova-scheduler``

-  ``nova-cpu``

-  ``glance-api``

-  ``glance-registry``

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
