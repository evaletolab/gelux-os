/*
 * Created on 30 mars 2005
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

import org.programmers.installer.gui.NodeInstaller;
import org.programmers.installer.type.StatelessInstall;

/**
 * @author Olivier Evalet
 *
 *  
 * 
 */
public class InstallBase implements InstallRunner{
	//Install options
	protected  DetectPartitions 		parts;
	protected  Admin					admin;
	protected  User					user;
	protected  Grub 					grub;
	protected  StringBuffer  		sb;
	
	private InstallRunner 	installer;
	
	public InstallBase(){
	    
	}
	public InstallBase(InstallRunner installer){
		this.installer=installer;	    
	}
	
	public InstallBase(String[] args,InstallRunner installer){
		this.installer=installer;	    
	}
	
	public void readConfig(String path){
	    
	}
	public void writeConfig(String path){
	    
	}
	
	public void doInstall(DetectPartitions parts, Admin admin, User user, Grub grub, InstallListener callback) throws InstallException{
	    installer.doInstall(parts, admin, user, grub, callback);
	}
	
	public static void main(String[] args) {
		NodeInstaller install;
/*		
		try {
	            FS.exec("xterm -iconic -geometry 0x0 -e /home/devel/gelux/morphixcvs/partitionmorpher/src/partitionmorpher");
        	} catch (InstallException e1) {
	            e1.printStackTrace();
        	    return;
	        }
*/        
		try {
			install=new NodeInstaller(args,new StatelessInstall());			
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

}
