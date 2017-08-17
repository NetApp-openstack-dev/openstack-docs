Overview
========

The OpenStack Shared File System (Manila) service provides management of
persistent shared file system resources. The Shared File System service
was originally conceived as an extension to the Block Storage service
(Cinder), but emerged as an official, independent project in the Grizzly
release.

Manila is typically deployed in conjunction with other OpenStack
services (e.g. Compute, Object Storage, Image, etc) as part of a larger,
more comprehensive cloud infrastructure. This is not an explicit
requirement, as Manila has been successfully deployed as a standalone
solution for shared file system provisioning and lifecycle management.

.. tip::
   As a management service, Manila controls the provisioning and
   lifecycle management of shared filesystems. It does not reside in
   the I/O (data) path between clients and the storage controller
   hosting the filesystem.
