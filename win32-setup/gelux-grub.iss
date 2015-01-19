; Copyright <Olivier Evalet at programmers.ch>
; Licensed GPL v2, (www.gnu.org for details)

;
#define TESTINST

[Setup]
AppName=Gelux settings
AppVerName=Gelux Boot Settings 1.0
AppPublisher=programmers.ch
AppPublisherURL=http://www.programmers.ch
AppSupportURL=http://gelux.programmers.ch
AppUpdatesURL=http://gelux.programmers.ch
DisableDirPage=true
DefaultGroupName=Gelux for WindowsXP
DisableProgramGroupPage=true
Compression=lzma
SolidCompression=true
OutputDir=d:\gelux-dev
;OutputDir=./
OutputBaseFilename=setup-boot
MinVersion=0,5.0.2195sp2
ExtraDiskSpaceRequired=0
PrivilegesRequired=admin
ShowLanguageDialog=yes
AppVersion=1.0
UninstallFilesDir={code:GetAppDir}
CreateAppDir=false
AppCopyright=GPL
DisableReadyPage=false
Uninstallable=false
CreateUninstallRegKey=false
UpdateUninstallLogAppName=false
DisableFinishedPage=true

[Files]
;Source: openboot.cmd; DestDir: {tmp}
;Source: closeboot.cmd; DestDir: {tmp}
Source: gzip.exe; DestDir: {tmp}
Source: pted.exe; DestDir: {tmp}
Source: .\boot\*; DestDir: {sd}; Flags: recursesubdirs overwritereadonly
Source: {src}\boot\vmlinuz; DestDir: {sd}\boot; Flags: external overwritereadonly
Source: {src}\boot\miniroot.gz; DestDir: {sd}\boot; Flags: external overwritereadonly


[_ISTool]
EnableISX=true

[Run]
;Filename: {tmp}\openboot.cmd; WorkingDir: {tmp}; Flags: runhidden
Filename: cmd; Parameters: /C attrib {sd}\boot.ini -s -r -h; Flags: runhidden
Filename: cmd; Parameters: /C pted -m >drives; WorkingDir: {tmp}; Flags: runhidden
Filename: cmd; Parameters: /C w32grub.exe -d {code:grubGetDevice} -1 {sd}/boot/stage1 -2 {sd}/boot/stage2 -i {sd}2>grub.log; WorkingDir: {sd}\boot\grub\; check: grubInstall; Flags: runhidden; StatusMsg: Installing boot manager
Filename: cmd; Parameters: /C w32grub.exe -d {code:grubGetDevice} -1 {sd}/boot/stage1 -2 {sd}/boot/stage2 -i {sd}2>>grub.log; WorkingDir: {sd}\boot\grub\; check: grubInstall; Flags: runhidden; StatusMsg: Installing boot manager
Filename: cmd; Parameters: /C w32grub.exe -d {code:grubGetDevice} -1 {sd}/boot/stage1 -2 {sd}/boot/stage2 -i {sd}2>>grub.log; WorkingDir: {sd}\boot\grub\; check: grubInstall; Flags: runhidden; StatusMsg: Installing boot manager
;Filename: cmd; Parameters: /C attrib {sd}\boot.ini -r +s +h; Flags: runhidden
;Filename: {tmp}\closeboot.cmd; Flags: runhidden

[Registry]
Root: HKLM; Subkey: SOFTWARE\programmers\gelux; ValueType: string; ValueName: user; ValueData: {code:boxGetUser}
Root: HKLM; Subkey: SOFTWARE\programmers\gelux; ValueType: string; ValueName: name; ValueData: {code:boxGetName}
Root: HKLM; Subkey: SOFTWARE\programmers\gelux; ValueType: string; ValueName: lang; ValueData: {code:boxGetLang}
Root: HKLM; Subkey: SOFTWARE\programmers\gelux; ValueType: string; ValueName: acpi; ValueData: {code:boxGetACPI}


[Code]
//
// Install variables
//
var
  boxName,boxUser,boxLang,boxACPI,boxDirectory: String;
  setGrub:Boolean;

const
  MORPHIX = 'Gelux';

function InitializeSetup(): Boolean;
begin
  RegQueryStringValue( HKLM, 'SOFTWARE\programmers\gelux', 'path', boxDirectory);
  RegQueryStringValue( HKLM, 'SOFTWARE\programmers\gelux', 'name', boxName);
  RegQueryStringValue( HKLM, 'SOFTWARE\programmers\gelux', 'user', boxUser);
  RegQueryStringValue( HKLM, 'SOFTWARE\programmers\gelux', 'lang', boxLang);
  RegQueryStringValue( HKLM, 'SOFTWARE\programmers\gelux', 'acpi', boxACPI);
  setGrub:=true;
  Result:=true;
