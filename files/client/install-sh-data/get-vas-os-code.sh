#!/bin/sh
#==============================================================================
# Copyright 2025 One Identity LLC. ALL RIGHTS RESERVED.
#
# get-vas-os-code.sh
#
#     Helper script for determining SAS OS code needed to find packages
#
# Version: 6.2.0.3400
#==============================================================================
SCRIPT_NAME="get-vas-os-code.sh"

solaris_use_ips() {
    case $HOST_PKG_VARIANT in
        11|ips) return 0 ;;
        10|svr4) return 1 ;;
        *)
            if [ "$HOST_OS_VERSION" -gt 10 ]; then
                return 0
            fi
            ;;
    esac
    return 1
}

SetVASPath() {
    case $HOST_OS_NAME in
        "SunOS")
            # under solaris11-(x64/sparc) we have a solaris10 build repackaged as IPS packages
            variant=10
            if solaris_use_ips; then
                variant=11
            fi
            case $HOST_HARDWARE in
                x86_64|i386) variant=$variant-x64 ;;
                sparc) variant=$variant-sparc ;;
            esac
            HOST_PKG_PATH=solaris$variant
            return 0  # prevent appending the variant again
            ;;

        "AIX")
            case $HOST_OS_VERSION in
                    "6."*) HOST_PKG_PATH="aix-61"   ;;
                        *) HOST_PKG_PATH="aix-71"   ;;
            esac
            ;;

        "HP-UX")
            if [ "x$HOST_HARDWARE" = "xia64" ];then
                HOST_PKG_PATH="hpux-ia64"

            else
                case $HOST_OS_VERSION in
                    "11.00") HOST_PKG_PATH="hpux-pa"        ;;
                    "11.11") HOST_PKG_PATH="hpux-pa-11v1"   ;;
                          *) HOST_PKG_PATH="hpux-pa-11v3"   ;;
                esac
            fi
            ;;

        "Darwin")
            HOST_PKG_PATH="macos"
            ;;

        "Linux")
            if [ "x$HOST_HARDWARE" = "xppc" ];then
				if [ "x$HOST_OS_DISTRO" = "xSuSE" ];then
					if ( echo "$HOST_OS_VERSION" | grep "^8" > /dev/null 2>&1) ;then
						HOST_PKG_PATH="linux-glibc22-ppc64"
					else
						HOST_PKG_PATH="linux-ppc64"
					fi
				else
					HOST_PKG_PATH="linux-ppc64"
				fi
            else
                HOST_PKG_PATH="linux-$HOST_HARDWARE"
            fi
            ;;
        "FreeBSD")
            HOST_PKG_PATH="freebsd-$HOST_HARDWARE"
            ;;
        *)
            HOST_PKG_PATH=
        ;;
    esac

    if [ "$HOST_PKG_PATH" != "" ] && [ "$HOST_PKG_VARIANT" != "" ]; then
        HOST_PKG_PATH="${HOST_PKG_PATH}-${HOST_PKG_VARIANT}"
    fi
}

if [ -z "${MAIN:-}" ];then
    HOST_PKG_PATH=
    SetVASPath
    
    printf "$HOST_PKG_PATH\n"

    exit 0
fi
