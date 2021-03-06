.PHONY: fs-cleanup
fs-cleanup:
#unwanted categories
	-rm -r fs/{var,include,{share,lib}/pkgconfig}
	-rm -r fs/share/{info,man,doc,*-doc,*-completion}
	-rm -r fs/{share/{locale,i18n,licenses},lib/locale}
	-rm -r fs/lib/*.{a,la,o}
	-rm -r fs/sbin/mkfs*
#unwanted stuff
	-rm -r fs/etc/{binfmt.d,dbus-1,modules-load.d,sysctl.d,systemd,tmpfiles.d,xdg}
	-rm -r fs/lib/{binfmt.d,girepository-*,modules-load.d,python*,security,locale}
	-rm -r fs/lib/{sysctl.d,systemd,tmpfiles.d,terminfo,lib.*,gconv,audit}
	-rm -r fs/lib/{getconf,pt_chown,libcind*,libmemusage.*,libnsl*}
	-rm -r fs/lib/lib{systemd*,gudev-*,nss_*,B*,S*,anl*,cprogile,m,resolve*,util*}.*
	-rm -r fs/sbin/{*ctl,kernel-install,systemd*,locale*,mklost+found,uuid*}
	-rm -r fs/etc/{gai.conf,nscd.conf,locale.gen,rpc,pam.d}
	-rm -r fs/sbin/{addpart,agetty,attr,badblocks,cfdisk,chacl,chattr,chcpu,chfn,setterm}
	-rm -r fs/sbin/{chsh,col,colcrt,colrm,column,compile_et,ctrlaltdel,cytune,debug*}
	-rm -r fs/sbin/{delpart,dmeventd,dmsetup,dumpe2fs,e2*,e4*,fallocate,filefrag,findmnt}
	-rm -r fs/sbin/{fsfreeze,fstrim,gencat,getconf,getent,getfacl,getfattr,i386,iconv*}
	-rm -r fs/sbin/{{ins,dep,ls,rm}mod,linux*,logsave,ls{attr,blk,cpu,locks},makedb}
	-rm -r fs/lib/lib{thread_db,ss,resolv,pcprofile,m-*,crypt*,cidn*}.so*
	-rm -r fs/lib/{e2initrd_helper,depmod.d,modprobe.d,lib{resolv,thread_db}-*}
	-rm -r fs/sbin/{catchsegv,ipcmk,isosize,look,mcookie,memusage*,mk_cmds,mk*fs,mtrace}
	-rm -r fs/sbin/{nscd,partx,pcprofiledump,pg,pldd,prlimit,raw,readprofile,renice}
	-rm -r fs/sbin/{resize*,rpcgen,setfa{cl,ttr},sfdisk,sln,sotruss,sprof,swaplabel}
	-rm -r fs/sbin/{tailf,taskset,tune2fs,tunelp,tzselect,ul,unshare,utmpdump,vigr,vipw}
	-rm -r fs/sbin/{whereis,wipefs,write,x86_64,xtrace,zdump,zic,rename,newgrp,namei}
	-rm -r fs/{share,etc/{*fs.conf,depmod.d,modprobe.d,udev}}


.PHONY: clean
clean:
	-yes | rm -r fs cpiolist initramfs-linux *-*.*/ *-*.tar.*


.PHONY: clean-fs
clean-fs:
	-yes | rm -r fs

