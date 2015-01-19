; Copyright <Olivier Evalet at programmers.ch>
; Licensed GPL v2, (www.gnu.org for details)

;
; Follow this link for help :
;   http://www13.brinkster.com/vincenzog/articles.asp?ps=80
;
;
#define TESTINST

[Setup]
AppName=Gelux for WindowsXP
AppVerName=Gelux 1.0
AppPublisher=programmers.ch
AppPublisherURL=http://www.programmers.ch
AppSupportURL=http://www.programmers.ch
AppUpdatesURL=http://www.programmers.ch
DisableDirPage=true
DefaultGroupName=Gelux for WindowsXP
DisableProgramGroupPage=true
Compression=lzma
SolidCompression=true
OutputDir=D:\gelux-dev
OutputBaseFilename=setup-gelux
MinVersion=0,5.0.2195sp2
ExtraDiskSpaceRequired=1000000000
PrivilegesRequired=admin
ShowLanguageDialog=yes
AppVersion=1.0
UninstallFilesDir={code:GetAppDir}
CreateAppDir=false

[Files]
Source: {src}\*; DestDir: {code:GetAppDir}; Flags: external skipifsourcedoesntexist recursesubdirs overwritereadonly
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
;Source: cp.cmd; DestDir: {tmp}
;Source: openboot.cmd; DestDir: {tmp}
;Source: closeboot.cmd; DestDir: {tmp}
Source: gzip.exe; DestDir: {tmp}
Source: setup-boot.exe; DestDir: {code:GetAppDir}
Source: gelux-300.home.gz; DestDir: {code:GetAppDir}; check: check_home_300
Source: gelux-700.home.gz; DestDir: {code:GetAppDir}; check: check_home_700
Source: gelux-512.swap.gz; DestDir: {code:GetAppDir}; check: check_swap_512
Source: gelux-1024.swap.gz; DestDir: {code:GetAppDir}; check: check_swap_1024


[Icons]
Name: {group}\Gelux Settings; Filename: {code:GetAppDir}\setup-boot.exe; Comment: Modify your GeluX settings and update the boot manager; IconIndex: 0
Name: {group}\Gelux for Windows; Filename: {code:GetAppDir}\index.html
Name: {group}\Uninstall GeluX; Filename: {code:GetAppDir}\unins000.exe

[_ISTool]
EnableISX=true

[Run]
Filename: {tmp}\gzip.exe; WorkingDir: {code:GetAppDir}; Parameters: -d {code:GetAppDir}\gelux-300.home.gz; check: check_home_300; Flags: runhidden; StatusMsg: Creating home persistant data
Filename: {tmp}\gzip.exe; WorkingDir: {code:GetAppDir}; Parameters: -d {code:GetAppDir}\gelux-700.home.gz; check: check_home_700; Flags: runhidden; StatusMsg: Creating home persistant data
Filename: {tmp}\gzip.exe; WorkingDir: {code:GetAppDir}; Parameters: -d {code:GetAppDir}\gelux-512.swap.gz; check: check_swap_512; Flags: runhidden; StatusMsg: Creating system persistant data
Filename: {tmp}\gzip.exe; WorkingDir: {code:GetAppDir}; Parameters: -d {code:GetAppDir}\gelux-1024.swap.gz; check: check_swap_1024; Flags: runhidden; StatusMsg: Creating system persistant data
Filename: cmd; Parameters: /C del {code:GetAppDir}\setup-gelux.exe; Flags: runhidden
;Filename: cmd; Parameters: /C attrib {sd}\boot.ini -s -r -h; Flags: runhidden
Filename: cmd; Parameters: /C copy {sd}\boot.ini {sd}\boot.gelux; Flags: runhidden; Check: grubRemove
;Filename: cmd; Parameters: /C attrib {sd}\boot.ini -r +s +h; Flags: runhidden

Filename: {code:GetAppDir}\setup-boot.exe; Flags: hidewizard
Filename: {code:GetAppDir}\index.html; Flags: postinstall shellexec; Description: "Make sure you take the time to read the GeluX page ;)"

[Registry]
Root: HKLM; Subkey: SOFTWARE\programmers\gelux; ValueType: string; ValueName: drive; ValueData: {code:GetDriveChoosed}



