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
 */
package org.programmers.installer;

import org.gnu.parted.*;

import java.io.File;
import java.util.ArrayList;

/**
 * @author Olivier Evalet
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class DetectPartitions implements DeviceListener,Runnable {
	static final int MIN_MB_ROOT	= 1500; 
	static final int MIN_MB_HOME	= 1000; 
	static final int MIN_MB_SWAP	= 1000;		//suspend needs space 

	static final String[] PART_TOOLS={ 
								"/usr/sbin/gparted",
								"/usr/sbin/partitionmorpher"
								};
	
	
	// help to retrieve the handle 
	private ArrayList 	arr_part_root;
	private ArrayList 	arr_part_home;
	private ArrayList 	arr_part_swap;
	private ArrayList 	arr_part_fs;
	
	// getActiveText is not avilable until the next version of gtk???
	
	private boolean		asynchrone;

	private int 		selected_home;
	private int 		selected_root;
	private int 		selected_swap;
	private int 		selected_fs;
	
	private int 		count_root;
	private int 		count_home;
	private int 		count_swap;
	private int 		count_fs;

	private StringBuffer sb;

	Partition[] 		parts;
	Device[] 			devices;
	
	
	
	public 		boolean	canInstall;
	public		boolean canAutopart;
	public		boolean preservWindows;
	
	public 		class PartitionDesc{
	    PartitionDesc(Partition	part,String tag, String info){
	        partition=part;
	        tagged_text=tag;
	        resume=info;
	    }
	    Partition	partition;
	    String		tagged_text;
	    String		resume;
	}
	
	public DetectPartitions(){
		devices=Device.getAll();
		
		
		arr_part_root	=new ArrayList();
		arr_part_home	=new ArrayList();
		arr_part_swap	=new ArrayList();
		arr_part_fs		=new ArrayList();
		
		asynchrone	=false;
		sb			=new StringBuffer();
		
		
		//this listener must be added before the NodeInstaller
		addDeviceListener(this);
	}

	public final void addDeviceListener(DeviceListener listener){
		for (int i=0;i<devices.length;i++)
			devices[0].addDeviceListener(listener);
	}
	public final void setAsynchrone(boolean mode){
		asynchrone=mode;
	}
	
	public final void setActiveRoot(int i){
	    if (i<0)i=0;
	    selected_root=i;
	}
	public final void setActiveHome(int i){
	    if (i<0)i=0;
	    selected_home=i;
	}
	public final void setActiveSwap(int i){
	    if (i<0)i=0;
	    selected_swap=i;
	}
	public final int getActiveRoot(){
	    return selected_root;
	}
	public final int getActiveHome(){
	    return selected_home;
	}
	public final int getActiveSwap(){
	    return selected_swap;
	}
	public final int getActiveFS(){
	    return selected_fs;
	}
	public final int getCountRoot(){
	    return count_root;
	}
	public final int getCountHome(){
	    return count_home;
	}
	public final int getCountSwap(){
	    return count_swap;
	}
	public final int getCountFS(){
	    return count_fs;
	}
	
	public boolean hasRoot(){
		return 	(arr_part_root.size()!=0);
	}
	public boolean hasHome(){
		return 	(arr_part_home.size()!=0);
	}
	public boolean hasSwap(){
		return 	(arr_part_swap.size()!=0);
	}

	public final Partition getHomePartition(int i){
		if (!hasHome())
			return null;
	    PartitionDesc r=(PartitionDesc)arr_part_home.get(i);
		return (Partition)r.partition;
	}
	public final Partition getRootPartition(int i){
		if (!hasRoot())
			return null;
	    PartitionDesc r=(PartitionDesc)arr_part_root.get(i);
		return (Partition)r.partition;
	}
	public final Partition getSwapPartition(int i){
		if (!hasSwap())
			return null;
	    PartitionDesc r=(PartitionDesc)arr_part_swap.get(i);	    
		return (Partition)r.partition;
	}

	public final String getRootInfo(int i){
		if (!hasRoot())
			return "No root partition available";
	    PartitionDesc r=(PartitionDesc)arr_part_root.get(i);	    
		return (String)((r.tagged_text!=null)?r.tagged_text:"No root partition available");
	}
	public final String getHomeInfo(int i){
		if (!hasHome())
			return "No home partition available";
	    PartitionDesc r=(PartitionDesc)arr_part_home.get(i);	    
		return (String)r.tagged_text!=null?r.tagged_text:"No home partition available";
	}
	public final String getSwapInfo(int i){
		if (!hasSwap())
			return "No swap partition available";
	    PartitionDesc r=(PartitionDesc)arr_part_swap.get(i);	    
		return (String)r.tagged_text!=null?r.tagged_text:"No swap partition available";
	}
	public final String getRootResume(int i){
		if (arr_part_root.size()==0)
			return "No root partition available";
	    PartitionDesc r=(PartitionDesc)arr_part_root.get(i);	    
		return (String)r.resume!=null?r.resume:"No root partition available";
	}
	public final String getHomeResume(int i){
		if (arr_part_home.size()==0)
			return "No home partition available";
	    PartitionDesc r=(PartitionDesc)arr_part_home.get(i);	    
		return (String)r.resume!=null?r.resume:"No home partition available";
	}
	public final String getSwapResume(int i){
		if (arr_part_swap.size()==0)
			return "No swap partition available";
	    PartitionDesc r=(PartitionDesc)arr_part_swap.get(i);	    
		return (String)r.resume!=null?r.resume:"No swap partition available";
	}
	
	public Device[] getDevices(){
		return devices;
	}
	public String getTheBestPartitioner(){
		int i=0;
		while (PART_TOOLS.length>i){
			File f=new File(PART_TOOLS[i]);
			if (f.exists()){
				f=null;
				return "xterm -iconic -geometry 0x0 -e "+PART_TOOLS[i];
			}
			i++;
		}
		// This is the default part tool
		return "xterm -fn 10x20 -e /sbin/cfdisk";
	}
	public String getInfo(){
		sb.setLength(0);
		canInstall=false;
		if (arr_part_root.size()<selected_root)
			return "waiting...";
		if (hasRoot()){
			sb.append((String)getRootInfo(selected_root)).append("\n");
		}else
			sb.append("No root partition available").append("\n");
		if (arr_part_home.size()<selected_home)
			return sb.toString();
		if (hasRoot() && hasHome()){
			if (getRootPartition(selected_root).path.equals(getHomePartition(selected_home).path)){
				System.out.println(getRootPartition(selected_root).path+" (Already used by <ROOT>)");
				sb.append(getHomeInfo(selected_home)).append(" (Already used by <b>root</b>)\n");
				return sb.toString();
			}else{
				sb.append(getHomeInfo(selected_home)).append("\n");
			}
		}else
			return sb.toString();
		    
		if (!hasSwap() && arr_part_swap.size()<selected_swap)
			return sb.toString();
		sb.append(getSwapInfo(selected_swap)).append("\n");
		canInstall=true;
		
		return sb.toString();
			   
	}
	
	public void revalidate(){

		if (asynchrone){		
			new Thread(){
				public void run(){
					devices[0].revalidate();
				}
			}.start();
		}
		else{
			devices[0].revalidate();
		}
	}
	private void on_partition_end(){
		org.gnu.glib.CustomEvents.addEvent(this);
	}
	
	/* callback when devices are updated !!NOT THREAD SAFE!!
	 * @see org.gnu.parted.DeviceListener#deviceUpdate(org.gnu.parted.Device)
	 */
	public void deviceUpdate(Device device) {
		parts=devices[0].getPartitions();
		if (asynchrone)
			org.gnu.glib.CustomEvents.addEvent(this);
		else
			run();
	}

	/* Do not call this funtion directly!
	 * @see java.lang.Runnable#run()
	 */
	public void run() {
		int d=0,i=0;
		String disk;
		long size_root=MIN_MB_ROOT,size_home=0,size_swap=0;
		String append;
		// clean
		count_home=count_root=count_swap=0;
		arr_part_home.clear();
		arr_part_root.clear();
		arr_part_swap.clear();
		
		
		while(devices.length>d){
			disk=devices[d].getModel();
			parts=devices[d].getPartitions();
			while(parts.length>i){
				System.out.println(parts[i].path+", "+parts[i].filesystem);
				if (	!parts[i].filesystem.equalsIgnoreCase("linux-swap") && 
						!parts[i].filesystem.equalsIgnoreCase("fat16") &&
						!parts[i].filesystem.equalsIgnoreCase("fat32") &&
						!parts[i].filesystem.equalsIgnoreCase("ntfs") &&
						parts[i].itype!=Partition.EXTENDED){
				    					
					if (parts[i].size>=MIN_MB_HOME){
						append=", "+parts[i].path+", "+parts[i].filesystem+", "+parts[i].size+"MB";
						arr_part_home.add(new PartitionDesc(parts[i],"<b>home</b>"+append,disk+append));
						count_home++;
						if ( parts[i].size > size_home ){
							size_home=parts[i].size;
							System.out.println("selecthome="+count_home+"-1");
							selected_home=count_home-1;
						}
					}
					
					if (parts[i].size>=MIN_MB_ROOT){
						append=", "+parts[i].path+", "+parts[i].filesystem+", "+parts[i].size+"MB";
						arr_part_root.add(new PartitionDesc(parts[i],"<b>root</b>"+append,disk+append));
						count_root++;
					}										
				}

				if (parts[i].filesystem.equalsIgnoreCase("linux-swap")){
					append=", "+parts[i].path+", "+parts[i].filesystem+", "+parts[i].size+"MB";
					arr_part_swap.add(new PartitionDesc(parts[i],"<b>swap</b>"+append,disk+append));
					count_swap++;
				}
				
				i++;
			}
			d++;
		}
		
		//select the bigger root partition unselected by home! 
		for (int j=0;i<arr_part_root.size();j++){
		    Partition part=((PartitionDesc)arr_part_root.get(j)).partition;
			if (part.size > size_root && part != ((PartitionDesc)arr_part_home.get(selected_home)).partition){
				size_root=part.size;
				selected_root=j;
			}

		}
	}
}
