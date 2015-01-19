/*
 * Created on 26 f?vr. 2005
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
package org.programmers.installer.gui; 

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.gnu.gnome.Program;
import org.gnu.gnome.About;
import org.gnu.glade.GladeXMLException;
import org.gnu.glade.LibGlade;
import org.gnu.gtk.Button;
import org.gnu.gtk.ButtonsType;
import org.gnu.gtk.CheckButton;
import org.gnu.gtk.ComboBox;
import org.gnu.gtk.DialogFlags;
import org.gnu.gtk.Entry;
import org.gnu.gtk.Fixed;
import org.gnu.gtk.Gtk;
import org.gnu.gtk.Label;
import org.gnu.gtk.MessageDialog;
import org.gnu.gtk.MessageType;
import org.gnu.gtk.Notebook;
import org.gnu.gtk.ProgressBar;
import org.gnu.gtk.VButtonBox;
import org.gnu.gtk.Window;
import org.gnu.parted.Device;
import org.gnu.parted.DeviceListener;
import org.programmers.installer.Admin;
import org.programmers.installer.DetectPartitions;
import org.programmers.installer.FS;
import org.programmers.installer.Grub;
import org.programmers.installer.InstallBase;
import org.programmers.installer.InstallException;
import org.programmers.installer.InstallListener;
import org.programmers.installer.InstallRunner;
import org.programmers.installer.User;
import org.programmers.installer.type.StatelessInstall;

/**
 * @author root
 *
 * Window - Preferences - Java - Code Style - Code Templates
 * 
 * Debian packages
 *  http://packages.qa.debian.org/j/java-gnome.html
 * 
 * set up eclipse with gcj
 * 	http://klomp.org/mark/gij_eclipse/setup.html
 * 	http://www.linuxjournal.com/article/4860
 * 
 */ 

public class NodeInstaller extends InstallBase implements InstallListener, DeviceListener,Runnable{
    
    public static String name = "GeluX node installer";
    public static String version = "0.1";
    public static String license = "GPL";
    public static String description = "A node is a linux box for working on clonned environnement";
    public static String authors[] = { 
    	"evaleto@programmers.ch", 
        "http://gelux.programmers.ch"
    };
    public static String documentors[] = { 
        "evaleto@programmers.ch", 
        "http://gelux.programmers.ch"
    };
    public static String translators = "Language Guys Inc.";
    public static String website = "http://gelux.programmers.ch";

    
    private LibGlade 		glade;
	private ProgressBar		progress;
	private int				statid;
	private boolean 		runinstall;
    private String 			error;
    private String 			message;
    private double			fraction;
	
	// GUI
	ComboBox 	cb_root;
	ComboBox 	cb_home;
	ComboBox 	cb_swap;
	ComboBox 	cb_fs;
	

	public NodeInstaller(String[] args,InstallRunner installer) throws GladeXMLException, FileNotFoundException, IOException{
	    
	    super(args,installer);
		Gtk.init(args);
		Program.initGnomeUI(name,version,args);
		
	    String glade_path="/usr/share/gelux-installer/node-installer.glade";
	    File src=new File(glade_path);
	    if (!src.exists()) glade_path="data/node-installer.glade";
	    
		glade = new LibGlade(glade_path, this,"mainInstall");
		parts = new DetectPartitions();
		grub  = new Grub(parts);
		admin = new Admin();
		user  = new User();
		sb	  = new StringBuffer();
		
		
		runinstall	=false;
		error		=null;
		
		progress= ((ProgressBar)glade.getWidget("progressbar"));

		
		
		parts.addDeviceListener(this);
		parts.setAsynchrone(true);
		parts.revalidate();
		((Fixed)glade.getWidget("fixed_part")).setSensitive(false);
		
		cb_home	=((ComboBox)glade.getWidget("cb_home"));
		cb_root	=((ComboBox)glade.getWidget("cb_root"));
		cb_swap	=((ComboBox)glade.getWidget("cb_swap"));
		cb_fs	=((ComboBox)glade.getWidget("cb_fs"));
//		statid=status.getContextID("installation");
		
		if (FS.fake)
		    description+=" THIS IS A FAKE INSTALL FOR DEVEL TESTS";
		Gtk.main();

	}
/**
 * Install gui events
 */
	public void on_pb_part_clicked(){
		((Notebook)glade.getWidget("notebook")).setCurrentPage(4);
	}
	public void on_pb_admin_clicked(){
		((Notebook)glade.getWidget("notebook")).setCurrentPage(1);
	}
	public void on_pb_user_clicked(){
		((Notebook)glade.getWidget("notebook")).setCurrentPage(2);
	}
	public void on_pb_grub_clicked(){
		((Notebook)glade.getWidget("notebook")).setCurrentPage(3);
	}
	public void on_pb_remuse_clicked(){
		updateInfo();
		((Notebook)glade.getWidget("notebook")).setCurrentPage(0);
	}
	
