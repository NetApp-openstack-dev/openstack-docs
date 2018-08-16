.. _cinder:

Cinder.conf: Overview
=====================

Cinder is configured by changing the contents of the ``cinder.conf``
file and restarting all of the Cinder processes. Depending on the
OpenStack distribution used, this may require issuing commands such as
``systemctl openstack-cinder-api restart`` or
``systemctl cinder-api restart``.

The ``cinder.conf`` file contains a set of configuration options (one
per line), specified as ``option_name``\ =value. Configuration options
are grouped together into a stanza, denoted by ``[stanza_name]``. There
must be at least one stanza named ``[DEFAULT]`` that contains
configuration parameters that apply generically to Cinder (and not to
any particular backend). Configuration options that are associated with
a particular Cinder backend should be placed in a separate stanza.

.. note::

   Block Storage V2 API has been deprecated. To ensure Cinder does not
   use the V2 API, update ``enable_v2_api=false`` and ``enable_v3_api=true``
   in your cinder.conf file.

.. note::

   While it is possible to specify driver-specific configuration
   options within the ``[DEFAULT]`` stanza, you are unable to define
   multiple Cinder backends within the ``[DEFAULT]`` stanza. NetApp
   strongly recommends that you specify driver-specific configuration
   in separate named stanzas, being sure to list the backends that
   should be enabled as the value for the configuration option
   ``enabled_backends``; for example::

       enabled_backends=myNfsBackend,myIscsiBackend,myFCBackend,myESeriesBackend

   The ``enabled_backends`` option should be specified within the
   ``[DEFAULT]`` configuration stanza.
