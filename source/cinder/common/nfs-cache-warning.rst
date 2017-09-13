
.. important::

   The NFS client cache refresh interval can vary depending on how the
   NFS client's default mounting options are configured. In order to
   prevent the issue of a stale negative cache
   entry, an additional option must be passed to the NFS mount command
   invoked by the Cinder using an NFS driver. This can be configured by
   adding the line ``nfs_mount_options = lookupcache=pos`` to your
   driver configuration stanza in your cinder.conf file. Alternatively,
   if you are already setting other NFS mount options, then you can
   just add ``,lookupcache=pos`` to the end of your current
   "nfs_mount_options". The effect of this additional option is to
   force the NFS client to ignore any negative entries in its cache and
   always check the NFS host when attempting to confirm the existence
   of a file.

   Please be aware, the ``nfs_mount_options`` values are not 
   automatically applied if the export is already mounted.  In such 
   a case, the ``nfs_mount_options`` values are applied the next 
   time the export is mounted.
