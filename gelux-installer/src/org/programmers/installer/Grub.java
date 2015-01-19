/*
 * Created on 4 mars 2005
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
 *  Copyright Olivier evalet at programmers.ch
 * 
 */
package org.programmers.installer;

import java.util.ArrayList;
import org.gnu.parted.Device;
import org.gnu.parted.Partition;

/**
 * @author root
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class Grub {
	DetectPartitions partitions; 
	ArrayList arr_boot;
	boolean selected;
	StringBuffer sb;
	
	public Grub(DetectPartitions partitions){
		arr_boot=new ArrayList();
		this.partitions=partitions;
		selected=true;
		sb=new StringBuffer();
	}
	public void setGrub(boolean selected){
		this.selected=selected;
	}
	public boolean isSelected(){
		return 	selected;
	}
	public String getInfo(){
		sb.setLength(0);
		if (isSelected())
			sb.append("Grub will be installed on MBR\n");
		else
			sb.append("Grub will not be installed\n");
			
		for (int i=0;i<arr_boot.size();i++){
			sb.append(i+1).append(") ").append(arr_boot.get(i));
		}
		return sb.toString();
	}
	
	public String[] getDetected(){
	    String[] ret=new String[arr_boot.size()];
	    return (String[]) arr_boot.toArray(ret);
	}
	
	public void revalidate(){
		int d=0,i=0;
		Device[] 	devices 	=	partitions.getDevices();
		Partition[] parts;
		arr_boot.clear();
		
		while(devices.length>d){
			parts=devices[d].getPartitions();
			while(parts.length>i){
				//windows NT/XP
				if (    parts[i].filesystem.equalsIgnoreCase("ntfs") &&
						parts[i].itype!=Partition.EXTENDED && parts[i].isBootable() ){
					arr_boot.add("Operating system Windows XP/NT on "+parts[i].path);
				}
				//windows 98/ME
				else if (    parts[i].filesystem.equalsIgnoreCase("fat32") &&
						parts[i].itype!=Partition.EXTENDED && parts[i].isBootable() ){
					arr_boot.add("Operating system Windows 95/98/ME on "+parts[i].path);					
				}
				//Linux
				else if (parts[i].itype!=Partition.EXTENDED && parts[i].isBootable() ){
					arr_boot.add("Operating system Linux on "+parts[i].path);					
				}
				i++;
			}
			d++;
		}
		
	}
}
