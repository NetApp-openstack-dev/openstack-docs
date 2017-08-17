OpenStack Object Storage Service (Swift)
========================================

.. toctree::
   :maxdepth: 1

   swift/section_swift-overview.rst
   swift/section_swift-e-series.rst
   swift/section_swift-disk-pools.rst
   swift/section_swift-partitioning.rst
   swift/section_swift-ring-considerations.rst

OpenStack Object Storage provides a fully distributed, scale-out,
API-accessible storage platform that can be integrated directly into
applications or used for backup, archiving and data retention. Object
storage does not present a traditional file system, but rather a
distributed storage system for static data such as: virtual machine
images, photo storage, email storage, backups and archives.

The Swift API proposes an open standard for cloud storage. It can also
function as an alternative endpoint for Amazon Web Services S3 and as a
CDMI server through the use of add on components.

Swift requires node accessible media for storing object data. This media
can be drives internal to the node or external storage devices such as
the NetApp E-Series storage array. This section provides information
that enables an NetApp E-Series storage array to be used as the backing
store for Swift object storage.

For configuration of Swift accounts and usage examples, please refer to
`TR 4485: StorageGRID Webscale 10.2 and
OpenStack <https://fieldportal.netapp.com/content/280689>`__
