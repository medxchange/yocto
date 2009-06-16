inherit distutils-base

DISTUTILS_BUILD_ARGS ?= ""
DISTUTILS_STAGE_HEADERS_ARGS ?= "--install-dir=${STAGING_INCDIR}/${PYTHON_DIR}"
DISTUTILS_STAGE_ALL_ARGS ?= "--prefix=${STAGING_DIR_HOST}${layout_prefix} \
    --install-data=${STAGING_DATADIR}"
DISTUTILS_INSTALL_ARGS ?= "--prefix=${D}/${prefix} \
    --install-data=${D}/${datadir}"

distutils_do_compile() {
         STAGING_INCDIR=${STAGING_INCDIR} \
         STAGING_LIBDIR=${STAGING_LIBDIR} \
         BUILD_SYS=${BUILD_SYS} HOST_SYS=${HOST_SYS} \
         ${STAGING_BINDIR_NATIVE}/python setup.py build ${DISTUTILS_BUILD_ARGS} || \
         oefatal "python setup.py build_ext execution failed."
}

distutils_stage_headers() {
        install -d ${STAGING_DIR_HOST}${layout_libdir}/${PYTHON_DIR}/site-packages
        STAGING_INCDIR=${STAGING_INCDIR} \
        STAGING_LIBDIR=${STAGING_LIBDIR} \
        BUILD_SYS=${BUILD_SYS} HOST_SYS=${HOST_SYS} \
        ${STAGING_BINDIR_NATIVE}/python setup.py install_headers ${DISTUTILS_STAGE_HEADERS_ARGS} || \
        oefatal "python setup.py install_headers execution failed."
}

distutils_stage_all() {
        install -d ${STAGING_DIR_HOST}${layout_prefix}/${PYTHON_DIR}/site-packages
        STAGING_INCDIR=${STAGING_INCDIR} \
        STAGING_LIBDIR=${STAGING_LIBDIR} \
        PYTHONPATH=${STAGING_DIR_HOST}${layout_prefix}/${PYTHON_DIR}/site-packages \
        BUILD_SYS=${BUILD_SYS} HOST_SYS=${HOST_SYS} \
        ${STAGING_BINDIR_NATIVE}/python setup.py install ${DISTUTILS_STAGE_ALL_ARGS} || \
        oefatal "python setup.py install (stage) execution failed."
}

distutils_do_install() {
        install -d ${D}${libdir}/${PYTHON_DIR}/site-packages
        STAGING_INCDIR=${STAGING_INCDIR} \
        STAGING_LIBDIR=${STAGING_LIBDIR} \
        PYTHONPATH=${D}/${libdir}/${PYTHON_DIR}/site-packages \
        BUILD_SYS=${BUILD_SYS} HOST_SYS=${HOST_SYS} \
        ${STAGING_BINDIR_NATIVE}/python setup.py install ${DISTUTILS_INSTALL_ARGS} || \
        oefatal "python setup.py install execution failed."

        for i in `find ${D} -name "*.py"` ; do \
            sed -i -e s:${D}::g $i
        done

        if test -e ${D}${bindir} ; then	
            for i in ${D}${bindir}/* ; do \
                sed -i -e s:${STAGING_BINDIR_NATIVE}:${bindir}:g $i
            done
        fi

        if test -e ${D}${sbindir}; then
            for i in ${D}${sbindir}/* ; do \
                sed -i -e s:${STAGING_BINDIR_NATIVE}:${bindir}:g $i
            done
        fi

        rm -f ${D}${libdir}/${PYTHON_DIR}/site-packages/easy-install.pth
        
        find ${D}${libdir}/${PYTHON_DIR}/site-packages -iname '*.pyo' -exec rm {} \;
}

EXPORT_FUNCTIONS do_compile do_install
