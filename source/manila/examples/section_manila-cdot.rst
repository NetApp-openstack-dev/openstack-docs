Clustered Data ONTAP
--------------------

This section provides an example configuration script to be executed
within Data ONTAP that enables one SVM appropriately configured for the
Manila configuration referenced in
`section\_title <#manila.examples.manila_conf.single_svm>`__. Note that
you may have to edit IP addresses and feature lists based on the
environment and licenses present.

::

    # create aggrs
    storage aggregate create -aggregate aggr1 -diskcount 24 \
    -nodes cluster-1-01

    storage aggregate create -aggregate aggr2 -diskcount 24 \
    -nodes cluster-1-02

    # create SVMs
    vserver create -vserver manila-vserver -rootvolume vol1 \
    -aggregate aggr1 -ns-switch file -rootvolume-security-style unix

    # NFS setup
    nfs create -vserver manila-vserver -access true
    network interface create -vserver manila-vserver \
    -lif manila-nfs-data -role data -home-node cluster-1-02 \
    -home-port e0d -address 10.63.40.153 -netmask 255.255.192.0

    vserver export-policy rule create -vserver manila-vserver \
    -policyname default -clientmatch 0.0.0.0/0 -rorule any -rwrule \
    any -superuser any -anon 0

    # enable v4.0, v4.1, pNFS
    nfs modify -vserver manila-vserver -v4.0 enabled -v4.1 enabled \
    -v4.1-pnfs enabled

    # assign aggregates to vserver
    vserver modify -vserver manila-vserver -aggr-list aggr1,aggr2