[UninstallRun]
Filename: cmd; Parameters: /C attrib {sd}\boot.ini -s -r -h; Flags: runhidden
Filename: cmd; Parameters: /C copy {sd}\boot.gelux {sd}\boot.ini; Flags: runhidden
Filename: cmd; Parameters: /C attrib {sd}\boot.ini -r +s +h; Flags: runhidden

[Code]
var
//
// Install variables
//
  home_300,home_700,swap_512,swap_1024:Boolean;
  createfs:Boolean;
  AppDir: String;

  DrivePrompts, DriveValues, DrvLetters: array of String;

  function GetDriveType( lpDisk: String ): Integer;
  external 'GetDriveTypeA@kernel32.dll stdcall';

  function GetLogicalDriveStrings( nLenDrives: LongInt; lpDrives: String ): Integer;
  external 'GetLogicalDriveStringsA@kernel32.dll stdcall';

const
  DRIVE_UNKNOWN = 0; // The drive type cannot be determined.
  DRIVE_NO_ROOT_DIR = 1; // The root path is invalid. For example, no volume is mounted at the path.
  DRIVE_REMOVABLE = 2; // The disk can be removed from the drive.
  DRIVE_FIXED = 3; // The disk cannot be removed from the drive.
  DRIVE_REMOTE = 4; // The drive is a remote (network) drive.
  DRIVE_CDROM = 5; // The drive is a CD-ROM drive.
  DRIVE_RAMDISK = 6; // The drive is a RAM disk.
  MORPHIX = 'Gelux';

function check_swap_512():Boolean;
begin
	Result:=swap_512;
end;
function check_swap_1024():Boolean;
begin
	Result:=swap_1024;
end;
function check_home_300():Boolean;
begin
	Result:=home_300;
end;
function check_home_700():Boolean;
begin
	Result:=home_700;
end;

// function to convert disk type to string
function DriveTypeString( dtype: Integer ): String ;
begin
  case dtype of
    DRIVE_NO_ROOT_DIR : Result := 'Root path invalid';
    DRIVE_REMOVABLE : Result := 'Removable';
    DRIVE_FIXED : Result := 'Fixed';
    DRIVE_REMOTE : Result := 'Network';
    DRIVE_CDROM : Result := 'CD-ROM';
    DRIVE_RAMDISK : Result := 'Ram disk';
  else
    Result := 'Unknown';
  end;
end;


function InitializeSetup(): Boolean;
var
  n: Integer;
  drivesletters: String; lenletters: Integer;
  drive,defaultDrive: String;
  disktype, posnull: Integer;