	public void on_pb_openpart_clicked(){
		String cmd=parts.getTheBestPartitioner();
		System.out.println(cmd);
		if (cmd==null){
			((Button)glade.getWidget("pb_part")).setSensitive(false);
			return;
		}
		
		try {
			Process p=Runtime.getRuntime().exec(cmd);
			p.waitFor();
			parts.revalidate();
			((Fixed)glade.getWidget("fixed_part")).setSensitive(false);
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		
	}
	public void on_cb_sudo_printers_toggled(){
		user.canPrinters=((CheckButton)glade.getWidget("cb_sudo_printers")).getState();
	}
	public void on_cb_sudo_aptget_toggled(){
		user.canAppget=((CheckButton)glade.getWidget("cb_sudo_aptget")).getState();		
	}
	public void on_cb_grub_toggled(){
		grub.setGrub(((CheckButton)glade.getWidget("cb_grub")).getState());
		((Label)glade.getWidget("lb_info_grub")).setMarkup(grub.getInfo());
		((Label)glade.getWidget("lb_grub")).setMarkup(grub.getInfo());
	}
	public void on_select_part_changed(){
	    if (cb_home.getActive()>=0)
	        parts.setActiveHome(cb_home.getActive());
	    if (cb_swap.getActive()>=0)
	        parts.setActiveSwap(cb_swap.getActive());
	    if (cb_root.getActive()>=0)
	        parts.setActiveRoot(cb_root.getActive());
	}
	public void on_mainInstall_quit(){
		System.out.println("Quit MainInstall...");
		Gtk.mainQuit();		
	}
	
	public void on_ef_passwd2_focus_out_event(){
		Entry passwd,passwd2;
		passwd	= ((Entry)glade.getWidget("ef_passwd"));
		passwd2	= ((Entry)glade.getWidget("ef_passwd2"));
		if (checkPassword(passwd,passwd2))
			admin.passwd=passwd.getText();
	}
	
	public void on_ef_user_passwd2_focus_out_event(){
		Entry passwd,passwd2;
		passwd	= ((Entry)glade.getWidget("ef_user_passwd"));
		passwd2	= ((Entry)glade.getWidget("ef_user_passwd2"));
		if (checkPassword(passwd,passwd2))
			user.passwd=passwd.getText();			
	}
	
	public void on_ef_host_focus_out_event(){
		Entry host=((Entry)glade.getWidget("ef_host"));
		if(checkEntryNotEmpty(host))
			admin.hostname=host.getText();
	}
	public void on_ef_domain_focus_out_event(){
		Entry domain=((Entry)glade.getWidget("ef_domain"));
		if(checkEntryNotEmpty(domain))
			admin.domain=domain.getText();
	}
	public void on_ef_username_focus_out_event(){
		Entry username=((Entry)glade.getWidget("ef_username"));
		if(checkEntryNotEmpty(username))
			user.username=username.getText();
	}
	
	public void on_ef_up2date_focus_out_event(){
		Entry up2date=((Entry)glade.getWidget("ef_up2date"));
		if(checkEntryNotEmpty(up2date))
			admin.server=up2date.getText();
	}

	public void on_ef_group_focus_out_event(){
		Entry node=((Entry)glade.getWidget("ef_group"));
		if(checkEntryNotEmpty(node))
			admin.node=node.getText();
	}
	
	public void on_pb_install_clicked(){
		((Window)glade.getWidget("mainInstall")).setSensitive(false);
		runinstall=true;
		new Thread(this).start();	    
	}
	public void on_save_as_activate(){
	    Window parent=((Window)glade.getWidget("mainInstall"));
        MessageDialog dialog = new MessageDialog(parent, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK,"Not implemented", false);
        dialog.run();
        dialog.destroy();	    
	}
	public void on_save_activate(){
	    on_save_as_activate();
	    
	}
	public void on_open_activate(){
	    on_save_as_activate();
	}
	
	public void on_pb_group_clicked(){
	    on_save_as_activate();	    
	}
	public void on_about_activate(){

	    //title, version, license, comments, authors, documenters, translator, pixbuf
	    About about = new About(name, version, license, description, authors, documentors,translators,null);
		about.show();	    
	}
	
	/* callback when devices are updated !!NOT THREAD SAFE!!
	 * @see org.gnu.parted.DeviceListener#deviceUpdate(org.gnu.parted.Device)
	 */
	public void deviceUpdate(Device device) {
		System.out.println("deviceUpdate");
		org.gnu.glib.CustomEvents.addEvent(this);
	}
	public void run(){
	    
	    if(runinstall){
			try {
	            doInstall(parts,admin,user,grub,this);
	        } catch (InstallException e) {
	            error=e.getMessage()+"\n\nYou can post this problem on the gelux bugs web site;)";
	        }
	        runinstall=false;
			org.gnu.glib.CustomEvents.addEvent(new Runnable() {
	            public void run() {
	        		Window parent=((Window)glade.getWidget("mainInstall"));
	        		parent.setSensitive(true);
	        		if (error!=null){
	        		    MessageDialog dialog = new MessageDialog(parent, DialogFlags.MODAL, MessageType.ERROR, ButtonsType.OK,error, false);
	        		    dialog.run();
	        		    dialog.destroy();
	        		    try{FS.umount(StatelessInstall.ROOT);}catch (InstallException ie){}
	        		    error=null;
	        		}else{
	        		    MessageDialog dialog = new MessageDialog(parent, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK,"Installation terminated with success, you can reboot now ;)", false);
	        		    dialog.run();
	        		    dialog.destroy();
	        		    try{FS.umount(StatelessInstall.ROOT);}catch (InstallException ie){}
	        		    Gtk.mainQuit();
	        		}
	            }
	        });
			return;
	    }
	    
		grub.revalidate();
		for (int x=9;x>=0;x--){ 
			cb_root.removeText(x);
			cb_swap.removeText(x);
			cb_home.removeText(x);
		}
		for (int x=0;x<parts.getCountRoot();x++){
//		    System.out.println(parts.getRootResume(x));
		    cb_root.appendText(parts.getRootResume(x));
		}
		for (int x=0;x<parts.getCountHome();x++){
		    cb_home.appendText(parts.getHomeResume(x));
		}
		for (int x=0;x<parts.getCountSwap();x++){
		    cb_swap.appendText(parts.getSwapResume(x));
		}
		
		cb_root.setActive(parts.getActiveRoot());
		cb_home.setActive(parts.getActiveHome());
		cb_swap.setActive(parts.getActiveSwap());
		cb_fs.setActive(parts.getActiveFS());
		((Fixed)glade.getWidget("fixed_part")).setSensitive(true);
		/*
		 	*/	
		updateInfo();
						
	}
	
	private boolean checkPassword(Entry passwd,Entry passwd2){
		if (passwd.getText().compareTo(passwd2.getText())!=0){
			System.out.println("Password is not correctly set ;("+"id="+statid);
			passwd.setText("");
			passwd2.setText("");
			passwd.grabFocus();
			((VButtonBox)glade.getWidget("vbuttonbox")).setSensitive(false);
			return false;
		}
		((VButtonBox)glade.getWidget("vbuttonbox")).setSensitive(true);		
		return true;	
	}
	
	private boolean checkEntryNotEmpty(Entry entry){
		if(entry.getText().length()==0){
			entry.grabFocus();
			((VButtonBox)glade.getWidget("vbuttonbox")).setSensitive(false);
			return false;
		}
		((VButtonBox)glade.getWidget("vbuttonbox")).setSensitive(true);		
		return true;	
	}
		
	
	public void updateInfo(){
		
		((Label)glade.getWidget("lb_info_grub")).setMarkup(grub.getInfo());
		((Label)glade.getWidget("lb_info_part")).setMarkup(parts.getInfo());
		((Label)glade.getWidget("lb_info_admin")).setMarkup(admin.getInfo());
		((Label)glade.getWidget("lb_info_user")).setMarkup(user.getInfo());
		((Label)glade.getWidget("lb_grub")).setMarkup(grub.getInfo());		
		((Button)glade.getWidget("pb_install")).setSensitive(admin.canInstall && user.canInstall && parts.canInstall);
		
		sb.setLength(0);
		sb.append("<span foreground='blue'>");
		if (!parts.canInstall)
			sb.append("Please correct the partitions informations\n");
		if (!admin.canInstall)
			sb.append("Please correct the amdinistrator informations\n");
		if (!user.canInstall)
			sb.append("Please correct the user informations\n");

		if (admin.canInstall && user.canInstall && parts.canInstall)
			sb.append("You can perform the installation now.");
		sb.append("</span>");
		((Label)glade.getWidget("lb_install_info")).setMarkup(sb.toString());

		
		
	}

	
	public String toString(){
	    sb.setLength(0);
		sb.append("swap="+parts.getSwapPartition(parts.getActiveSwap()).path).append("\n");
		sb.append("home="+parts.getHomePartition(parts.getActiveHome()).path).append("\n");
		sb.append("root="+parts.getRootPartition(parts.getActiveRoot()).path).append("\n");
		sb.append("preserve Windows="+parts.preservWindows).append("\n");
		sb.append("auto part="+parts.canAutopart).append("\n");
		sb.append("---------------------------------------------").append("\n");
		sb.append("username="+user.username).append("\n");
		sb.append("passwd="+user.passwd).append("\n");
		sb.append("sudo apt="+user.canAppget).append("\n");
		sb.append("sudo cups="+user.canPrinters).append("\n");
		sb.append("---------------------------------------------").append("\n");
		sb.append("hostname="+admin.hostname).append("\n");
		sb.append("passwd="+admin.passwd).append("\n");
		sb.append("server="+admin.server).append("\n");
		sb.append("---------------------------------------------").append("\n");
		sb.append("grub="+grub.isSelected()).append("\n");
		String[] grubs=grub.getDetected();
		for (int i=0;i<grubs.length;i++)
		    sb.append("grub.detected="+grubs[i]).append("\n");
		return sb.toString();
	}
    /* (non-Javadoc)
     * @see org.programmers.installer.InstallListener#update(java.lang.String, int, int)
     */
    public void update(String status, int current, int end) {
        message=status;
        fraction=(double)current/(double)end;
        //System.out.println("fraction="+fraction);
		org.gnu.glib.CustomEvents.addEvent(new Runnable() {
            public void run() {        
                progress.setFraction(fraction);
                progress.setText(message);
            }
		});
        
    }

}
