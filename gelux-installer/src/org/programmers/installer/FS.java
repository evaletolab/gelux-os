/*
 * Created on 17 mars 2005
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
 *  Copyright Olivier Evalet at programmer.ch
 * 
 */
package org.programmers.installer;

/**
 * @author Olivier Evalet
 * Filesystem helper
 * 	mount
 *  umount
 *  mkresierfs
 *  mkswap
 * TODO 
 * 
 */
public class FS {
    public static boolean fake=false; 
    
    private static int run(String cmd){
			Process p=null;
			if (fake){
			    try {
                    Thread.sleep(100);
                } catch (InterruptedException e1) {
                    e1.printStackTrace();
                }
			    return 0;
			}
			    
            try {
                p = Runtime.getRuntime().exec(cmd);
                p.waitFor();
    			return p.exitValue();
            } catch (Exception e) {
                e.printStackTrace();
            }
//			p.getOutputStream();
			return 1;
    }
    public static void mount(String device,String mount)
    										throws InstallException{
        String mountcmd="mount "+device+" "+mount;
        if (run(mountcmd)!=0)
            throw new InstallException("ERROR on mount:\n"+mountcmd);
        
    }
    public static void umount(String device) throws InstallException{
        String mountcmd="umount "+device;
        if (run(mountcmd)!=0)
            throw new InstallException("ERROR on umount :\n"+mountcmd);
        
    }
    public static boolean isMounted(String device){
        return (run("grep -q "+device+" /proc/mounts")==0);
    }
    public static void mkext3(String device)throws InstallException{
        String cmd="mkfs.ext3 -j -q  "+device;
        if (run(cmd)!=0)
            throw new InstallException("ERROR on mkreiserfs :\n"+cmd);        
    }
    public static void mkreiserfs(String device)throws InstallException{
        String cmd="mkfs.reiserfs -q "+device;
        if (run(cmd)!=0)
            throw new InstallException("ERROR on mkreiserfs :\n"+cmd);        
    }

    public static void mkswap(String device)throws InstallException{
        String cmd="mkswap "+device;
        if (run(cmd)!=0)
            throw new InstallException("ERROR on mkswap :\n"+cmd);        
    }
    
    public static void mkdir(String directory)throws InstallException{
        String cmd="mkdir -p "+directory;
        if (run(cmd)!=0)
            throw new InstallException("ERROR on mkdir :\n"+cmd);        
		}
	
	public static void cpio(String src,String dst)throws InstallException{
	    String cmd="find "+src+" -depth | cpio -pdmv --quiet "+dst;
        if (run(cmd)!=0)
            throw new InstallException("ERROR on cpio :\n"+cmd);        
		
	}
	
	public static void cp(String options, String src,String dst)throws InstallException{
	    String cmd="cp "+options+" "+src+" "+dst;
	    if (run(cmd)!=0)
	        throw new InstallException("ERROR on cp :\n"+cmd);        

	}
	
	public static void rm(String options, String src)throws InstallException{
	    String cmd="rm "+options+" "+src;
	    if (run(cmd)!=0)
	        throw new InstallException("ERROR on rm :\n"+cmd);        

	}

	public static void exec(String cmd)	throws InstallException{
	    if (run(cmd)!=0)
	        throw new InstallException("ERROR on command :\n"+cmd);        

	}
}