end;

function boxGetName(S: String): String;
begin
  Result:=boxName;
end;

function boxGetUser(S: String): String;
begin
  Result:=boxUser;
end;
function boxGetLang(S: String): String;
begin
  Result:=boxLang;
end;
function boxGetACPI(S: String): String;
begin
  Result:=boxACPI;
end;



function GetAppDir(S: String): String;
var
  path:String;
begin
  // Return the selected AppDir
  Result := boxDirectory;
end;

function grubUpdateMenu(strFilename, grubDevice: String): Boolean;
var
  options : String;
  index : Integer;
  aMenu : TArrayOfString;
  strTextfile : String;
  fAlreadyExist : Boolean;

begin
  { Load textfile into string array }
  LoadStringsFromFile(strFilename, aMenu);

  { grub options }
  options:=          'kernel /boot/vmlinuz  null fromdirectory='+MORPHIX+' ';
  options:= options+ 'hostname='+boxName+' username='+boxUser+' acpi='+boxACPI+' lang='+boxLang+' ';
  options:= options+ 'quiet splash=silent gdm dma alsa noapic  home=scan ramdisk_size=100000 init=/etc/init apm=power-off vga=791 minifo=on initrd=miniroot.gz  BOOT_IMAGE=morphix';


  for index := 0 to GetArrayLength(aMenu)-1 do begin
    if (pos('oot (',aMenu[index])>0) then  // Using 'oot (' instead 'root' to get a positive pos
		aMenu[index]:='root '+grubDevice;
    if (pos('ernel /boot/',aMenu[index])>0) then
		aMenu[index]:=options;
  end;

  { Add new textline at the end }
  Result := SaveStringsToFile(strFilename, aMenu, False);

end;


function grubUpdateBootinit(strFilename, strAddLine: String): Boolean;
var
  strTemp : String;
  index : Integer;
  aBoot : TArrayOfString;
  strBoot : String;
  fAlreadyExist : Boolean;

