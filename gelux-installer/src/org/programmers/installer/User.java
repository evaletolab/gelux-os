/*
 * Created on 5 mars 2005
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
 *  Copyright Olivier EValet at programmer.ch
 * 
 */
package org.programmers.installer;

/**
 * @author Olivier Evalet
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class User {
	private StringBuffer sb;
	public String username="demo";
	public String passwd="";
	public boolean canAppget;
	public boolean canPrinters;
	public boolean canInstall;
	public User(){
		sb=new StringBuffer(100);
	}
	
	public String getInfo(){
		canInstall=false;
		sb.setLength(0);
		if (username.length()>0){
			sb.append("user <b>").append(username).append("</b> is set\n");
			if (passwd.length()>0){
				sb.append("password for ").append(username).append(" is set\n");
				canInstall=true;
			}
			else
				sb.append("<span foreground='blue'>password for ").append(username).append(" is not set</span>\n");
			
			sb.append(username).append(canAppget?" can manage applications\n":" can <b>not</b> manage applications\n");
			sb.append(username).append(canPrinters?" can manage printers\n":" can <b>not</b> manage printers\n");
		}else{
			sb.append("user ").append(username).append(" is <b>not</b> set\n");
		}
		return sb.toString();
	}
}
