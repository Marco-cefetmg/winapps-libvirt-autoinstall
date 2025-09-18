#!/bin/bash

# Configuration variables
VM_NAME="windows-vm"
RAM_SIZE=1024
VCPUS=2
DISK_SIZE=16
WIN_ISO="./en-us_windows_10_iot_enterprise_version_22h2_x64_dvd_51cc370f.iso"
VIRTIO_ISO="./virtio-win.iso"
AUTOUNATTENDED_XML="./Scripts/autounattend.xml"
AUTOUNATTENDED_ISO="/tmp/autounattend.iso"

# Cleanup
function cleanup {
	echo "Cleaning up..."
	virsh destroy "$VM_NAME" 2>/dev/null
	virsh undefine "$VM_NAME" --nvram 2>/dev/null
	sudo rm -f /var/lib/libvirt/images/"$VM_NAME".qcow2
	sudo rm -f "$AUTOUNATTENDED_ISO"
}

if [[ $1 == "-c" ]]; then
	echo "Cleanup mode activated."
	cleanup
	exit 1
fi


# Checks if the WIN_ISO file exists, if not, downloads it
if [ ! -f "$WIN_ISO" ]; then
    echo "File $WIN_ISO not found. Searching..."
    WIN_ISO=$(find . -maxdepth 1 -type f -iname "*windows*.iso" -exec readlink -f {} \;)
    if [ $? == 0 ]; then
        echo "File $WIN_ISO found."
    fi
else
    echo "$WIN_ISO found."
fi

# Checks if the VIRTIO_ISO file exists, if not, downloads it
if [ ! -f "$VIRTIO_ISO" ]; then
    echo "File $VIRTIO_ISO not found. Downloading..."
    VIRTIO_ISO="virtio-win.iso"
    wget -O "$VIRTIO_ISO" "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso" || {
        echo "Error downloading $VIRTIO_ISO."
        exit 1
    }
else
    echo "$VIRTIO_ISO found."
fi

# Create ISO with autounattended.xml
echo "Creating autounattend ISO..."
mkisofs -o "$AUTOUNATTENDED_ISO" -J -r "$AUTOUNATTENDED_XML" 2>/dev/null || {
    echo "Error: Failed to create autounattend ISO. Ensure 'mkisofs' is installed."
    exit 1
}

# Create the VM using virt-install
echo "Starting VM installation..."
virt-install \
    --name "$VM_NAME" \
    --memory "$RAM_SIZE" \
    --vcpus "$VCPUS" \
    --disk size="$DISK_SIZE",bus=virtio \
    --osinfo detect=on,name=win10 \
    --clock hypervclock_present=yes,rtc_present=no,pit_present=no,kvmclock_present=no \
    --xml ./features/hyperv/@mode=passthrough \
    --network network=default,model=virtio \
    --graphics spice,listen=127.0.0.1 \
    --video virtio \
    --channel spicevmc \
	--channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
    --cdrom "$WIN_ISO" \
    --disk path="$VIRTIO_ISO",device=cdrom,bus=sata \
    --disk path="$AUTOUNATTENDED_ISO",device=cdrom,bus=sata \
    --boot cdrom,uefi \
    --noautoconsole

for run in {1..3}; do
    virsh send-key "$VM_NAME" --codeset win32 --holdtime 1000 VK_SPACE
    sleep 1
done

echo "VM creation started. Connect with virt-viewer or virt-manager to monitor progress."

# 	--features hyperv.relaxed.state=on,hyperv.vapic.state=on,hyperv.spinlocks.state=on,hyperv.vpindex.state=on,hyperv.synic.state=on,hyperv.reset.state=on,hyperv.frequencies.state=on,hyperv.reenlightenment.state=on,hyperv.tlbflush.state=on,hyperv.ipi.state=on \
#	--clock hypervclock_present=yes,rtc_present=no,pit_present=no,hpet_present=no,kvmclock_present=no \
#	--features hyperv.relaxed.state=on,hyperv.vapic.state=on,hyperv.spinlocks.state=on,hyperv.synic.state=on,hyperv.reset.state=on\

#  hyperv.relaxed.state
#  hyperv.reset.state
#  hyperv.spinlocks.retries
#  hyperv.spinlocks.state
#  hyperv.synic.state
#  hyperv.vapic.state

#	--clock hypervclock_present=yes,rtc_present=no \
#   --clock pit_present=no,hpet_present=no,kvmclock_present=no \

#  hpet_present
#  hypervclock_present
#  kvmclock_present
#  offset
#  pit_present
#  pit_tickpolicy
#  platform_present
#  rtc_present
#  rtc_tickpolicy
#  timer[0-9]*.catchup.limit
#  timer[0-9]*.catchup.slew
#  timer[0-9]*.catchup.threshold
#  timer[0-9]*.frequency
#  timer[0-9]*.mode
#  timer[0-9]*.name
#  timer[0-9]*.present
#  timer[0-9]*.tickpolicy
#  timer[0-9]*.track
#  tsc_present

#    --xml ./features/hyperv/@mode=passtrough \

#    --xml ./features/hyperv/vpindex/@state=on \
#    --xml ./features/hyperv/synic/@state=on \
#    --xml ./features/hyperv/stimer/@state=on \
#    --xml ./features/hyperv/stimer/direct/@state=on \
#    --xml ./features/hyperv/reset/@state=on \
#    --xml ./features/hyperv/frequencies/@state=on \
#    --xml ./features/hyperv/reenlightenment/@state=on \
#    --xml ./features/hyperv/tlbflush/@state=on \
#    --xml ./features/hyperv/ipi/@state=on \
