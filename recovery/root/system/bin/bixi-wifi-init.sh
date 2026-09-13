#!/system/bin/sh

# Bixi/peach_v2 Wi-Fi bring-up. Kept outside init's boot actions so a failed
# module or firmware request leaves TWRP and USB adb available for diagnosis.
LOG=/tmp/bixi-wifi.log
MODDIR=/tmp/vendor/lib/modules
RFKILL=/system/lib/modules/rfkill.ko
FS_READY=/sys/devices/platform/soc/b0000000.qcom,cnss-peach/fs_ready

echo "bixi-wifi: begin" > "$LOG"

fail() {
    echo "bixi-wifi: $*" >> "$LOG"
    setprop twrp.wifi.driver.ready false
    setprop twrp.wifi.userspace.ready false
    exit 1
}

signal_driver_ready() {
    setprop twrp.wifi.driver.ready true
    if [ -x /system/bin/wpa_supplicant ]; then
        mkdir -p /tmp/recovery/sockets
        chown wifi:wifi /tmp/recovery/sockets
        chmod 0770 /tmp/recovery/sockets
        setprop twrp.wifi.userspace.ready true
    else
        echo "bixi-wifi: driver ready, but /system/bin/wpa_supplicant is missing" >> "$LOG"
        setprop twrp.wifi.userspace.ready false
    fi
}

load_module() {
    module="$1"
    path="$2"
    if grep -q "^$module " /proc/modules; then
        echo "bixi-wifi: already loaded $module" >> "$LOG"
        return 0
    fi
    echo "bixi-wifi: insmod $path" >> "$LOG"
    [ -f "$path" ] || fail "missing module $path"
    insmod "$path" >> "$LOG" 2>&1 || fail "insmod failed: $module"
}

if [ -d /sys/class/net/wlan0 ]; then
    echo "bixi-wifi: wlan0 already present" >> "$LOG"
    signal_driver_ready
    exit 0
fi

[ -d "$MODDIR" ] || fail "vendor modules were not staged at $MODDIR"
[ -f /system/etc/firmware/wlan/qca_cld/peach_v2/WCNSS_qcom_cfg.ini ] ||
    fail "missing bixi peach_v2 firmware configuration"
[ -f /firmware/image/peach/amss20.bin ] ||
    fail "modem firmware is missing or unreadable at /firmware"

# This is the order validated with live adb in bixi recovery. Only rfkill is
# bundled: its 6.6.77 binary must match the boot kernel; vendor modules are
# taken from TWRP's staged vendor_dlkm files for the currently installed ROM.
load_module cnss_prealloc "$MODDIR/cnss_prealloc.ko"
load_module rfkill "$RFKILL"
load_module cfg80211 "$MODDIR/cfg80211.ko"
load_module smem_mailbox "$MODDIR/smem-mailbox.ko"
load_module cnss_nl "$MODDIR/cnss_nl.ko"
load_module cnss_utils "$MODDIR/cnss_utils.ko"
load_module cnss_plat_ipc_qmi_svc "$MODDIR/cnss_plat_ipc_qmi_svc.ko"
load_module wlan_firmware_service "$MODDIR/wlan_firmware_service.ko"
load_module gsim "$MODDIR/gsim.ko"
load_module rmnet_mem "$MODDIR/rmnet_mem.ko"
load_module ipam "$MODDIR/ipam.ko"
load_module cnss2 "$MODDIR/cnss2.ko"

[ -e "$FS_READY" ] || fail "cnss2 did not expose fs_ready"
echo 1 > "$FS_READY" || fail "could not notify cnss2 of mounted firmware"
sleep 2
load_module qca_cld3_peach_v2 "$MODDIR/qca_cld3_peach_v2.ko"

i=0
while [ "$i" -lt 30 ]; do
    if [ -d /sys/class/net/wlan0 ]; then
        echo "bixi-wifi: wlan0 ready" >> "$LOG"
        signal_driver_ready
        exit 0
    fi
    sleep 1
    i=$((i + 1))
done
fail "wlan0 did not appear within 30 seconds"
