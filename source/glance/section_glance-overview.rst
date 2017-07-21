Overview
========

The OpenStack Image Service (Glance) provides discovery, registration
and delivery services for disk and server images. The ability to copy or
snapshot a server image and immediately store it away is a powerful
capability of the OpenStack cloud operating system. Stored images can be
used as a template to get new servers up and running quickly and more
consistently if you are provisioning multiple servers than installing a
server operating system and individually configuring additional
services. It can also be used to store and catalog an unlimited number
of backups. 

Glance can store disk and server images in a variety of back-ends
(called stores), including through NFS and Object Storage (such as
StorageGRID Webscale). The Glance API provides a standard REST interface
for querying information about disk images and lets clients stream the
images to new servers. A multiformat image registry allowing uploads of
private and public images in a variety of formats.
