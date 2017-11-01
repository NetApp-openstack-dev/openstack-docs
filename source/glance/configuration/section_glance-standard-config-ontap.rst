.. _glance-ontap-config:

Basic Configuration of Glance Using ONTAP as a Glance Backing Store
===================================================================

By specifying the value of ``filesystem_store_datadir`` to be a
directory that is the mount point for an NFS share that is served from a
NetApp FlexVol volume, you can have a single filesystem that can be
mounted from one or more ``glance-registry`` servers.

::

   $ vim /etc/glance/glance-api.conf
   ...
   ...
   filesystem_store_datadir=/var/lib/glance/images/
   ...

.. warning::

   The NFS mount for the ``filesystem_store_datadir`` is not managed by
   Glance; therefore, you must use the standard Linux mechanisms (e.g.
   ``/etc/fstab`` or NFS automounter) to ensure that the NFS mount
   exists before Glance starts.

.. tip::

   Be sure to refer to the `ONTAP NFS Best Practices and
   Implementation
   Guide <http://www.netapp.com/us/system/pdf-reader.aspx?pdfuri=tcm:10-61288-16&m=tr-4067.pdf>`__
   for information on how to optimally set up the NFS export for use
   with Glance, and `NetApp Data Compression and Deduplication
   Deployment and Implementation
   Guide <http://www.netapp.com/us/system/pdf-reader.aspx?pdfuri=tcm:10-60107-16&m=tr-3958.pdf>`__.
