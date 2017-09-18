Fio tests

These tests are based on Alex's most common profiles which include are the checked or basic mode..
this wrapper allows to select which mode you prefer, the other parameters map directly to fio toggles for block size and rw load mode.

The fio tests are currently only available in Host tests.. We can add to containers but in order to run the same device based tests
we would need to mount /var/lib/storageos:/var/lib/storageos in docker run..


