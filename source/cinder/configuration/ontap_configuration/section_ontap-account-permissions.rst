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
   (NetApp\_disk\_type)

-  Space Efficiency will not be considered when creating volumes
   (NetApp\_dedup, NetApp\_compression)

-  Headroom considerations cannot be made when creating volumes,
   effectively, goodness and filter functions are disabled.
   (filter\_function, goodness\_function)

-  Disk protection levels will not be considered when creating volume
   (NetApp\_raid\_type)

Create use case specific cluster admin role privileges
------------------------------------------------------
Please see ":ref:`account-permissions` before creating
security permissions in your environment.

Permissions exclusive of DR/protocol/replication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Assign the following permissions which are exclusive of DR,
   replication, and protocols, each of which will be added next::

       security login role create -role cl-limited -cmddirname vserver -access readonly
       security login role create -role cl-limited -cmddirname "system node" -access readonly
       security login role create -role cl-limited -cmddirname security -access readonly
       security login role create -role cl-limited -cmddirname "security login role" -access readonly
       security login role create -role cl-limited -cmddirname statistics -access readonly
       security login role create -role cl-limited -cmddirname "statistics catalog counter" -access readonly
       security login role create -role cl-limited -cmddirname "statistics catalog instance" -access readonly
       security login role create -role cl-limited -cmddirname "statistics catalog" -access readonly
       security login role create -role cl-limited -cmddirname "storage disk" -access readonly
       security login role create -role cl-limited -cmddirname "storage aggregate" -access readonly
       security login role create -role cl-limited -cmddirname "network interface" -access readonly
       security login role create -role cl-limited -cmddirname "volume efficiency" -access all
       security login role create -role cl-limited -cmddirname "qos policy-group" -access all
       security login role create -role cl-limited -cmddirname version -access all
       security login role create -role cl-limited -cmddirname event -access all
       security login role create -role cl-limited -cmddirname "volume file clone" -access readonly
       security login role create -role cl-limited -cmddirname "volume file clone split" -access readonly
       security login role create -role cl-limited -cmddirname "volume snapshot" -access all

Permissions required for NFS protocol
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Assign the following permissions if NetApp cinder driver is to
   support NFS::

       security login role create -role cl-limited -cmddirname "volume file" -access all

Permissions required for iSCSI and or FC protocol
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Assign the following permissions if NetApp cinder driver is to
   support iSCSI and or FC::

       security login role create -role cl-limited -cmddirname "lun" -access all
       security login role create -role cl-limited -cmddirname "lun mapping" -access all
       security login role create -role cl-limited -cmddirname "lun igroup" -access all

Permissions required for iSCSI protocol
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Assign the following permissions if NetApp cinder driver is to
   support iSCSI::

       security login role create -role cl-limited -cmddirname "vserver iscsi interface" -access all
       security login role create -role cl-limited -cmddirname "vserver iscsi security" -access all
       security login role create -role cl-limited -cmddirname "vserver iscsi" -access readonly

Permissions required for FC protocol
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Assign the following permissions if NetApp cinder driver is to
   support FC::

       security login role create -role cl-limited -cmddirname "vserver fcp portname" -access all
       security login role create -role cl-limited -cmddirname "vserver fcp interface" -access readonly
       security login role create -role cl-limited -cmddirname "vserver fcp" -access readonly

Permissions required for replication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Assign the following permissions if NetApp cinder driver is to
   support replication but not cheesecake DR::

       security login role create -role cl-limited -cmddirname snapmirror -access readonly
       security login role create -role cl-limited -cmddirname volume -access readonly

Permissions required for cheesecake
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Assign the following permissions if NetApp cinder driver is to
   support replication along with cheesecake DR::

       security login role create -role cl-limited -cmddirname "cluster peer" -access all
       security login role create -role cl-limited -cmddirname "cluster peer policy" -access all
       security login role create -role cl-limited -cmddirname "vserver peer" -access all
       security login role create -role cl-limited -cmddirname snapmirror -access all
       security login role create -role cl-limited -cmddirname volume -access all

Creating a user with appropriate permissions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Command to create user with appropriate role for api access::

       security login create -user-or-group-name openstack –application ontapi -authentication-method password –role cl-limited

   Command to create user with appropriate role for ssh access::

       security login create -user-or-group-name openstack –application ssh -authentication-method password –role cl-limited

.. note::

   Granting ssh access is required for iSCSI CHAP authentication.
   Access via ssh is optional otherwise.

