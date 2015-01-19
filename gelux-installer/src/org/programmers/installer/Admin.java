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
 * Copyright Olivier evalet at programmers.ch
 */
package org.programmers.installer;

/**
 * @author Olivier Evalet
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class Admin {
	private StringBuffer sb;
	public String passwd="";
	public String hostname="gelux-01";
	public String domain="programmers.ch";
	public String server="debian.programmers.ch";
	public String node="anonymous";
	public boolean canInstall;
	public Admin(){		
		sb=new StringBuffer(100);
		
	}
	
	public String getInfo(){
		sb.setLength(0);
		canInstall=(passwd.length()>0 && hostname.length()>0);
		// minimum length is 5!!!
		sb.append(passwd.length()>4?"root password is set\n":"<span foreground='blue'>root password is not set</span>\n");
		sb.append(hostname.length()>0?"hostname <b>"+hostname+"</b> is set\n":"<span foreground='blue'>hostname is not set</span>\n");
		sb.append(domain.length()>0?"domain <b>"+domain+"</b> is set\n":"<span foreground='blue'>domain is not set</span>\n");
		sb.append(server.length()>0?"repository <b>"+server+"</b> server is set\n":"<span foreground='blue'>repository server is not set</span>\n");
		sb.append(node.length()>0?"Clone name <b>"+node+"</b> is set\n":"<span foreground='blue'>Clone name is not set</span>\n");
		return sb.toString();
	}
		
}
