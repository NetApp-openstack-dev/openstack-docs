.. setup_ontap_for_cinder:

Setup Clustered ONTAP for Cinder
======================================

This section provides an example set of configuration commands to be executed
within Data ONTAP that enables two SVMs, appropriately configured for
the Cinder configuration referenced in the section called ":ref:`cinder-conf`".
Note that you may have to edit IP addresses and feature lists based on the environment and
licenses present.

Licenses
--------
    assign licenses::

        license add --license-code xxxxxxxxxxxxxx

        license add --license-code xxxxxxxxxxxxxx

Aggregates
----------
    create aggrs::

        storage aggregate create -aggregate aggr1 -diskcount 24 -nodes \
        democluster-1-01

        storage aggregate create -aggregate aggr2 -diskcount 24 -nodes \
        democluster-1-02

Storage Virtual Machines
------------------------
    create SVMs::

        vserver create -vserver demo-iscsi-svm -rootvolume vol1 \
        -aggregate aggr1 -ns-switch file -rootvolume-security-style unix

        vserver create -vserver demo-nfs-svm -rootvolume vol1 \
        -aggregate aggr2 -ns-switch file -rootvolume-security-style unix


Configure iSCSI
---------------
    iSCSI setup::

        iscsi create -vserver demo-iscsi-svm

    Networking setup::

        network interface create -vserver demo-iscsi-svm -lif \
        demo-iscsi-data -role data -data-protocol iscsi -home-node \
        democluster-1-01-e0e -home-port e0e -address 10.63.40.149 \
        -netmask 255.255.192.0

        network interface create -vserver demo-iscsi-svm -lif \
        demo-iscsi-data-e0f -role data -data-protocol iscsi -home-node \
        democluster-1-01 -home-port e0f -address 10.63.40.150 \
        -netmask 255.255.192.0

        network interface create -vserver demo-iscsi-svm -lif \
        demo-iscsi-data-e0e -role data -data-protocol iscsi -home-node \
        democluster-1-02 -home-port e0e -address 10.63.40.151 \
        -netmask 255.255.192.0

        network interface create -vserver demo-iscsi-svm -lif \
        demo-iscsi-data-e0f -role data -data-protocol iscsi -home-node \
        democluster-1-02 -home-port e0f -address 10.63.40.152 \
        -netmask 255.255.192.0

    Volume setup::

        volume create -vserver demo-iscsi-svm -volume vol1 \
        -aggregate aggr1 -size 1024g

        volume create -vserver demo-iscsi-svm -volume vol2 \
        -aggregate aggr1 -size 1024g

        volume create -vserver demo-iscsi-svm -volume vol3 \
        -aggregate aggr1 -size 1024g

        volume create -vserver demo-iscsi-svm -volume vol4 \
        -aggregate aggr1 -size 1024g

        volume create -vserver demo-iscsi-svm -volume vol5 \
        -aggregate aggr2 -size 1024g

        volume create -vserver demo-iscsi-svm -volume vol6 \
        -aggregate aggr2 -size 1024g

        volume create -vserver demo-iscsi-svm -volume vol7 \
        -aggregate aggr2 -size 1024g

        volume create -vserver demo-iscsi-svm -volume vol8 \
        -aggregate aggr2 -size 1024g

Configure NFS
-------------
    NFS Setup::

        nfs create -vserver demo-nfs-svm -access true

    Networking setup::

        network interface create -vserver demo-nfs-svm -lif node1-nfs-e0c \
        -role data -home-node democluster-1-01 -home-port e0c -address \
        10.63.41.149 -netmask 255.255.192.0

        network interface create -vserver demo-nfs-svm -lif node1-nfs-e0d \
        -role data -home-node democluster-1-01 -home-port e0d -address \
        10.63.41.150 -netmask 255.255.192.0

        network interface create -vserver demo-nfs-svm -lif node2-nfs-e0c \
        -role data -home-node democluster-1-02 -home-port e0c -address \
        10.63.41.149 -netmask 255.255.192.0

        network interface create -vserver demo-nfs-svm -lif node2-nfs-e0d \
        -role data -home-node democluster-1-02 -home-port e0d -address \
        10.63.41.150 -netmask 255.255.192.0

    Export policy rule setup::

        vserver export-policy rule create -vserver demo-nfs-svm \
        -policyname default -clientmatch 0.0.0.0/0 -rorule any -rwrule \
        any -superuser any -anon 0

    Volume setup::

        volume create -vserver demo-nfs-svm -volume vol1_dedup \
        -aggregate aggr1 -size 1024g -junction-path /vo1_dedup

        volume create -vserver demo-nfs-svm -volume vol2_compressed \
        -aggregate aggr1 -size 1024g -junction-path /vol2_compressed

        volume create -vserver demo-nfs-svm -volume vol3_mirrored \
        -aggregate aggr1 -size 1024g -junction-path /vol3_mirrored

        volume create -vserver demo-nfs-svm -volume vol3_mirror_dest \
        -aggregate aggr2 -size 1024g -type DP


    SSC features::

        volume efficiency on -vserver demo-nfs-svm -volume vol1_dedup

        volume efficiency on -vserver demo-nfs-svm -volume vol2_compressed

        volume efficiency modify -vserver demo-nfs-svm -volume \
        vol3_compressed -compression true -inline-compression true

        snapmirror create -source-path demo-nfs-svm:vol3_mirrored \
        -destination-path demo-nfs-svm:vol3_mirror_dest -type DP \
        -vserver demo-nfs-svm

        snapmirror initialize -source-path demo-nfs-svm:vol4_mirrored \
        -destination-path demo-nfs-svm:vol4_mirror_dest -type DP

    Enable NFS v4.0, v4.1, pNFS::

        nfs modify -vserver demo-nfs-svm -v4.0 enabled -v4.1 enabled \
        -v4.1-pnfs enabled
