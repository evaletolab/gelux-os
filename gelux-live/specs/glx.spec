>>> Merging x11-drivers/ati-drivers-8.14.13-r3 to /
--- /etc/
--- /etc/env.d/
>>> /etc/env.d/09ati
--- /lib/
--- /lib/modules/
--- /lib/modules/2.6.14-gentoo-r2gelux/
--- /lib/modules/2.6.14-gentoo-r2gelux/video/
>>> /lib/modules/2.6.14-gentoo-r2gelux/video/fglrx.ko
--- /opt/
--- /opt/ati/
--- /opt/ati/bin/
>>> /opt/ati/bin/fglrxinfo
>>> /opt/ati/bin/fglrx_xgamma
>>> /opt/ati/bin/fglrxconfig
>>> /opt/ati/bin/fireglcontrolpanel
--- /usr/
--- /usr/lib/
--- /usr/lib/modules/
--- /usr/lib/modules/dri/
>>> /usr/lib/modules/dri/atiogl_a_dri.so
>>> /usr/lib/modules/dri/fglrx_dri.so
--- /usr/lib/modules/linux/
>>> /usr/lib/modules/linux/libfglrxdrm.a
--- /usr/lib/modules/drivers/
>>> /usr/lib/modules/drivers/fglrx_drv.o
--- /usr/lib/opengl/
--- /usr/lib/opengl/ati/
>>> /usr/lib/opengl/ati/lib/
>>> /usr/lib/opengl/ati/lib/libGL.so.1.2
>>> /usr/lib/opengl/ati/lib/libGL.so -> libGL.so.1.2
>>> /usr/lib/libfglrx_gamma.so.1.0
>>> /usr/lib/libfglrx_gamma.a
--- /usr/include/
--- /usr/include/GL/
>>> /usr/include/GL/glxATI.h
--- /usr/include/X11/
--- /usr/include/X11/extensions/
>>> /usr/include/X11/extensions/fglrx_gamma.h
>>> /usr/lib/opengl/ati/lib/libGL.so.1 -> libGL.so.1.2
>>> /usr/lib/opengl/ati/extensions -> ../xorg-x11/extensions
>>> Safely unmerging already-installed instance...


>>> Merging media-video/nvidia-kernel-1.0.6629-r4 to /
--- /etc/
--- /etc/modules.d/
>>> /etc/modules.d/nvidia
--- /lib/
--- /lib/modules/
--- /lib/modules/2.6.14-gentoo-r2gelux/
--- /lib/modules/2.6.14-gentoo-r2gelux/video/
>>> /lib/modules/2.6.14-gentoo-r2gelux/video/nvidia.ko
--- /usr/
--- /usr/share/
--- /usr/share/doc/
>>> /usr/share/doc/nvidia-kernel-1.0.6629-r4/
>>> /usr/share/doc/nvidia-kernel-1.0.6629-r4/README.gz
--- /sbin/
>>> /sbin/NVmakedevices.sh


>>> Merging media-video/nvidia-glx-1.0.6629-r6 to /
--- /usr/
--- /usr/bin/
>>> /usr/bin/nvidia-bug-report.sh
--- /usr/lib/
>>> /usr/lib/libXvMCNVIDIA.so.1.0.6629
--- /usr/lib/modules/
--- /usr/lib/modules/drivers/
>>> /usr/lib/modules/drivers/nvidia_drv.o
--- /usr/lib/opengl/
>>> /usr/lib/opengl/nvidia/
>>> /usr/lib/opengl/nvidia/lib/
>>> /usr/lib/opengl/nvidia/lib/libGL.so.1.0.6629
>>> /usr/lib/opengl/nvidia/lib/libGL.la
>>> /usr/lib/opengl/nvidia/lib/libGL.so -> libGL.so.1.0.6629
>>> /usr/lib/opengl/nvidia/lib/libGLcore.so.1.0.6629
>>> /usr/lib/opengl/nvidia/tls/
>>> /usr/lib/opengl/nvidia/tls/libnvidia-tls.so.1.0.6629
>>> /usr/lib/opengl/nvidia/tls/libnvidia-tls.so -> libnvidia-tls.so.1.0.6629
>>> /usr/lib/opengl/nvidia/no-tls/
>>> /usr/lib/opengl/nvidia/no-tls/libnvidia-tls.so.1.0.6629
>>> /usr/lib/opengl/nvidia/no-tls/libnvidia-tls.so -> libnvidia-tls.so.1.0.6629
>>> /usr/lib/opengl/nvidia/extensions/
>>> /usr/lib/opengl/nvidia/extensions/libglx.so
>>> /usr/lib/opengl/nvidia/include/
>>> /usr/lib/opengl/nvidia/include/glxtokens.h
>>> /usr/lib/opengl/nvidia/include/gl.h
>>> /usr/lib/opengl/nvidia/include/glx.h
>>> /usr/lib/opengl/nvidia/include/glext.h
>>> /usr/lib/libXvMCNVIDIA.a
--- /usr/share/
--- /usr/share/doc/
>>> /usr/share/doc/nvidia-glx-1.0.6629-r6/
>>> /usr/share/doc/nvidia-glx-1.0.6629-r6/README.gz
>>> /usr/share/doc/nvidia-glx-1.0.6629-r6/XF86Config.sample.gz
>>> /usr/share/doc/nvidia-glx-1.0.6629-r6/NVIDIA_Changelog.gz
>>> /usr/lib/opengl/nvidia/lib/libGL.so.1 -> libGL.so.1.0.6629
>>> /usr/lib/opengl/nvidia/lib/libnvidia-tls.so.1.0.6629 -> ../no-tls/libnvidia-tls.so.1.0.6629
>>> /usr/lib/opengl/nvidia/lib/libnvidia-tls.so -> ../no-tls/libnvidia-tls.so
>>> /usr/lib/opengl/nvidia/lib/libGLcore.so -> libGLcore.so.1.0.6629
>>> /usr/lib/opengl/nvidia/lib/libGLcore.so.1 -> libGLcore.so.1.0.6629
>>> /usr/lib/opengl/nvidia/tls/libnvidia-tls.so.1 -> libnvidia-tls.so.1.0.6629
>>> /usr/lib/opengl/nvidia/no-tls/libnvidia-tls.so.1 -> libnvidia-tls.so.1.0.6629
>>> /usr/lib/opengl/nvidia/lib/libnvidia-tls.so.1 -> ../no-tls/libnvidia-tls.so.1
