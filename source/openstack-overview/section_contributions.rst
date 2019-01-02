NetApp's Contributions To OpenStack
===================================

A suite of NetApp drivers for OpenStack Block Storage (aka Cinder) are
built into the Icehouse release of OpenStack available from
http://www.openstack.org/software/start/.

NetApp has provided enhancements to the OpenStack Compute Service (Nova)
and OpenStack Image Service (Glance) projects to enhance instance
creation and storage efficiency as well. NetApp has also published a
reference architecture for deploying OpenStack Object Storage (Swift) on
top of NetApp's E-Series storage solutions (deprecated from Rocky release)
that reduces the overall deployment footprint and replication overhead.

NetApp additionally leads a development effort within the OpenStack
community to introduce a new core storage service developed under the
project name Manila, which adds a shared file system service to the
existing block and object storage services. This addresses a critical
gap in OpenStack’s storage services coverage and enables a new category
of on-demand file storage for Infrastructure as a Service (IaaS)
deployments. Refer to :ref:`manila` for more information on
Manila.

Where possible, NetApp intends to (and has to date) contribute
integrations upstream in OpenStack directly. NetApp’s direct
contributions to OpenStack date back to the Essex release.
