MODULE_NAME='PolycomHDX9002_UI'(DEV vdvPolycomHDX[], DEV dvTP,DEV dvTP_ROOT, INTEGER nButtons[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/30/2013  AT: 20:54:04        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
/**
THIS SAMPLE CODE WAS DEVELOPED FOR HDX9004 FIRMWARE VERSION BETA HF-1.0.1.08-349
*/
#include 'ModuleProperties.axi'
#include 'SNAPI.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
///////////////////////////////////////////////
// Adjust these constant based on your device. 
integer MAX_INPUTS  = 5 // MAX NUMBER OF INPUTS. Default is HDX9004 w/ 5 inputs
////////////////////////////////////////////////

////////////////////////////////////////////////
// The below constants should not be changed 
char CONFERENCE_STATE[4][15] = {'Idle', 'Negotiating', 'Connected', 'Ringing'}
char BAUD_RATES[9][4] = {'Auto','384','512','768','1024','1472','1920','3840','4096'}
char CAMERAS[5][15] = {'Camera 1','Camera 2','Camera 3','Camera 4','Camera 5'}
char CALL_TYPE[3][4] = {'POTS','ISDN','IP'}
integer POTS_TYPE = 1
integer IP_TYPE   = 3
integer MAX_TEXT_LENGTH = 40
integer SEARCH_SIZE = 6 // SIZE OF THE PHONEBOOK SEARCH PAGE - 6 entries total 
integer MAX_LINES   = 8 // MAX NUMBER OF ACTIVE CALLS 
//////////////////////////////////////////////// 
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

// Change this variable to match the IP address of your device...
volatile char IP[15]= '192.168.10.1'// Polycom IP address

volatile char KEY[] = 'KEY'

volatile integer m_port     // stores the port # a reply is received on.
volatile integer m_debug    // stores the debug level 
volatile integer m_btnindex // stores the button index used from the button array.

volatile char m_phonebookNumber[6][MAX_TEXT_LENGTH] // stores the phonebook number as displayed.
volatile char m_phonebookName[6][MAX_TEXT_LENGTH] // stores the phonebook name as displayed.
volatile integer m_phonebookIndex      // stores the phonebook index selected (1..6)
volatile integer m_phonebookLocality   // 0=Local 1=Global 
volatile integer m_phonebookMatches

volatile char m_TechSupportPOTS[20]
volatile char m_PIPLocation[20]

volatile integer m_LineRinging 
volatile char m_numberDialed[MAX_TEXT_LENGTH] // stores the number being dialed
volatile char m_DialSpeed[10] = '1920'     // stores the baud rate speed of the call
volatile integer m_BaudRateIndex = 7   // stores the index of the selected baud rate 1..9
volatile integer m_LineSelected[MAX_LINES]     // stores the line selected by user
volatile char m_LineState[MAX_LINES][15]       // stores the current state of the conference line
volatile char m_LineInfo[MAX_LINES][80]        // stores line information

volatile integer m_cameraSelected[2] = {1,1}   // stores the current camera selected as the main video source
volatile integer m_cameraPreset[2]     // stores the preset number the camera is on
volatile integer m_cameraLocality = 1     // 1=Near 2=Far

volatile integer m_Level 
volatile char m_ViewMode[15]

volatile integer m_Streaming = false 
volatile char    m_StreamState[2][5] = {'stop','start'}

volatile integer m_PanelOffline = false 
volatile integer m_MeetingpasswordSet = false
volatile char    m_MeetingpasswordMask[] = '****'

volatile integer m_callType = 1
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
DEFINE_FUNCTION updateLineInfo(integer line)
{
	send_command dvTP,"'@TXT',nButtons[32+line],m_LineInfo[line]"
}


DEFINE_FUNCTION clearPhoneBookEntries()
{
	stack_var integer i 
	for(i=1 ; i <= SEARCH_SIZE ; i++)
	{
		m_phonebookName[i] = ''
		m_phonebookNumber[i] = ''
		send_command dvTP,"'@TXT',nButtons[56+i],''"
		send_command dvTP,"'@TXT',156+i,''"
	}
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvTP_ROOT]
{
	OFFLINE:  m_PanelOffline = true
	ONLINE:
	{
		integer i
		m_PanelOffline = false
		send_command dvTP,"'@TXT',nButtons[121],CALL_TYPE[m_callType]"
		for(i=1 ; i<=MAX_LINES ; i++)
		{
			if(m_LineState[i]==CONFERENCE_STATE[3])
			{
				send_command dvTP,"'@TXT',nButtons[20],CONFERENCE_STATE[3]"
				break;
			}
		}
		if(i>MAX_LINES)
			send_command dvTP,"'@TXT',nButtons[20],CONFERENCE_STATE[1]"
		send_command dvTP,"'@TXT',nButtons[19],m_numberDialed"
		if(!find_string(m_numberDialed,'.',1))
		{
			send_command dvTP,"'^SHO-',itoa(nButtons[32]),',0'" // Hide the baud button
		}
		send_command dvTP,"'@TXT',nButtons[68],CAMERAS[m_cameraSelected[m_cameraLocality]]"
	  send_level dvTP,nButtons[92],m_Level
		send_command dvTP,"'@TXT',nButtons[108],m_PIPLocation"
		for(i=1 ; i<=MAX_LINES ; i++)
		{
			if(m_LineState[i]==CONFERENCE_STATE[4])
			{
				send_command dvTP,"'@PPN-_incomingcall'"
				send_command dvTP,"'@TXT',nButtons[114],m_LineInfo[i]"
				break;
			}
		}
		send_command vdvPolycomHDX[1],"'?MEETING_PASSWORD'"
		send_command vdvPolycomHDX[1],"'PHONEBOOKREFRESH-',KEY,',',itoa(SEARCH_SIZE)"
		for(i=1 ; i<=MAX_LINES ; i++)
		{
			if(m_LineState[i]==CONFERENCE_STATE[3])updateLineInfo(i)
			else if(m_LineState[i]!=CONFERENCE_STATE[1])
				send_command dvTP,"'@TXT',nButtons[32+i],m_LineState[i]"
		
		}
	}
	STRING:
	{
		if(find_string(data.text,'KEYB-',1) && !find_string(data.text,'ABORT',1))
		{
			send_string 0,"'STRING received from TP: ',DATA.TEXT"
			remove_string(data.text,'-',1)
			if(m_MeetingpasswordSet==true)
			{
				m_MeetingpasswordSet = false 
				send_command vdvPolycomHDX[1],"'MEETING_PASSWORD-',data.text"
				send_command dvTP,"'@TXT',nButtons[120],m_MeetingpasswordMask"
		  }
			else
			{
				clearPhoneBookEntries()
				send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKCLOSESEARCH-',KEY"
				send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKSEARCH-',KEY,',ID=',data.text"
		  }
		}
	}
	
}

DATA_EVENT[vdvPolycomHDX[1]]
{
	ONLINE:
	{
		clearPhoneBookEntries()
		send_command vdvPolycomHDX[1],"'PROPERTY-',IP_Address,',',IP"  // sets the IP address of the HDX9004 to control
		send_command vdvPolycomHDX[1],"'PROPERTY-',PASSWORD,',password'" // sets the Ethernet login password.
		send_command vdvPolycomHDX[1],'REINIT' // reinitializes the module...communications are established.
	}
}

LEVEL_EVENT [vdvPolycomHDX[1],VOL_LVL]
{
	m_Level = LEVEL.VALUE
	send_level dvTP,nButtons[92],m_Level
}

LEVEL_EVENT [dvTP,nButtons[92]]
{
	cancel_wait 'Update'
	wait 10 'Update'
		if(m_PanelOffline==false)send_level vdvPolycomHDX[1],VOL_LVL,LEVEL.VALUE
}

CHANNEL_EVENT[vdvPolycomHDX[1],DATA_INITIALIZED]
{
	ON: send_command vdvPolycomHDX[1],"'?PROPERTY-',IP_Address"
}

DATA_EVENT[vdvPolycomHDX]
{
	COMMAND:
	{
		m_port = DATA.DEVICE.PORT
		if(m_debug>1)
			SEND_string 0,"'UI rcvd from COMM on port ',itoa(m_port),' :',data.text"
		switch(remove_string(data.text,'-',1))
		{
			case 'CAMERAPRESET-':
			{
				m_cameraPreset[m_port] = atoi(data.text)
			}
			case 'DIALERSTATUS-':
			{
				if(find_string(data.text,'DISCONNECTED',1)) 
				{
					m_LineState[m_port] = CONFERENCE_STATE[1]
					m_LineInfo[m_port] = ''
					send_command dvTP,"'@TXT',nButtons[32+m_port],m_LineInfo[m_port]"
					if(m_LineState[1] == CONFERENCE_STATE[1] && m_LineState[2] == CONFERENCE_STATE[1] && m_LineState[3] == CONFERENCE_STATE[1] &&
					   m_LineState[4] == CONFERENCE_STATE[1] && m_LineState[5] == CONFERENCE_STATE[1] && m_LineState[6] == CONFERENCE_STATE[1] &&
						 m_LineState[7] == CONFERENCE_STATE[1] && m_LineState[8] == CONFERENCE_STATE[1])
					{
						send_command dvTP,"'@TXT',nButtons[20],m_LineState[m_port]"
						send_command dvTP,"'@PPK-_incomingcall'"
					}
					else if(m_LineState[1] == CONFERENCE_STATE[3] || m_LineState[2] == CONFERENCE_STATE[3] || m_LineState[3] == CONFERENCE_STATE[3] ||
					        m_LineState[4] == CONFERENCE_STATE[3] || m_LineState[5] == CONFERENCE_STATE[3] || m_LineState[6] == CONFERENCE_STATE[3] ||
						      m_LineState[7] == CONFERENCE_STATE[3] || m_LineState[8] == CONFERENCE_STATE[3])
					{
						send_command dvTP,"'@TXT',nButtons[20],CONFERENCE_STATE[3]"
						send_command dvTP,"'@PPK-_incomingcall'"
					}
					else if(m_LineState[1] == CONFERENCE_STATE[2] || m_LineState[2] == CONFERENCE_STATE[2] || m_LineState[3] == CONFERENCE_STATE[2] ||
					        m_LineState[4] == CONFERENCE_STATE[2] || m_LineState[5] == CONFERENCE_STATE[2] || m_LineState[6] == CONFERENCE_STATE[2] ||
						      m_LineState[7] == CONFERENCE_STATE[2] || m_LineState[2] == CONFERENCE_STATE[2])
					{
						send_command dvTP,"'@TXT',nButtons[20],CONFERENCE_STATE[2]"
						send_command dvTP,"'@PPK-_incomingcall'"
					}
				}
				else if(find_string(data.text,'NEGOTIATING',1)) 
				{
					m_LineState[m_port] = CONFERENCE_STATE[2]
					send_command dvTP,"'@TXT',nButtons[20],m_LineState[m_port]"
					send_command dvTP,"'@TXT',nButtons[32+m_port],'Negotiating...'"
				}
				else if(find_string(data.text,'RINGING',1)) 
				{
					m_LineState[m_port] = CONFERENCE_STATE[4]
					send_command dvTP,"'@TXT',nButtons[20],m_LineState[m_port]"
					send_command dvTP,"'@TXT',nButtons[32+m_port],'Ringing...'"
				}
				else if(find_string(data.text,'CONNECTED',1)) 
				{
					m_LineState[m_port] = CONFERENCE_STATE[3]
					send_command dvTP,"'@TXT',nButtons[20],m_LineState[m_port]"
					send_command dvTP,"'@PPK-_incomingcall'"
					if(m_port==1)
					{
					
						wait 20
						{
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_1_Name"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_1_Number"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_1_Direction"
				    }
					}
					else if(m_port==2)
					{
						wait 20
						{
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_2_Name"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_2_Number"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_2_Direction"
					  }
					}
					else if(m_port==3)
					{
						wait 20
						{
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_3_Name"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_3_Number"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_3_Direction"
					  }
					}
					else if(m_port==4)
					{
						wait 20
						{
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_4_Name"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_4_Number"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_4_Direction"
					  }
					}
					else if(m_port==5)
					{
						wait 20
						{
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_5_Name"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_5_Number"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_5_Direction"
					  }
					}
					else if(m_port==6)
					{
						wait 20
						{
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_6_Name"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_6_Number"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_6_Direction"
					  }
					}
					else if(m_port==7)
					{
						wait 20
						{
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_7_Name"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_7_Number"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_7_Direction"
					  }
					}
					else
					{
						wait 20
						{
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_8_Name"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_8_Number"
							send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_8_Direction"
					  }
					}
				}
				break
			}
			case 'INCOMINGCALL-':
			{
				send_command dvTP,"'@PPN-_incomingcall'"
				m_LineState[m_port] = CONFERENCE_STATE[4]
				m_LineInfo[m_port] = data.text
				send_command dvTP,"'@TXT',nButtons[114],m_LineInfo[m_port]"
				m_LineRinging = m_port
			}
			case 'MEETING_PASSWORD-':
			{
				if(length_string(data.text)>0 && data.text!="$22,$22") send_command dvTP,"'@TXT',nButtons[120],m_MeetingpasswordMask"
			  else send_command dvTP,"'@TXT',nButtons[120],''"
			}
			case 'INPUT-':
			{
				send_command dvTP,"'@PPK-_wait'"
				m_cameraSelected[m_port] = atoi(data.text)
				if(m_port==m_cameraLocality && m_cameraSelected[m_port]>0)
					send_command dvTP,"'@TXT',nButtons[68],CAMERAS[m_cameraSelected[m_port]]"
			}
			case 'PHONEBOOKSEARCHRESULT-':
			{
				if(find_string(data.text,KEY,1))
				{
					remove_string(data.text,',',1) // get rid of the KEY 
					m_phonebookMatches = atoi(data.text)
					if(m_phonebookMatches>0) send_command vdvPolycomHDX[m_port],"'PHONEBOOKNEXT-',KEY,',',itoa(SEARCH_SIZE)" 
				 	send_command dvTP,"'@PPK-_wait'"
				}
			}
			case 'PIP_LOCATION-':
			{
				m_PIPLocation = data.text 
				send_command dvTP,"'@TXT',nButtons[108],m_PIPLocation"
			}
			case 'PHONEBOOKRECORD-':
			{
				if(find_string(data.text,KEY,1))
				{ //PHONEBOOKRECORD-<key>,<id>,<#>,<name>,<number>
					integer idx
					remove_string(data.text,',',1) // get rid of the KEY 
					remove_string(data.text,',',1) // get rid of the id
					idx = atoi(data.text) // store the record index # 
					remove_string(data.text,',',1) // remove the record index # 
				  m_phonebookName[idx] = remove_string(data.text,',',1)
					m_phonebookNumber[idx] = data.text
					set_length_string(m_phonebookName[idx],length_string(m_phonebookName[idx])-1) // remove the last , at the end
					send_command dvTP,"'@TXT',nButtons[56+idx],m_phonebookName[idx]"
					send_command dvTP,"'@TXT',156+idx,m_phonebookNumber[idx]"
				}
			}
			case 'VERSION-':
			{
				send_command dvTP,"'@TXT',nButtons[93],data.text"
			}
			case 'FWVERSION-':
			{
				send_command dvTP,"'@TXT',nButtons[94],data.text"
			}
			case 'VIEW_MODE-':
			{
				m_ViewMode = data.text
			}
			case 'PROPERTY-':
			{
				if(find_string(data.text,Call_1_Number,1) && m_LineState[1]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[1] = "m_LineInfo[1],' #',data.text"
				}
				else if(find_string(data.text,Call_2_Number,1) && m_LineState[2]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[2] = "m_LineInfo[2],' #',data.text"
				}
				else if(find_string(data.text,Call_3_Number,1) && m_LineState[3]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[3] = "m_LineInfo[3],' #',data.text"
				}
				else if(find_string(data.text,Call_4_Number,1) && m_LineState[4]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[4] = "m_LineInfo[4],' #',data.text"
				}
				else if(find_string(data.text,Call_5_Number,1) && m_LineState[5]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[5] = "m_LineInfo[5],' #',data.text"
				}
				else if(find_string(data.text,Call_6_Number,1) && m_LineState[6]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[6] = "m_LineInfo[6],' #',data.text"
				}
				else if(find_string(data.text,Call_7_Number,1) && m_LineState[7]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[7] = "m_LineInfo[7],' #',data.text"
				}
				else if(find_string(data.text,Call_8_Number,1) && m_LineState[8]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[8] = "m_LineInfo[8],' #',data.text"
				}
				else if(find_string(data.text,Call_1_Name,1) && m_LineState[1]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[1] = data.text
				}
				else if(find_string(data.text,Call_2_Name,1) && m_LineState[2]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[2] = data.text
				}
				else if(find_string(data.text,Call_3_Name,1) && m_LineState[3]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[3] = data.text
				}
				else if(find_string(data.text,Call_4_Name,1) && m_LineState[4]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[4] = data.text
				}
				else if(find_string(data.text,Call_5_Name,1) && m_LineState[5]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[5] = data.text
				}
				else if(find_string(data.text,Call_6_Name,1) && m_LineState[6]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[6] = data.text
				}
				else if(find_string(data.text,Call_7_Name,1) && m_LineState[7]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[7] = data.text
				}
				else if(find_string(data.text,Call_8_Name,1) && m_LineState[8]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[8] = data.text
				}
				else if(find_string(data.text,Call_1_Direction,1) && m_LineState[1]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[1] = "m_LineInfo[1],' >',data.text"
					updateLineInfo(1)
				}
				else if(find_string(data.text,Call_2_Direction,1) && m_LineState[2]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[2] = "m_LineInfo[2],' >',data.text"
					updateLineInfo(2)
				}
				else if(find_string(data.text,Call_3_Direction,1) && m_LineState[3]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[3] = "m_LineInfo[3],' >',data.text"
					updateLineInfo(3)
				}
				else if(find_string(data.text,Call_4_Direction,1) && m_LineState[4]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[4] = "m_LineInfo[4],' >',data.text"
					updateLineInfo(4)
				}
				else if(find_string(data.text,Call_5_Direction,1) && m_LineState[5]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[5] = "m_LineInfo[5],' >',data.text"
					updateLineInfo(5)
				}
				else if(find_string(data.text,Call_6_Direction,1) && m_LineState[6]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[6] = "m_LineInfo[6],' >',data.text"
					updateLineInfo(6)
				}
				else if(find_string(data.text,Call_7_Direction,1) && m_LineState[7]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[7] = "m_LineInfo[7],' >',data.text"
					updateLineInfo(7)
				}
				else if(find_string(data.text,Call_8_Direction,1) && m_LineState[8]==CONFERENCE_STATE[3])
				{
					remove_string(data.text,',',1)
					m_LineInfo[8] = "m_LineInfo[8],' >',data.text"
					updateLineInfo(8)
				}
				else if(find_string(data.text,RoomNumber,1))
				{
					remove_string(data.text,',',1)
					send_command dvTP,"'@TXT',nButtons[51],'My Phone # ',data.text,' and IP ',IP"
				}
				else if(find_string(data.text,Polycom_Name,1))
				{
					remove_string(data.text,',',1)
					send_command dvTP,"'@TXT',nButtons[95],data.text"
				}
				else if(find_string(data.text,Polycom_Model,1))
				{
					remove_string(data.text,',',1)
					send_command dvTP,"'@TXT',nButtons[96],data.text"
				}
				else if(find_string(data.text,Polycom_SN,1))
				{
					remove_string(data.text,',',1)
					send_command dvTP,"'@TXT',nButtons[97],data.text"
				}
				else if(find_string(data.text,IP_Address,1))
				{
					remove_string(data.text,',',1)
					IP=data.text
				}
				else if(find_string(data.text,Polycom_SystemNumber,1))
				{
					remove_string(data.text,',',1)
					send_command dvTP,"'@TXT',nButtons[98],data.text"
					m_TechSupportPOTS = data.text
				}
			}
		}
	}
}


BUTTON_EVENT[dvTP,nButtons]
{
	PUSH:
		{
			cancel_wait 'Timeout'
			wait 18000 'Timeout'
				send_command dvTP,"'PAGE-Main Page'"
			m_btnindex = get_last(nButtons)
			if(m_btnindex>=1 && m_btnindex<=10) // 0..9 buttons 
			{
				if(length_string(m_numberDialed)<MAX_TEXT_LENGTH)
					m_numberDialed = "m_numberDialed,itoa(m_btnindex-1)"
				send_command dvTP,"'@TXT',nButtons[19],m_numberDialed"
			}
			else if(m_btnindex==11) // Dot/Period button 
			{
				if(length_string(m_numberDialed)<MAX_TEXT_LENGTH)
				{
					m_numberDialed = "m_numberDialed,'.'"
					send_command dvTP,"'^SHO-',itoa(nButtons[32]),',1'" // Show the baud button
					m_callType = IP_TYPE
					send_command dvTP,"'@TXT',nButtons[121],CALL_TYPE[m_callType]"
				}
				send_command dvTP,"'@TXT',nButtons[19],m_numberDialed"
			}
			else if(m_btnindex==12) // bksp
			{
				if(length_string(m_numberDialed)>0)
				{
					m_numberDialed = left_string(m_numberDialed,length_string(m_numberDialed)-1);
				  if(!find_string(m_numberDialed,'.',1)) 
					{
						send_command dvTP,"'^SHO-',itoa(nButtons[32]),',0'" // Hide the baud button
					}
				}
				send_command dvTP,"'@TXT',nButtons[19],m_numberDialed"
			}
			else if(m_btnindex==13) // clear
			{
				m_numberDialed = ''
				send_command dvTP,"'@TXT',nButtons[19],m_numberDialed"
				send_command dvTP,"'^SHO-',itoa(nButtons[32]),',0'" // Hide the baud button
			}
			else if(m_btnindex==14) // Dial
			{
				if(m_callType>POTS_TYPE) 
				{ // it must be an IP/ISDN call
					send_command vdvPolycomHDX[1],"'PROPERTY-',ManualDialCallType,',AUDIO_VIDEO'"
					send_command vdvPolycomHDX[1],"'PROPERTY-',ManualDialSpeed,',',m_DialSpeed"
				}
				else
				{
					m_callType = POTS_TYPE
					send_command vdvPolycomHDX[1],"'PROPERTY-',ManualDialCallType,',AUDIO_ONLY'"
				}
				send_command vdvPolycomHDX[1],"'DIALNUMBER-',m_numberDialed"
			}
			else if(m_btnindex==15) // Pip Cycle
			{
				PULSE[vdvPolycomHDX[1],PIP]
			}
			else if(m_btnindex==16) // Mic Cycle
			{
				PULSE[vdvPolycomHDX[1],VCONF_PRIVACY]
			}
			else if(m_btnindex==17) // Hang Up 
			{
				if(m_LineSelected[1]==true) 
				{
					ON[vdvPolycomHDX[1],DIAL_OFF_HOOK_ON]
					OFF[vdvPolycomHDX[1],DIAL_OFF_HOOK_ON]
				}
				if(m_LineSelected[2]==true) 
				{
					ON[vdvPolycomHDX[2],DIAL_OFF_HOOK_ON]
					OFF[vdvPolycomHDX[2],DIAL_OFF_HOOK_ON]
				}
				if(m_LineSelected[3]==true) 
				{
					ON[vdvPolycomHDX[3],DIAL_OFF_HOOK_ON]
					OFF[vdvPolycomHDX[3],DIAL_OFF_HOOK_ON]
				}
				if(m_LineSelected[4]==true) 
				{
					ON[vdvPolycomHDX[4],DIAL_OFF_HOOK_ON]
					OFF[vdvPolycomHDX[4],DIAL_OFF_HOOK_ON]
				}
				if(m_LineSelected[5]==true) 
				{
					ON[vdvPolycomHDX[5],DIAL_OFF_HOOK_ON]
					OFF[vdvPolycomHDX[5],DIAL_OFF_HOOK_ON]
				}
				if(m_LineSelected[6]==true) 
				{
					ON[vdvPolycomHDX[6],DIAL_OFF_HOOK_ON]
					OFF[vdvPolycomHDX[6],DIAL_OFF_HOOK_ON]
				}
				if(m_LineSelected[7]==true) 
				{
					ON[vdvPolycomHDX[7],DIAL_OFF_HOOK_ON]
					OFF[vdvPolycomHDX[7],DIAL_OFF_HOOK_ON]
				}
				if(m_LineSelected[8]==true) 
				{
					ON[vdvPolycomHDX[8],DIAL_OFF_HOOK_ON]
					OFF[vdvPolycomHDX[8],DIAL_OFF_HOOK_ON]
				}
				
				m_LineSelected[1]=false
				m_LineSelected[2]=false
				m_LineSelected[3]=false
				m_LineSelected[4]=false
				m_LineSelected[5]=false
				m_LineSelected[6]=false
				m_LineSelected[7]=false
				m_LineSelected[8]=false
			}
			else if(m_btnindex==18) // Hang Up All
			{
				send_command vdvPolycomHDX[1],'HANGUPALL'
			}
			else if(m_btnindex==22) // Logo / installer screen
			{
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Polycom_Name"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Polycom_Model"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Polycom_SN"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Polycom_SystemNumber"
				send_command vdvPolycomHDX[1],"'?VERSION'"
				send_command vdvPolycomHDX[1],"'?FWVERSION'"
			}
			else if(m_btnindex>=23 && m_btnindex<=31) // IP call rates
			{
				m_BaudRateIndex = m_btnindex-22
				m_DialSpeed = BAUD_RATES[m_BaudRateIndex]
			}
			else if(m_btnindex>=33 && m_btnindex<=40) // Line select
			{
				m_LineSelected[m_btnindex-32] = !m_LineSelected[m_btnindex-32]
			}
			else if(m_btnindex>=122 && m_btnindex<=131) // DTMF tone 
			{
				send_command vdvPolycomHDX[1],"'DTMF-',itoa(m_btnindex-122)"
				send_command dvTP,"'@TXT',nButtons[48],itoa(m_btnindex-122)"
			}
			else if(m_btnindex==132) // DTMF * tone 
			{
				send_command vdvPolycomHDX[1],"'DTMF-*'"
				send_command dvTP,"'@TXT',nButtons[48],'*'"
			}
			else if(m_btnindex==133) // DTMF # tone 
			{
				send_command vdvPolycomHDX[1],"'DTMF-#'"
				send_command dvTP,"'@TXT',nButtons[48],'#'"
			}
			else if(m_btnindex==49) // DTMF exit
			{
				send_command dvTP,"'@TXT',nButtons[48],''"
			}
			else if(m_btnindex==50) // status button 
			{
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_1_Name"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_2_Name"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_3_Name"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_4_Name"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_5_Name"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_6_Name"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_7_Name"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_8_Name"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_1_Number"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_2_Number"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_3_Number"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_4_Number"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_5_Number"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_6_Number"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_7_Number"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_8_Number"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_1_Direction"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_2_Direction"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_3_Direction"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_4_Direction"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_5_Direction"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_6_Direction"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_7_Direction"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',Call_8_Direction"
				send_command vdvPolycomHDX[1],"'?PROPERTY-',RoomNumber"
			}
			else if(m_btnindex==52) // Local phonebook selected 
			{
				m_phonebookLocality = 0
				clearPhoneBookEntries()
				send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKCLOSESEARCH-',KEY"
				send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKSEARCH-',KEY,',ID=*'"
			  send_command dvTP,"'@PPN-_wait'"
			}
			else if(m_btnindex==53) // Global phonebook selected 
			{
				m_phonebookLocality = 1
				clearPhoneBookEntries()
				send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKCLOSESEARCH-',KEY"
				send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKSEARCH-',KEY,',ID=*'"
			  send_command dvTP,"'@PPN-_wait'"
			}
			else if(m_btnindex==63) // Phone Book button... start search  
			{
				if(m_phonebookMatches==0)
				{
					send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKCLOSESEARCH-',KEY"
					send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKSEARCH-',KEY,',ID=*'"
			    send_command dvTP,"'@PPN-_wait'"
				}
			}
			else if(m_btnindex>=57 && m_btnindex<=62) // phonebook entry select
			{
				m_phonebookIndex = m_btnindex-56
			}
			else if(m_btnindex==56) // Dial from phonebook  
			{
				if(m_phonebookIndex)
				{
					if(length_string(m_phonebookName[m_phonebookIndex]))
					{
						send_command vdvPolycomHDX[1],"'DIALID-',m_phonebookName[m_phonebookIndex]"
				    send_command dvTP,"'@TXT',nButtons[19],m_phonebookName[m_phonebookIndex]"
						m_numberDialed = m_phonebookNumber[m_phonebookIndex]
					}
				}
			}
			else if(m_btnindex==54) // scroll up
			{
				clearPhoneBookEntries()
				send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKPREV-',KEY,',',itoa(SEARCH_SIZE)"
			}
			else if(m_btnindex==55) // scroll down 
			{
				clearPhoneBookEntries()
				send_command vdvPolycomHDX[m_phonebookLocality+1],"'PHONEBOOKNEXT-',KEY,',',itoa(SEARCH_SIZE)"
			}
			else if(m_btnindex==64) // Near camera selected 
			{
				m_cameraLocality=1
				send_command dvTP,"'@TXT',nButtons[68],CAMERAS[m_cameraSelected[m_cameraLocality]]"
				pulse[vdvPolycomHDX[1],313] // pulse the Near button
			}
			else if(m_btnindex==65) // Far camera selected 
			{
				m_cameraLocality=2
				send_command dvTP,"'@TXT',nButtons[68],CAMERAS[m_cameraSelected[m_cameraLocality]]"
				pulse[vdvPolycomHDX[1],307] // pulse the Far button
			}
			else if(m_btnindex==66) // Camera next
			{
				integer cam 
				cam = m_cameraSelected[m_cameraLocality]+1
				if(cam>MAX_INPUTS) cam=1
				send_command vdvPolycomHDX[m_cameraLocality],"'INPUT-CAMERA,',itoa(cam)"
				send_command dvTP,"'@PPN-_wait'"
				
			}
			else if(m_btnindex==67) // Camera prev
			{
				integer cam 
				cam = m_cameraSelected[m_cameraLocality]-1
				if(cam==0) cam=MAX_INPUTS
				send_command vdvPolycomHDX[m_cameraLocality],"'INPUT-CAMERA,',itoa(cam)"
				send_command dvTP,"'@PPN-_wait'"
				
			}
			else if(m_btnindex==69) // Zoom In
			{
				ON[vdvPolycomHDX[m_cameraLocality],ZOOM_IN]
			}
			else if(m_btnindex==70) // Zoom OUT
			{
				ON[vdvPolycomHDX[m_cameraLocality],ZOOM_OUT]
			}
			else if(m_btnindex==71) // Tilt up
			{
				ON[vdvPolycomHDX[m_cameraLocality],TILT_UP]
			}
			else if(m_btnindex==72) // Tilt down
			{
				ON[vdvPolycomHDX[m_cameraLocality],TILT_DN]
			}
			else if(m_btnindex==73) // PAN RIGHT
			{
				ON[vdvPolycomHDX[m_cameraLocality],PAN_RT]
			}
			else if(m_btnindex==74) // pan left
			{
				ON[vdvPolycomHDX[m_cameraLocality],PAN_LT]
			}
			else if(m_btnindex==81) // Menu auto 
			{
				PULSE[vdvPolycomHDX[1],304]
			}
			else if(m_btnindex==82) // Menu keybrd 
			{
				PULSE[vdvPolycomHDX[1],310]
			}
			else if(m_btnindex==83) // Menu return
			{
				PULSE[vdvPolycomHDX[1],MENU_BACK]
			}
			else if(m_btnindex==84) // Menu up
			{
				PULSE[vdvPolycomHDX[1],MENU_UP]
			}
			else if(m_btnindex==85) // Menu dn
			{
				PULSE[vdvPolycomHDX[1],MENU_DN]
			}
			else if(m_btnindex==86) // Menu LEFT
			{
				PULSE[vdvPolycomHDX[1],MENU_LT]
			}
			else if(m_btnindex==87) // Menu RIGHT
			{
				PULSE[vdvPolycomHDX[1],MENU_RT]
			}
			else if(m_btnindex==88) // Menu SELECT
			{
				PULSE[vdvPolycomHDX[1],MENU_SELECT]
			}
			else if(m_btnindex==89) // Volume up
			{
				ON[vdvPolycomHDX[1],VOL_UP]
			}
			else if(m_btnindex==90) // Volume dn
			{
				ON[vdvPolycomHDX[1],VOL_DN]
			}
			else if(m_btnindex==99)
			{
				send_command vdvPolycomHDX[1],'REINIT'
				m_phonebookMatches = 0
			}
			else if(m_btnindex==100) // Tech Support
			{
				send_command vdvPolycomHDX[1],"'PROPERTY-',ManualDialCallType,',AUDIO_ONLY'"
				send_command vdvPolycomHDX[1],"'DIALNUMBER-',m_TechSupportPOTS"
			}
			else if(m_btnindex==101) // Auto-Answer
			{
				PULSE[vdvPolycomHDX[1],DIAL_AUTO_ANSWER]
				if([vdvPolycomHDX[1],DIAL_AUTO_ANSWER_ON]) 
					Off[vdvPolycomHDX[1],300]
				else On[vdvPolycomHDX[1],300]
			}
			else if(m_btnindex==102) // Auto-Mute
			{
				[vdvPolycomHDX[1],301]=![vdvPolycomHDX[1],301]
			}
			else if(m_btnindex==111) // Do not disturb
			{
				[vdvPolycomHDX[1],303]=![vdvPolycomHDX[1],303]
			}
			else if(m_btnindex==103)
			{
				send_command vdvPolycomHDX[1],'VIEW_MODE-AUTO'
			}
			else if(m_btnindex==104)
			{
				send_command vdvPolycomHDX[1],'VIEW_MODE-PRESENTATION'
			}
			else if(m_btnindex==105)
			{
				send_command vdvPolycomHDX[1],'VIEW_MODE-DISCUSSION'
			}
			else if(m_btnindex==106)
			{
				send_command vdvPolycomHDX[1],'VIEW_MODE-FULLSCREEN'
			}
			else if(m_btnindex==107) //PiP cycle
			{
				PULSE[vdvPolycomHDX[1],PIP_POS]
			}
			else if(m_btnindex==109) // Setup button 
			{
				send_command vdvPolycomHDX[1],'?MEETING_PASSWORD'
			}
			else if(m_btnindex==115) //Streaming
			{
				m_Streaming =! m_Streaming
				send_command vdvPolycomHDX[1],"'STREAM-',m_StreamState[m_Streaming+1]"
			}
			else if(m_btnindex==116) //Play
			{
				PULSE[vdvPolycomHDX[1],PLAY]
			}
			else if(m_btnindex==117) //STOP
			{
				PULSE[vdvPolycomHDX[1],STOP]
			}
			else if(m_btnindex==118) //Far control of near camera
			{
				[vdvPolycomHDX[1],302] = ![vdvPolycomHDX[1],302]
			}
			else if(m_btnindex==119) //PiP Swap
			{
				PULSE[vdvPolycomHDX[1],PIP_SWAP]
			}
			else if(m_btnindex==120) // meetig password 
			{
				m_MeetingpasswordSet = true
			}
			else if(m_btnindex==121) // POTS/ISDN/IP call type selector 
			{
				m_callType++
				if(m_callType>3) m_callType=POTS_TYPE
				send_command dvTP,"'@TXT',nButtons[121],CALL_TYPE[m_callType]"
				if(m_callType!=POTS_TYPE)send_command dvTP,"'^SHO-',itoa(nButtons[32]),',1'" // Show the CALL RATE button
			  else send_command dvTP,"'^SHO-',itoa(nButtons[32]),',0'" // Hide the baud button
			}
			else if(m_btnindex==112) // answer call
			{
				ON[vdvPolycomHDX[m_LineRinging],DIAL_OFF_HOOK_ON]
			}
			else if(m_btnindex==113) // reject call
			{
				PULSE[vdvPolycomHDX[m_LineRinging],DIAL_OFF_HOOK_ON]
			}
		}
	HOLD[20]:
		{
			if(m_btnindex>=75 && m_btnindex<=80)
			{ // preset save
				send_command vdvPolycomHDX[m_cameraLocality],"'CAMERAPRESETSAVE-',itoa(m_btnindex-74)"
			  if([vdvPolycomHDX[1],DATA_INITIALIZED]) send_command dvTP,"'@PPN-_presetsaved'"
			}
		}
	RELEASE:
		{
			if(m_btnindex==69) // Zoom In
			{
				OFF[vdvPolycomHDX[m_cameraLocality],ZOOM_IN]
			}
			else if(m_btnindex==70) // Zoom OUT
			{
				OFF[vdvPolycomHDX[m_cameraLocality],ZOOM_OUT]
			}
			else if(m_btnindex==71) // Tilt up
			{
				OFF[vdvPolycomHDX[m_cameraLocality],TILT_UP]
			}
			else if(m_btnindex==72) // Tilt down
			{
				OFF[vdvPolycomHDX[m_cameraLocality],TILT_DN]
			}
			else if(m_btnindex==73) // PAN RIGHT
			{
				OFF[vdvPolycomHDX[m_cameraLocality],PAN_RT]
			}
			else if(m_btnindex==74) // pan left
			{
				OFF[vdvPolycomHDX[m_cameraLocality],PAN_LT]
			}
			else if(m_btnindex>=75 && m_btnindex<=80)
			{ // preset recall
				send_command vdvPolycomHDX[m_cameraLocality],"'CAMERAPRESET-',itoa(m_btnindex-74)"
			}
			else if(m_btnindex==89) // Volume up
			{
				OFF[vdvPolycomHDX[1],VOL_UP]
			}
			else if(m_btnindex==90) // Volume dn
			{
				OFF[vdvPolycomHDX[1],VOL_DN]
			}
		}
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvTP,nButtons[15]] = [vdvPolycomHDX[1],PIP_FB]
[dvTP,nButtons[16]] = [vdvPolycomHDX[1],VCONF_PRIVACY_FB]

[dvTP,nButtons[23]] = (m_BaudRateIndex==1)
[dvTP,nButtons[24]] = (m_BaudRateIndex==2)
[dvTP,nButtons[25]] = (m_BaudRateIndex==3)
[dvTP,nButtons[26]] = (m_BaudRateIndex==4)
[dvTP,nButtons[27]] = (m_BaudRateIndex==5)
[dvTP,nButtons[28]] = (m_BaudRateIndex==6)
[dvTP,nButtons[29]] = (m_BaudRateIndex==7)
[dvTP,nButtons[30]] = (m_BaudRateIndex==8)
[dvTP,nButtons[31]] = (m_BaudRateIndex==9)

[dvTP,nButtons[33]] = m_LineSelected[1]
[dvTP,nButtons[34]] = m_LineSelected[2]
[dvTP,nButtons[35]] = m_LineSelected[3]
[dvTP,nButtons[36]] = m_LineSelected[4]
[dvTP,nButtons[37]] = m_LineSelected[5]
[dvTP,nButtons[38]] = m_LineSelected[6]
[dvTP,nButtons[39]] = m_LineSelected[7]
[dvTP,nButtons[40]] = m_LineSelected[8]

[dvTP,nButtons[21]] = [vdvPolycomHDX[1],DATA_INITIALIZED]

[dvTP,nButtons[52]] = (m_phonebookLocality==0)
[dvTP,nButtons[53]] = (m_phonebookLocality==1)


[dvTP,nButtons[57]] = (m_phonebookIndex==1)
[dvTP,nButtons[58]] = (m_phonebookIndex==2)
[dvTP,nButtons[59]] = (m_phonebookIndex==3)
[dvTP,nButtons[60]] = (m_phonebookIndex==4)
[dvTP,nButtons[61]] = (m_phonebookIndex==5)
[dvTP,nButtons[62]] = (m_phonebookIndex==6)

[dvTP,nButtons[64]] = (m_cameraLocality==1)
[dvTP,nButtons[65]] = (m_cameraLocality==2)
[dvTP,nButtons[75]] = (m_cameraPreset[m_cameraLocality]==1)
[dvTP,nButtons[76]] = (m_cameraPreset[m_cameraLocality]==2)
[dvTP,nButtons[77]] = (m_cameraPreset[m_cameraLocality]==3)
[dvTP,nButtons[78]] = (m_cameraPreset[m_cameraLocality]==4)
[dvTP,nButtons[79]] = (m_cameraPreset[m_cameraLocality]==5)
[dvTP,nButtons[80]] = (m_cameraPreset[m_cameraLocality]==6)


[dvTP,nButtons[101]] = [vdvPolycomHDX[1],DIAL_AUTO_ANSWER_ON]
[dvTP,nButtons[102]] = [vdvPolycomHDX[1],301]
[dvTP,nButtons[111]] = [vdvPolycomHDX[1],303]
[dvTP,nButtons[103]] = (m_ViewMode=='AUTO')
[dvTP,nButtons[104]] = (m_ViewMode=='PRESENTATION')
[dvTP,nButtons[105]] = (m_ViewMode=='DISCUSSION')
[dvTP,nButtons[106]] = (m_ViewMode=='FULLSCREEN')

[dvTP,nButtons[116]] = [vdvPolycomHDX[1],PLAY_FB]
[dvTP,nButtons[117]] = [vdvPolycomHDX[1],STOP_FB]
[dvTP,nButtons[118]] = [vdvPolycomHDX[1],302]
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

