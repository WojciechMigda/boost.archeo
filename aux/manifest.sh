#!/bin/bash

pushd() {
    command pushd "$@" > /dev/null
}

popd() {
    command popd "$@" > /dev/null
}

clone_boost() {
    local tag="${1}" ; shift
    local dest="${1}" ; shift

    git clone --depth 1 --branch "${tag}" https://github.com/boostorg/boost "${dest}"
    pushd "${dest}"
    git submodule update --init --recursive --depth 1
    popd
}

list_libs() {
    local dest="${1}" ; shift
    pushd "${dest}"
    LIB_LIST=`git submodule--helper list | cut -d$'\t' -f 2 | grep "^libs/"`
    popd
}

process_libs() {
    local TAG="${1}" ; shift
    local WORK_DIR="${1}" ; shift
    local LIB_LIST="${@}" ; shift

    OJSON="$(pwd)/manifest-${TAG#boost-}.json"
    echo "Will write to ${OJSON}"

    pushd "${WORK_DIR}"

    first_lib=true

    printf "[" > "${OJSON}"

    for path in ${LIB_LIST}
    do
        # path=libs/accumulators ...

        [[ -d "${path}/include/boost" ]] && {

            [[ ${first_lib} == true ]] && {
                printf '\n' >> "${OJSON}"
                first_lib=false
            } || {
                printf ',\n' >> "${OJSON}"
            }

            printf '{"lib":"%s","files":[' "${path#libs/}" >> "${OJSON}"

            first_file=true

            find "${path}/include/boost" -type f -name "*" -print0 | while read -d '' file ; do
                #echo $file
                [[ ${first_file} == true ]] && {
                    printf '\n' >> "${OJSON}"
                    first_file=false
                } || {
                    printf ',\n' >> "${OJSON}"
                }

                sha1=`sha1sum "${file}" | cut -f 1 -d ' '`
                printf '{"file":"%s","sha1":"%s"}' "${file#${path}/include/boost/}" "${sha1}" >> "${OJSON}"
            done

            printf '\n]}' >> "${OJSON}"
        }
    done

    printf "\n]\n" >> "${OJSON}"

    popd
}

show_help() {
    script_name=$( basename ${BASH_SOURCE[0]} )
    echo "Usage: ${script_name} [OPTION]..."
    cat <<EOD
-h | --help         show help
--tag=TAG           boost tag for which manifest is requested, e.g. boost-1.80.0
--dir=DIRECTORY     work folder into which boost should be cloned using git
-c | --clean        remove work folder after manifest is created
EOD
}

run_main() {
    for i in "$@"
    do
    case ${i} in
        -c|--clean)
        CLEANUP=true
        shift
        ;;
        --tag=*)
        TAG=${i#*=}
        shift
        ;;
        --dir=*)
        WORK_DIR=${i#*=}
        shift
        ;;
        -h|--help)
        HELP=true
        shift
        ;;
        *)
        ;;
    esac
    done

    if [[ ${HELP} == true ]]; then
        show_help
        return
    fi

    if [[ -z "${TAG}" ]]; then
        echo "TAG parameter is mandatory."
        return -1
    fi

    if [[ -z "${WORK_DIR}" ]]; then
        echo "WORK_DIR parameter is mandatory."
        return -1
    fi

    clone_boost "${TAG}" "${WORK_DIR}"
    list_libs "${WORK_DIR}"

    process_libs "${TAG}" "${WORK_DIR}" "${LIB_LIST}"

    if [[ "${CLEANUP}" == true ]]; then
        echo "Cleaning up..."
        rm -rf "${WORK_DIR}"
    fi
}

run_main "$@"
exit $?