begin
  { Load textfile into string array }
  LoadStringsFromFile(strFilename, aBoot);
  LoadStringFromFile(strFilename, strBoot);

  { Loop trough all textlines to check if line to add already exists }
  fAlreadyExist:=false;
  for index := 0 to GetArrayLength(aBoot)-1 do begin
    if (aBoot[index] = strAddLine) then
        fAlreadyExist := True
  end;

  if not fAlreadyExist then begin
    { Add new textline at the end }
	SaveStringToFile(strFilename, strBoot+ #13 + #10 + strAddLine, False);
  end;

  Result := Not fAlreadyExist;

end;

function grubGetDevice(empty:String):String;
var
  aDrives : TArrayOfString;
  sysDrive,grubDrive: String;
  posHD,posLD,index: Integer;
begin
  sysDrive:=ExpandConstant('{sd}');
  { Load menu into string array }
  LoadStringsFromFile(ExpandConstant('{tmp}') + '\drives', aDrives);
  posHD:=pos('FS',aDrives[0]); // help to get (HDN,M)
  posLD:=pos('LD',aDrives[0]); // help to get the system frive

  for index := 1 to GetArrayLength(aDrives)-1 do begin
    if (pos(Copy(sysDrive,0,1),Copy(aDrives[index],posLD,3))>0) then begin
		grubDrive:=trim(Copy(aDrives[index],0,posHD-1));
    end;
  end;
  Result:=grubDrive;
end;


function grubInstall():Boolean;
begin
	{ Update boot.ini }
	Result:=grubUpdateBootinit(ExpandConstant('{sd}') + '\boot.ini',ExpandConstant('{sd}')+'\boot\stage1="GeLux for Windows 2000/XP"');
	{ Update menu.lst }
	grubUpdateMenu(ExpandConstant('{sd}') + '\boot\grub\menu.lst',grubGetDevice(''));

	Result:=true;
end;



function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  S: String;
begin
  // Fill the 'Ready Memo' with the normal settings and the custom settings
  S := MORPHIX+' options'+ NewLine;
  S := S + Space + 'Name is ' + boxName + NewLine;
  S := S + Space + 'User is ' + boxUser + NewLine;
  S := S + Space + 'Lang is ' + boxLang + NewLine;
  S := S + Space + 'ACPI is ' + boxACPI + NewLine + NewLine;

  S := S + 'Windows System'+ NewLine;
  S := S + Space + 'Update the boot manager on Windows 2000/XP' + NewLine + NewLine;
  Result:=S;
end;
{ ScriptDlgPages }

function ScriptDlgPages(CurPage: Integer; BackClicked: Boolean): Boolean;
var
  Next, NextOK,NextDisk: Boolean;
  CurSubPage: Integer;
// UI variables
  lbName: TLabel;
  Label1: TLabel;
  Label2: TLabel;
  Label3: TLabel;
  efName: TEdit;
  cbACPI: TCheckBox;
  efUser: TEdit;
  cbLang: TComboBox;
  cbGrub: TCheckBox;

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
        0:  // custompage 2
          begin
            ScriptDlgPageSetCaption('Configure your GeluX Box');
            ScriptDlgPageSetSubCaption1('Here you can set the main option of your linux box ');
            ScriptDlgPageSetSubCaption2('');

            { lbName }
            lbName := TLabel.Create(WizardForm.ScriptDlgPanel);
            with lbName do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 0;
              Top := 8;
              Width := 253;
              Height := 13;
              AutoSize := False;
              Caption := 'Choose the name of your GeluX Box:';
            end;

            { Label1 }
            Label1 := TLabel.Create(WizardForm.ScriptDlgPanel);
            with Label1 do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 0;
              Top := 48;
              Width := 253;
              Height := 13;
              AutoSize := False;
              Caption := 'Choose the default user  name:';
            end;

            { Label2 }
            Label2 := TLabel.Create(WizardForm.ScriptDlgPanel);
            with Label2 do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 200;
              Top := 88;
              Width := 197;
              Height := 21;
              AutoSize := False;
              Caption := 'default administrator password is demo.';
              Font.Color := -16777208;
              Font.Height := -11;
              Font.Name := 'Tahoma';
              WordWrap := True;
            end;

            { Label3 }
            Label3 := TLabel.Create(WizardForm.ScriptDlgPanel);
            with Label3 do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 0;
              Top := 104;
              Width := 253;
              Height := 13;
              AutoSize := False;
              Caption := 'Choose the default language:';
            end;

            { efName }
            efName := TEdit.Create(WizardForm.ScriptDlgPanel);
            with efName do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 200;
              Top := 16;
              Width := 121;
              Height := 21;
              TabOrder := 0;
              Text := 'gelux';
            end;

            { cbACPI }
            cbACPI := TCheckBox.Create(WizardForm.ScriptDlgPanel);
            with cbACPI do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 48;
              Top := 160;
              Width := 321;
              Height := 33;
              Caption := 'Use the Advanced Configuration and Power Interface (ACPI)';
              Checked := True;
              State := cbChecked;
              TabOrder := 1;
            end;

            { efUser }
            efUser := TEdit.Create(WizardForm.ScriptDlgPanel);
            with efUser do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 200;
              Top := 56;
              Width := 121;
              Height := 21;
              TabOrder := 2;
              Text := 'demo';
            end;

            { cbLang }
            cbLang := TComboBox.Create(WizardForm.ScriptDlgPanel);
            with cbLang do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 200;
              Top := 120;
              Width := 121;
              Height := 21;
              TabOrder := 3;
              Text := 'sf';
              Items.Add('sf');
              Items.Add('en');
              Items.Add('it');
              Items.Add('ge');
            end;

            { cbGrub }
            {
            cbGrub := TCheckBox.Create(WizardForm.ScriptDlgPanel);
            with cbGrub do
            begin
              Parent := WizardForm.ScriptDlgPanel;
              Left := 48;
              Top := 200;
              Width := 289;
              Height := 17;
              Caption := 'Update the boot manager';
              Checked := True;
              State := cbChecked;
              TabOrder := 4;
            end;
			}

            if (boxName <> '') then efName.text:=boxName;
            if (boxUser <> '') then efUser.text:=boxUser;
            if (boxLang <> '') then cbLang.text:=boxLang;
            cbACPI.Checked :=(boxACPI = 'on') ;


            Next := ScriptDlgPageProcessCustom(nil);

            boxName:=efName.text;
            boxUser:=efUser.text;
            boxLang:=cbLang.text;
            if cbACPI.Checked then boxACPI := 'on' else boxACPI := 'off' ;

            NextOK := True;
          end;

        1: // custompage 1
          begin
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
