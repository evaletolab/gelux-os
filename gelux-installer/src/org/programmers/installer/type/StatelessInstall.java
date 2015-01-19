/*
 * Created on 9 mars 2005
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * 
 * Copyright Olivier EValet at programmer.ch
 * 
 */
package org.programmers.installer.type;

import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;

import org.gnu.glade.GladeXMLException;
import org.programmers.installer.Admin;
import org.programmers.installer.DetectPartitions;
import org.programmers.installer.FS;
import org.programmers.installer.Grub;
import org.programmers.installer.InstallException;
import org.programmers.installer.InstallListener;
import org.programmers.installer.InstallRunner;
import org.programmers.installer.User;

/**
 * @author Olivier Evalet
 *
 * Stateless installation will set the system as the livecd but on harddisk
 * 1) We can use exactly the same configuration as a livecd.
 * 		/hda1/boot
 * 		/hda1/base
 * 		/hda1/maimod
 * 		/hda2/home to point on maimod
 *    This configuration is simple but it is not possible to *simply* 
 *    modify the mainmod.
 * 2) We will use the same configuration than bellow but the mainmod is 
 *    uncompressed on the mainmod directory. This solution is avantageus for addding
 *    or removing application or apply patch.   
 */
public class StatelessInstall implements InstallRunner {

	/**
	 * @throws GladeXMLException
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public StatelessInstall() {
		//Init the GUI install mode
	}
	/**
	 * doInstall is started on a thread and will setup linux on this order
	 * The check of the partitions is done by the user with the UI. The 
	 * autopart is not implemented.
	 * 
	 * 1) mount partitions
	 * 2) copy files
	 * 3) copy readonly root (mainmod) 
	 * 4) Copy grub && kernel
	 * 5) Generate grub menu
	 * 6) Create special directories ?
	 * 7) Create fstab ?
	 * 8) Create default user 
	 * 9) set default user sudo
	 *10) set default root passwd ?
	 *11) copy extra stuff (/opt)
	 */
	public static String ROOT="/mnt/gelux.install";
	//"";									//don't forget the persistant union, home
	private String GROUPS="dialout,dip,games,cdrom,video,audio,users,plugdev,lpadmin,scanner";
	
	/**
	 * Some parameters are dynamic: hostname,acpi=on/off,video,persistoverlay
	 */
	private String BOOT_PARAMS	=	" username=guest " +
									"quiet splash=silent gdm dma alsa noapic acpi=on lang=sf " +
									"ramdisk_size=100000 init=/etc/init apm=power-off vga=791 " +
									"unionfs=on initrd=miniroot.gz  BOOT_IMAGE=morphix";
	
