Deployment Choices: Image Formats ``raw`` vs. ``QCOW2``
=======================================================

Glance supports a variety of image formats; however ``raw``
and ``QCOW2`` are the most common. While ``QCOW2`` does provide
some benefits (supports copy-on-write, snapshots, dynamic expansion)
over the ``raw`` format, it should be noted that when images
are copied into Cinder volumes, they are converted into the ``raw``
format once stored on a NetApp backend.

.. note::

   Use of the ``QCOW2`` image format is recommended for ephemeral disks
   due to its inherent benefits when taking instance snapshots. Use of

.. note::

   Use of the ``raw`` image format are recommended for persistent
   boot disks. 
