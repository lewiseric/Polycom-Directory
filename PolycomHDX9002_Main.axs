PROGRAM_NAME='PolycomHDX9002_Main'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/30/2013  AT: 20:37:21        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
   
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

// See DEFINE_START section below for default implementation
dvPolycomHDXSerial = 5001:1:0   // RS232 port 1 real device 
dvPolycomHDXIP     = 0:5:0      // IP real device

vdvPolycomHDX1IP   = 41001:1:0  // IP virtual device 1
vdvPolycomHDX2IP   = 41001:2:0  // IP virtual device 2
vdvPolycomHDX3IP   = 41001:3:0  // IP virtual device 3
vdvPolycomHDX4IP   = 41001:4:0  // IP virtual device 4
vdvPolycomHDX5IP   = 41001:5:0  // IP virtual device 5
vdvPolycomHDX6IP   = 41001:6:0  // IP virtual device 6
vdvPolycomHDX7IP   = 41001:7:0  // IP virtual device 7
vdvPolycomHDX8IP   = 41001:8:0  // IP virtual device 8

vdvPolycomHDX1Serial   = 41002:1:0  // Serial virtual device 1
vdvPolycomHDX2Serial   = 41002:2:0  // Serial virtual device 2
vdvPolycomHDX3Serial   = 41002:3:0  // Serial virtual device 3
vdvPolycomHDX4Serial   = 41002:4:0  // Serial virtual device 4
vdvPolycomHDX5Serial   = 41002:5:0  // Serial virtual device 5
vdvPolycomHDX6Serial   = 41002:6:0  // Serial virtual device 6
vdvPolycomHDX7Serial   = 41002:7:0  // Serial virtual device 7
vdvPolycomHDX8Serial   = 41002:8:0  // Serial virtual device 8

dvTP               = 10001:5:0  // G4 touch panel 
dvTP_ROOT	  = 10001:1:0 
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

DEV vdvPolycomHDXIP[] = {vdvPolycomHDX1IP,vdvPolycomHDX2IP,vdvPolycomHDX3IP,vdvPolycomHDX4IP,vdvPolycomHDX5IP,vdvPolycomHDX6IP,vdvPolycomHDX7IP,vdvPolycomHDX8IP}
DEV vdvPolycomHDXSERIAL[] = {vdvPolycomHDX1Serial,vdvPolycomHDX2Serial,vdvPolycomHDX3Serial,vdvPolycomHDX4Serial,vdvPolycomHDX5Serial,vdvPolycomHDX6Serial,vdvPolycomHDX7Serial,vdvPolycomHDX8Serial}

