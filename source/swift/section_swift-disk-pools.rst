Disk Pools, Volumes, and Mapping
================================

Disk pools should be created and sized based on the number of object
storage nodes connecting to the storage subsystem. A minimum of 11
drives per drive pool is required, but the recommended number of drives
in a drive pool is equal to ``N``, where ``N`` is the total number of
drives in the storage subsystem divided by the total number of attached
object storage nodes.

Assuming no SSD drives are present, create 3 volumes of equal capacity
on each drive pool. Be sure to select the “Map Later” option to ensure
the mapping to a host takes place after all volumes are created. If SSDs
are present, be sure to create separate disk pools that only contain
SSDs. Swift documentation recommends that SSDs be leveraged for account
and container type objects.

The default mapping for volumes to hosts (via LUN mapping) is to expose
all volumes to all hosts. To ensure multiple hosts are not accessing the
same LUN concurrently, it is recommended that each volume be explicitly
mapped to the WWN for the appropriate host it should connect to. If the
default mapping is utilized, extreme care must be exercised to ensure
the correct mapping is retained to prevent data corruption.
