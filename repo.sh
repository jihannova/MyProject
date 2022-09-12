#!/bin/bash
    
sync () {
    cd ~/rom
    repo init --depth=1 --no-repo-verify -u ${Nusantara} -b 13 -g default,-mips,-darwin,-notdefault
    rclone copy znxtproject:NusantaraProject/manifest/13/nusantara.xml .repo/manifests/snippets -P
    rclone copy znxtproject:NusantaraProject/manifest/13/local_nad.xml .repo/local_manifests -P
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j20
    cd hardware/nad/interfaces
    git fetch https://github.com/LineageOS/android_hardware_lineage_interfaces lineage-19.1 && git cherry-pick 21e6c8c09692bb9ae21fdc6e4bc1442f6c4cd5d0
    cd ../../qcom-caf/common && git fetch https://github.com/ArrowOS/android_hardware_qcom-caf_common arrow-12.1 && git checkout FETCH_HEAD
}

build () {
     cd ~/rom
     . build/envsetup.sh
     export CCACHE_DIR=~/ccache
     export CCACHE_EXEC=$(which ccache)
     export USE_CCACHE=1
     ccache -M 50G
     ccache -z
     export BUILD_HOSTNAME=znxt
     export BUILD_USERNAME=znxt
     export TZ=Asia/Jakarta
     export SELINUX_IGNORE_NEVERALLOWS=true
     export ALLOW_MISSING_DEPENDENCIES=true
     export USE_GAPPS=true
     export NAD_BUILD_TYPE=OFFICIAL
     #export USE_PIXEL_CHARGING=true
     lunch nad_maple_dsds-userdebug
    #make sepolicy -j24
    #make bootimage -j24
    #make systemimage &
    #make installclean
    mka nad -j30
}

compile () {
    sync
    echo "done."
    build
}

push_kernel () {
  cd ~/rom/kernel/sony/ms*
  git #push github HEAD:refs/heads/cherish-12
}

push_device () {
  cd ~/rom/device/sony/maple_dsds
  git #push github HEAD:cherish-12 -f
}

push_yoshino () {
  cd ~/rom/device/sony/yos*
  git #push github HEAD:cherish-12 -f
}

push_vendor () {
  cd ~/rom/vendor/sony/maple_dsds
  git #push github HEAD:cherish-12 -f
}

cd ~/rom
ls -lh
compile &
sleep 114m
kill %1
#push_kernel
#push_device
#push_yoshino
#push_vendor

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
