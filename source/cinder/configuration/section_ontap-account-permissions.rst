.. _account-permissions:

Account Permission Considerations
=================================

The NetApp unified driver talks to ONTAP via ONTAP API and HTTP(S). At a
minimum, the ONTAP SVM administrator (vsadmin) role is required. The
cinder driver requires cluster level rights to support scheduling based
on some of the more advanced features. Such rights cannot be granted to
even the SVM administrators. The following limitations apply when using
a SVM admin role:

-  cinder volume type extra specs which cannot be used, for further
   details, see the section called ":ref:`cinder-api`" and
   the section called ":ref:`theory-op`"

-  QoS support will be disabled and hence QOS specs cannot be used when
   creating volumes (QoS\_support)

-  Disk types considerations will not be possible when creating volumes
   (netapp\_disk\_type)

-  Space Efficieny will not be considered when creating volumes
   (netapp\_dedup, netapp\_compression)

-  Headroom considerations cannot be made when creating volumes,
   effectively, goodness and filter functions are disabled.
   (filter\_function, goodness\_function)

-  Disk protection leves will not be considered when creating volume
   (netapp\_raid\_type)

For instructions on implimenting/creating storage permissions, please refer to
the section ":ref:`creating_least_privileged_role_for_a_cluster-scoped_account`"
