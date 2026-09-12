#!/system/bin/sh

# TWRP invokes this hook after processing recovery.fstab. At this point its
# temporary logical ODM mount has been removed, exposing the recovery ramdisk
# copy of the haptics calibration library at /odm/lib64.
umount /odm 2>/dev/null || true
setprop vendor.haptic.calibrate.done 1
setprop ctl.start odm.vibratorfeature-service

exit 0
