#!/bin/sh

extract_xz() {
    echo "MSG: using tar for xz extract"
    tar xf ${1}
}

## parameters: 1: folder name, 2: url, 3: file name
get_and_extract() {
# download linaro cross compiler toolchain
    if [ ! -f ${1} ]; then
        echo "MSG: downloading toolchain"
        cd ${TOOLCHAIN_DIR}
    	wget -c ${2}
    fi
# extract linaro cross compiler toolchain
    echo "MSG: extracting toolchain"
    cd ${TOOLCHAIN_DIR}
    extract_xz ${3}
# install linaro gcc crosstoolchain dependency:
	sudo ${apt_cmd} -y install lib32stdc++6
}

## parameters: 1: folder name, 2: patch file name
git_patch() {
	echo "MGG: Applying patch ${2}"
	cd ${1}
	git am --signoff <  ${PATCH_SCRIPT_DIR}/${2}
}

## parameters: 1: folder name, 2: url, 3: branch name, 4: checkout options, 5: patch file name
git_fetch() {
	if [ ! -d ${CURRENT_DIR}/${1} ]; then
		echo "MSG: cloning ${2}"
		git clone ${2} ${1}
	fi

	cd ${CURRENT_DIR}/${1}
	if [ ! -z "${3}" ]; then
		git fetch origin
		git reset --hard origin/master
		echo "MSG: Will now check out " ${3}
		git checkout ${3} ${4}
		if [ ! -z "${5}" ]; then
			echo "MSG: Will now apply patch: " ${PATCH_SCRIPT_DIR}/${5}
			git_patch ${PATCH_SCRIPT_DIR}/${5}
		fi
	fi
	cd ..
}

## parameters: 1: folder name, 2: config string 3: build string
armhf_build() {
	cd ${1}
	# compile u-boot + spl
	export ARCH=arm
	export PATH=$CC_DIR/bin/:$PATH
	export CROSS_COMPILE=$CC

	echo "MSG: configuring u-boot"
	make -j${NCORES} mrproper
	make ${2}
	echo "MSG: compiling u-boot"
	make -j$NCORES ${3}
}