	public void doInstall(DetectPartitions parts, Admin admin, User user, Grub grub, InstallListener callback)throws InstallException {
	    int pulser=0;
	    String home_path=parts.getHomePartition(parts.getActiveHome()).path;
	    
	    System.out.println(toString());
        callback.update("preparing the system...",pulser++,10);
        FS.mkdir(ROOT);
        if (FS.isMounted(parts.getRootPartition(parts.getActiveRoot()).path))
            FS.umount(parts.getRootPartition(parts.getActiveRoot()).path);
        if (FS.isMounted(home_path))
            FS.umount(home_path);
        
        // check if we must create the filesystem! If the filesystem 
        // name length is > 0 then there is a partition
        if (parts.getRootPartition(parts.getActiveRoot()).filesystem.length()==0){
            FS.mkreiserfs(parts.getRootPartition(parts.getActiveRoot()).path);
        }
        // This is very important to preserv data in home!!
        if (parts.getHomePartition(parts.getActiveHome()).filesystem.length()==0){
            FS.mkreiserfs(home_path);
        }
        
        FS.mkswap(parts.getSwapPartition(parts.getActiveSwap()).path);
        
        FS.mount(parts.getRootPartition(parts.getActiveRoot()).path,ROOT);
        
        // clean the insatll disk
        FS.rm("-rf",ROOT+"/*");

        // these directories are created but must be empty
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/MorphixCD");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/cdrom");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/media");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/proc");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/sys");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/tmp");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/dev");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/home");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/boot");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/mnt");
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/root");
        FS.mkdir(ROOT+"/deb");
        FS.mkdir(ROOT+"/copy");
        FS.mkdir(ROOT+"/exec");
        FS.mkdir(ROOT+"/minimod");
        
        FS.exec("chmod 666 "+ROOT+"/mainmod/mainmod.mod/tmp");
        
        // copying the stateless images
        FS.cp("-ap","/cdrom/base",ROOT);
        FS.cp("-ap","/cdrom/boot",ROOT);
        

        callback.update("installing files...",pulser++,10);
        // copying the mainmod with the merged minimod
        FS.rm("-rf",ROOT+"/mainmod/mainmod.mod/bin");
        try{
	        FS.cp("-apf","/mnt/.hidden_base/mnt/main_ro/bin",ROOT+"/mainmod/mainmod.mod/");
	}catch(InstallException ie){System.err.println(ie.getMessage());}
        callback.update("installing files...",pulser++,10);

        FS.rm("-rf",ROOT+"/mainmod/mainmod.mod/etc");
        try{
	        FS.cp("-apf","/mnt/.hidden_base/mnt/main_ro/etc",ROOT+"/mainmod/mainmod.mod/");
	}catch(InstallException ie){System.err.println(ie.getMessage());}
        callback.update("installing files...",pulser++,10);
        
        FS.rm("-rf",ROOT+"/mainmod/mainmod.mod/lib");
        try{
	        FS.cp("-apf","/mnt/.hidden_base/mnt/main_ro/lib",ROOT+"/mainmod/mainmod.mod/");
	}catch(InstallException ie){System.err.println(ie.getMessage());}
        callback.update("installing files...",pulser++,10);
        
        FS.rm("-rf",ROOT+"/mainmod/mainmod.mod/morphix");
        try{
	        FS.cp("-apf","/mnt/.hidden_base/mnt/main_ro/morphix",ROOT+"/mainmod/mainmod.mod/");
	}catch(InstallException ie){System.err.println(ie.getMessage());}
        callback.update("installing files...",pulser++,10);
        
        FS.rm("-rf",ROOT+"/mainmod/mainmod.mod/sbin");
        try{
	        FS.cp("-apf","/mnt/.hidden_base/mnt/main_ro/sbin",ROOT+"/mainmod/mainmod.mod/");
	}catch(InstallException ie){System.err.println(ie.getMessage());}
        
        FS.rm("-rf",ROOT+"/mainmod/mainmod.mod/usr");
        callback.update("installing files...",pulser++,10);
        try{
	        FS.cp("-apf","/mnt/.hidden_base/mnt/main_ro/usr",ROOT+"/mainmod/mainmod.mod/");
	}catch(InstallException ie){System.err.println(ie.getMessage());}
        callback.update("installing files...",pulser++,10);
        
        FS.rm("-rf",ROOT+"/mainmod/mainmod.mod/opt");
        try{
        	FS.cp("-apf","/mnt/.hidden_base/mnt/main_ro/opt",ROOT+"/mainmod/mainmod.mod/");
	}catch(InstallException ie){System.err.println(ie.getMessage());}
        callback.update("installing files...",pulser++,10);
        
        FS.rm("-rf",ROOT+"/mainmod/mainmod.mod/var");
        try{
	        FS.cp("-apf","/mnt/.hidden_base/mnt/main_ro/var",ROOT+"/mainmod/mainmod.mod/");
	}catch(InstallException ie){System.err.println(ie.getMessage());}
	
        callback.update("installing files...",pulser++,10);
        FS.mkdir(ROOT+"/mainmod/mainmod.mod/opt");
        
        // create grub menu
        // install to mbr of device
        BOOT_PARAMS	= " hostname="+admin.hostname+ " domain="+admin.domain+" bindhome="+home_path+BOOT_PARAMS;
        if (grub.isSelected()){
	        callback.update("installing boot manager...",pulser++,11);
            String grubdevice=parts.getRootPartition(parts.getActiveRoot()).getParent().getPath();
            String grubcmd="gengrubmenu2 "+ROOT+"/boot/grub "+grubdevice+" "+parts.getRootPartition(parts.getActiveRoot()).path+" \""+BOOT_PARAMS+"\" /boot/vmlinuz /boot/miniroot.gz";
            String menucmd="\nsed -i -e 's/title.*GNU/title GeluX GNU/g' "+ROOT+"/boot/grub/menu.lst";
            FS.exec("grub-install --no-floppy --root-directory="+ROOT+"/ "+grubdevice);
            try {
                FileWriter f_grubcmd=new FileWriter("/tmp/grubcmd");
                f_grubcmd.write(grubcmd);
                f_grubcmd.write(menucmd);
                f_grubcmd.close();
                
            } catch (IOException e) {
                e.printStackTrace();
            }
            
            FS.exec("sh /tmp/grubcmd");
        }
        
        
        callback.update("setup the system...",pulser++,11);
        
        // create default user and update sudo
        FS.mount(parts.getRootPartition(parts.getActiveHome()).path,ROOT+"/mainmod/mainmod.mod/home");
        
        // add the new group
        FS.exec("chroot "+ROOT+"/mainmod/mainmod.mod groupadd "+user.username);
        
        callback.update("setup the system...",pulser++,12);
        // add the new users 
        // BUGS (  -c \"GeluX User\" ) quotes are not working with exec
        FS.exec("chroot "+ROOT+"/mainmod/mainmod.mod useradd -m -k /etc/skel -g "+user.username+" -s /bin/bash "+user.username+" -p "+user.passwd);
        
        callback.update("setup the system...",pulser++,13);
        FS.exec("chroot "+ROOT+"/mainmod/mainmod.mod chown -R "+user.username+"."+user.username+" /home/"+user.username);
        try {
           FileWriter f_pwdcmd=new FileWriter("/tmp/rootpwd");
           f_pwdcmd.write("chroot "+ROOT+"/mainmod/mainmod.mod sh -c 'echo root:"+admin.passwd+"|chpasswd'\n");
           f_pwdcmd.write("chroot "+ROOT+"/mainmod/mainmod.mod usermod -G "+GROUPS+" "+user.username+"\n");
           f_pwdcmd.write("chroot "+ROOT+"/mainmod/mainmod.mod sh -c 'echo "+user.username+":"+user.passwd+" | chpasswd'\n");
           f_pwdcmd.close();
           FS.exec("sh /tmp/rootpwd");
               
        } catch (IOException e) {
           e.printStackTrace();
        }        
        callback.update("Copy minimodules ...",pulser++,14);
        FS.cp("-apf","//mnt/.hidden_base/mnt/main_ro/var",ROOT+"/mainmod/mainmod.mod/");
        
        // set default root password
        callback.update("setup the system ...",pulser++,15);
        
        FS.exec("chroot "+ROOT+"/mainmod/mainmod.mod /usr/share/gelux-installer/node-post-install.sh -u="+user.username+" -s="+admin.server);
        FS.umount(ROOT);
        
        if (FS.isMounted(home_path))
            FS.umount(home_path);

        callback.update("installation is terminated",pulser++,16);
        
         		

	    
	}	

}