begin
  //Init the default fs size
  home_300:=false;
  home_700:=true;
  swap_512:=false;
  swap_1024:=true;



  //get all drives letters of system
  drivesletters := StringOfChar( ' ', 64 );
  lenletters := GetLogicalDriveStrings( 63, drivesletters );
  SetLength( drivesletters , lenletters );

  drive := '';
  // get the saved drive letter
  RegQueryStringValue( HKLM, 'SOFTWARE\programmers\gelux', 'drive', defaultDrive);
  if (defaultDrive = '') then defaultDrive:='C:\';

  n := 0;
  while ( (Length(drivesletters) > 0) ) do
  begin
    posnull := Pos( #0, drivesletters );
  	if posnull > 0 then
  	begin
      drive:= UpperCase( Copy( drivesletters, 1, posnull - 1 ) );

      // get number type of disk
      disktype := GetDriveType( drive );

      // add it only if it is not a floppy
      if ( not ( disktype = DRIVE_CDROM ) and not ( drive = 'A:\' ) and Not (disktype = DRIVE_REMOTE)) then
      begin

        SetArrayLength(DrivePrompts, N+1);
        SetArrayLength(DriveValues, N+1);
        SetArrayLength(DrvLetters, N+1);

        DrivePrompts[n] := drive + '  ' + DriveTypeString( disktype );
        DrvLetters[n] := drive;
        // default select C: Drive
        if ( drive = defaultDrive ) then DriveValues[n] := '1';
        n := n + 1;
      end

  	  drivesletters := Copy( drivesletters, posnull+1, Length(drivesletters));
  	end
  end;

  Result := True;
end;

function grubRemove() : Boolean;
var
  index : Integer;
  aBoot : TArrayOfString;
begin
  LoadStringsFromFile(ExpandConstant('{sd}') + '\boot.ini', aBoot);
  { Loop trough all textlines to check if line to add already exists }
  for index := 0 to GetArrayLength(aBoot)-1 do begin
    if (pos('\boot\stage1',aBoot[index])>0) then begin
		aBoot[index]:='';
    end;
  end;
  SaveStringsToFile(ExpandConstant('{sd}') + '\boot.gelux', aBoot, False);
  Result:=false;
end;


function GetDriveChoosed( empty:String) : String;
var i:Integer;
begin
  for i:=0 to GetArrayLength(DriveValues)-1 do
    begin
      if DriveValues[i]='1' then
        begin
          Result:=DrvLetters[i];
          Exit;
        end;
    end;
  Result:='?';
end;

function GetAppDir(S: String): String;
begin
  // Return the selected AppDir
  Result := AppDir + MORPHIX;
end;





function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  S: String;
begin
  // Fill the 'Ready Memo' with the normal settings and the custom settings
  S := 'Program Location'+ NewLine;

  S := S + Space + GetAppDir('') + NewLine + NewLine;

  if createfs then begin
	S := S + 'Persistant datas'+ NewLine;
	S := S + Space + 'Create a home filesystem'+ NewLine;
	S := S + Space + 'Create a swap filesystem'+ NewLine + NewLine;
  end;

  S := S + 'Windows System'+ NewLine;
  S := S + Space + 'Update the boot manager' + NewLine + NewLine;
  Result:=S;
end;
{ ScriptDlgPages }

function ScriptDlgPages(CurPage: Integer; BackClicked: Boolean): Boolean;
var
  Next, NextOK,NextDisk: Boolean;
  CurSubPage: Integer;
// UI variables
  lb_disksize: TLabel;
  Label2: TLabel;
  lb_programmers: TLabel;
  rbhome300: TRadioButton;
  rbhome700: TRadioButton;
  Panel1: TPanel;

  Label6: TLabel;
  rbsys500: TRadioButton;
  rbsys1000: TRadioButton;


  lb_size: TLabel;
  lb_select_disk : TListBox;
  cbInstallFS: TCheckBox;

begin
  { place subpages between 'Welcome'- and 'SelectDir' page }
  if (not BackClicked and (CurPage = wpWelcome)) or (BackClicked and (CurPage = wpSelectDir)) then
  begin
    { find startpage }
    if not BackClicked then
      CurSubPage := 0
    else
      CurSubPage := 1;

    { iterate through all subpages }
    while (CurSubPage >= 0) and (CurSubPage <= 1) and not Terminated do
    begin
      ScriptDlgPageOpen();
      ScriptDlgPageClearCustom();

      { insert subpage }
      case CurSubPage of
        1:  // custompage 2
          begin
            ScriptDlgPageSetCaption('Create Virtual Disk for Linux');
            ScriptDlgPageSetSubCaption1('Install '+MORPHIX+' with persistant file for personnal data');
            ScriptDlgPageSetSubCaption2('');

            { lb_disksize }
            lb_disksize := TLabel.Create(WizardForm.ScriptDlgPanel);
            with lb_disksize do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 0;
              Top := 0;
              Width := 439;
              Height := 73;
              AutoSize := False;
              Caption := 'Select the size you want for your home data and the system environement.  Depending on your hard disk size, we recommend to select the maximum. The home disk will be used for our personnal data on linux and will be imported in case of a real installation';
              WordWrap := True;
            end;

            { Label2 }
            Label2 := TLabel.Create(WizardForm.ScriptDlgPanel);
            with Label2 do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 0;
              Top := 96;
              Width := 46;
              Height := 17;
              Caption := 'Home:';
              Font.Color := -16777208;
              Font.Height := -14;
              Font.Name := 'Tahoma';
              Font.Style := [fsBold];
            end;



            { rbhome300 }
            rbhome300 := TRadioButton.Create(WizardForm.ScriptDlgPanel);
            with rbhome300 do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 88;
              Top := 96;
              Width := 97;
              Height := 17;
              Caption := '300Mb';
              TabOrder := 0;
              Checked:=not home_700;
            end;

            { rbhome700 }
            rbhome700 := TRadioButton.Create(WizardForm.ScriptDlgPanel);
            with rbhome700 do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 208;
              Top := 96;
              Width := 169;
              Height := 17;
              Caption := '700Mb';
              Checked := True;
              TabOrder := 1;
              TabStop := True;
              Font.Style := [fsBold];
              Checked:=home_700;
            end;

            { Panel1 }
            Panel1 := TPanel.Create(WizardForm.ScriptDlgPanel);
            with Panel1 do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 0;
              Top := 120;
              Width := 409;
              Height := 49;
              BevelOuter := bvNone;
              TabOrder := 2;
            end;



            { Label6 }
            Label6 := TLabel.Create(WizardForm.ScriptDlgPanel);
            with Label6 do
            begin
              Parent := Panel1;
              Left := 0;
              Top := 16;
              Width := 56;
              Height := 17;
              Caption := 'System:';
              Font.Color := -16777208;
              Font.Height := -14;
              Font.Name := 'Tahoma';
              Font.Style := [fsBold];
            end;

            { rbsys500 }
            rbsys500 := TRadioButton.Create(WizardForm.ScriptDlgPanel);
            with rbsys500 do
            begin
              Parent := Panel1;
              Left := 88;
              Top := 16;
              Width := 89;
              Height := 17;
              Caption := '512Mb';
              TabOrder := 5;
              TabStop := True;
              Checked:=not swap_1024;
            end;

            { rbsys1000 }
            rbsys1000 := TRadioButton.Create(WizardForm.ScriptDlgPanel);
            with rbsys1000 do
            begin
              Parent := Panel1;
              Left := 208;
              Top := 16;
              Width := 177;
              Height := 17;
              Caption := '1024Mb';
              TabOrder := 6;
              Checked := swap_1024;
              Font.Style := [fsBold];
            end;

            { lb_programmers
            lb_programmers := TLabel.Create(WizardForm.ScriptDlgPanel);
            with lb_programmers do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 0;
              Top := 222;
              Width := 136;
              Height := 17;
              Cursor := crHand;
              Caption := 'http://gelux.programmers.ch/GeluxOnWindows';
              Font.Color := 16711680;
              Font.Height := -14;
              Font.Name := 'Tahoma';
              Font.Style := [fsUnderline];
            end;}
			{ cbInstallFS }
			cbInstallFS := TCheckBox.Create(WizardForm.ScriptDlgPanel);
			with cbInstallFS do
			begin
			  Parent := WizardForm.ScriptDlgPanel;
			  Left := 0;
			  Top := 222;
			  Width := 329;
			  Height := 17;
			  Caption := 'Do not create these files, there are already instelled!';
			  TabOrder := 0;
			  Checked := Boolean(FileExists(GetAppDir('')+'\gelux-300.home')) or Boolean(FileExists(GetAppDir('')+'\gelux-700.home'));
			end;
            Next := ScriptDlgPageProcessCustom(nil);

   			createfs:=not cbInstallFS.Checked;
   			swap_1024:=rbsys1000.Checked and createfs ;
   			swap_512:=rbsys500.Checked and createfs ;
   			home_300:=rbhome300.Checked  and createfs;
   			home_700:=rbhome700.Checked  and createfs;


            NextOK := True;
          end;

        0: // custompage 1
          begin
			// Set some captions
			ScriptDlgPageSetCaption('Select Installation drive');
			ScriptDlgPageSetSubCaption1( 'Where should '+MORPHIX+' be installed' );
			ScriptDlgPageSetSubCaption2('Select the drive where you would like '+MORPHIX+' to be installed, then click Next..');

			// Ask for a dir until the user has entered one or click Back or Cancel
			Next:= InputOptionArray(DrivePrompts, DriveValues, True, True);

			// store drive choosed
			if Next then
			AppDir := GetDriveChoosed('');


            //Next := ScriptDlgPageProcessCustom(nil);
            NextOK := True;
          end;
      end;

      { check sub-page navigation }
      if Next then
      begin
        if NextOK then
          CurSubPage := CurSubPage + 1;
      end
      else
        CurSubPage := CurSubPage - 1;
    end;

    { check main-page navigation }
    if not BackClicked then
      Result := Next
    else
      Result := not Next;
    ScriptDlgPageClose(not Result);
  end

  { return default }
  else
    Result := True;
end;

{ NextButtonClick }

function NextButtonClick(CurPage: Integer): Boolean;
begin
  Result := ScriptDlgPages(CurPage, False);
end;

{ BackButtonClick }

function BackButtonClick(CurPage: Integer): Boolean;
begin
  Result := ScriptDlgPages(CurPage, True);
end;
