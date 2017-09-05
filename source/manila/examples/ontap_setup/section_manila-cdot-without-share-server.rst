Setup ONTAP: Without Share Server
=================================

This section provides an example set of configuration commands to
be executed within ONTAP that enables one SVM appropriately
configured for the Manila configuration referenced in the section
called ":ref:`manila-conf-ex`". Note that you may have to edit IP
addresses and feature lists based on the environment and licenses
present.


Licenses
--------
    Assign licenses

    ::

        license add --license-code xxxxxxxxxxxxxx

        license add --license-code xxxxxxxxxxxxxx


Aggregates
----------
    Create aggrs

    ::

        storage aggregate create -aggregate aggr1 -diskcount 24 \
        -nodes cluster-1-01

        storage aggregate create -aggregate aggr2 -diskcount 24 \
        -nodes cluster-1-02

Storage Virtual Machines
------------------------
    Create SVMs

    ::

        vserver create -vserver manila-vserver -rootvolume vol1 \
        -aggregate aggr1 -ns-switch file -rootvolume-security-style unix

Configure NFS
-------------
    Setup NFS

    ::
        nfs create -vserver manila-vserver -access true

    Setup networking

    ::

        network interface create -vserver manila-vserver \
        -lif manila-nfs-data -role data -home-node cluster-1-02 \
        -home-port e0d -address 10.63.40.153 -netmask 255.255.192.0

    Setup export policy rule

    ::

        vserver export-policy rule create -vserver manila-vserver \
        -policyname default -clientmatch 0.0.0.0/0 -rorule any -rwrule \
        any -superuser any -anon 0

    Enable v4.0, v4.1, pNFS

    ::

        nfs modify -vserver manila-vserver -v4.0 enabled -v4.1 enabled \
        -v4.1-pnfs enabled

Assign Aggregates
-----------------
    Assign aggregates to SVM

    ::

        vserver modify -vserver manila-vserver -aggr-list aggr1,aggr2
