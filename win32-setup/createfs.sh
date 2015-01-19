#create swap and home fs
#do this to avoid inutil cvs entries
dd if=/dev/zero of=gelux-1024.swap bs=1G count=1
mkswap gelux-1024.swap
gzip gelux-1024.swap
dd if=/dev/zero of=gelux-700.home bs=1M count=700
mke2fs -j gelux-700.home
gzip gelux-700.home
dd if=/dev/zero of=gelux-300.home bs=1M count=300
mke2fs -j gelux-300.home
gzip gelux-300.home
dd if=/dev/zero of=gelux-512.swap bs=1M count=512
mkswap gelux-512.swap
gzip gelux-512.swap