integer nButtons[]=
{
	// Main Conference Page 
	1,  //1-  Dialer 0
	2,  //2-  Dialer 1
	3,4,5,6,7,8,9,10, // Dialer 2..9
	11, //11- Dot/Period
	12, //12- Bksp
	13, //13- Clear 
	14, //14- Dial 
	15, //15- PiP
	16, //16- Mic On/Off 
	// Main Conference Page hangup popup
	17, //17- Hang Up 
	18, //18- Hang Up All
	////////////////////////////////////
	19, //19- Dialed Number Text Box
	20, //20- Call Status Text Box
	21, //21- Initialized Gears
	22, //22- Polycom Logo 
	// Main Conference Page baudrate popup
	23, //23- Auto Rate 
	24, //24- 384k Rate
	25,26,27,28,29,30,31, //31- 4096k Rate
	32, //32- Baud button
  33, //33- Line 1
	34, //34- Line 2
	35, //35- Line 3
	36, //36- Line 4
	37, //37- Line 5
	38, //38- Line 6
	39, //39- Line 7
	40, //40- Line 8
	41,42,43,44,45, //not used
	46, //46- not used
	47, //47- not used
	48, //48- dtmf text box
	49, //49- dtmf exit
	// end of Main Conference page buttons
  50, //50- Status button
  51, //51- My information
  
  // Phonebook page
  52, //52- Local phonebook
  53, //53- Global phonebook 
  54, //54- Scroll up 
  55, //55- Scroll down 
  56, //56- Dial selection 
  57, //57- Index 1 
  58,59,60,61,62, //62 - Index 6
  63, //63- Phone Book button 
	// end of Phonebook page
	
	// Camera page 
	64, //64- Near selected 
	65, //65- Far selected 
	66, //66- Camera next 
	67, //67- Camera prev 
	68, //68- Camera text box 
	69, //69- Zoom In 
	70, //70- Zoom out
	71, //71- Tilt up 
	72, //72- Tild down 
	73, //73- pan right 
	74, //74- pan left 
	75,76,77,78,79,80, //80- presets 1..6
	// end Camera page
	
	// Menu page
	81, //81- auto
	82, //82- keyboard
	83, //83- Return 
	84, //84- Up 
	85, //85- Down 
	86, //86- Left 
	87, //87- Right 
	88, //88- Select
	// end Menu page
	
	// Volume page 
	89, //89- Volume up 
	90, //90- Volume down 
	91, //91- Not used
	92, //92- Level number
  // end of Volume page 
  93, //93- AMX module version 
  94, //94- Polycom Firmware
	95, //95- Polycom Name 
	96, //96- Polycom Model 
	97, //97- Polycom SN
	98, //98- Polycom Tech Support Contact
	99, //99- Reinitialize
 100, //100- Dial Tech Support
 
  // Setup page 
	101, //101- Auto-Answer 
	102, //102- Auto Mute 
	103, //103- Video Layout Auto 
	104, //104- Video Layout Presentation 
	105, //105- Video Layout Discussion 
	106, //106- Video Layout Full Scrn.
	107, //107- Pip Cycle
	108, //108- Pip position 
	109, //109- Setup button 
	110, //110- not used
  111, //111- Do not disturb
  // End of setup page

  // Incoming call page 
	112, //112- Answer call 
  113, //113- Reject Call
  114, //114- Caller id 
  // end of Incoming call page 

  115, //115- Stream Start/Stop 
  116, //116- VCR play 
  117, //117- VCR stop
  118, //118- Far control of near Camera 
  119, //119- PiP Swap
  120, //120- Meeting password
  121, //121- POTS/ISDN/IP selector on Main page
  122,123,124,125,126,127,128,129,130,131, //0..9 DTMF tones	
	132, //132- * DTMF 
	133  //133- # DTMF
	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

/***************************************************************/
// NOTE: In order to enable a control method comment/uncomment the below pair of DEFINE_MODULE statements as needed.
//       Only 1 control method should be uncommented at one time.
/***************************************************************/

//DEFINE_MODULE 'PolycomHDX9002_UI' IP(vdvPolycomHDXIP,dvTP,nButtons)
//DEFINE_MODULE 'PolycomHDX9002_Comm_dr2_0_0' comm1(vdvPolycomHDXIP[1],dvPolycomHDXIP)

DEFINE_MODULE 'PolycomHDX9002_UI' SERIAL(vdvPolycomHDXSerial,dvTP,dvTP_ROOT, nButtons)
DEFINE_MODULE 'PolycomHDX9002_Comm_dr2_0_0' comm2(vdvPolycomHDXSerial[1],dvPolycomHDXSerial)

(* System Information Strings ******************************)
(* Use this section if there is a TP in the System!        *)
(*
    SEND_COMMAND TP,"'!F',250,'1'"
    SEND_COMMAND TP,"'TEXT250-',__NAME__"
    SEND_COMMAND TP,"'!F',251,'1'"
    SEND_COMMAND TP,"'TEXT251-',__FILE__,', ',S_DATE,', ',S_TIME"
    SEND_COMMAND TP,"'!F',252,'1'"
    SEND_COMMAND TP,"'TEXT252-',__VERSION__"
    SEND_COMMAND TP,"'!F',253,'1'"
    (* Must fill this (Master Ver) *)
    SEND_COMMAND TP,'TEXT253-'
    SEND_COMMAND TP,"'!F',254,'1'"
    (* Must fill this (Panel File) *)
    SEND_COMMAND TP,'TEXT254-'
    SEND_COMMAND TP,"'!F',255,'1'"
    (* Must fill this (Dealer Info) *)
    SEND_COMMAND TP,'TEXT255-'
*)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

