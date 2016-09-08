// USBDataCapture.cpp : implementation file
//

#include "stdafx.h"
#include "PacketSniffer.h"
#include "USBDataCapture.h"
#include "SnifferEvent.h"


// CUSBDataCapture

IMPLEMENT_DYNCREATE(CUSBDataCapture, CWinThread)

CUSBDataCapture::CUSBDataCapture()
{

}

CUSBDataCapture::~CUSBDataCapture()
{
	//delete [] RxBuffer;
}

BOOL CUSBDataCapture::InitInstance()  /// TODO: Get this to send "go" message to embedded packet sniffer, wait for ACK.
{
	m_datasource.ListDevices();  // make sure currently connected devices are enumerated

	// attempt to add a datapoint to test message passing
	CSnifferEvent *newEvent = new CSnifferEvent();

	theApp.PostThreadMessage(WM_SEND_DATA,0,(LPARAM)newEvent);  // This works... but it seems weird.

	ReadState = WAIT_FOR_PREAMBLE;
	PreambleCounter = 0;
	AckCounter = 0;
	MessageCounter = 0;

	return TRUE;
}

int CUSBDataCapture::ExitInstance()
{	
	CUSBDataCapture::pause_data_capture(0,0);  // tell the CUmote to go into the wait state
	m_datasource.DisconnectFromDevice();
	delete [] RxBuffer;
	delete [] MsgBuffer;
	return CWinThread::ExitInstance();
}

BEGIN_MESSAGE_MAP(CUSBDataCapture, CWinThread)
	ON_THREAD_MESSAGE(WM_ASSOCIATE_THREAD,set_device_index)
	ON_THREAD_MESSAGE(WM_SET_CHANNEL,set_device_channel)
	ON_THREAD_MESSAGE(WM_PAUSE_CAPTURE,pause_data_capture)
	ON_THREAD_MESSAGE(WM_RESUME_CAPTURE,resume_data_capture)
	ON_THREAD_MESSAGE(WM_START_SCAN,start_rssi_scan)
END_MESSAGE_MAP()


// CUSBDataCapture message handlers

void CUSBDataCapture::set_device_index(WPARAM wParam, LPARAM lParam)  {   // modify in the future to keep track of other device parameters?
	// wParam holds DWORD which indicates Device index. lParam unused.
	device_index = (DWORD) wParam;
	/// Connect to device...  
	if (m_datasource.is_connected == TRUE)  {
		return;  // disregard command to connect if we're already connected.
	}
	
	if (!(m_datasource.ConnectToDevice((int)device_index)))  {
		AfxMessageBox("Failed to connect to selected device.");   /// TODO: better error handling!
	}

	m_datasource.SetBaudRate(500000);  // 500,000 bps
	m_datasource.SetDataCharacteristics(FT_BITS_8,FT_STOP_BITS_1,FT_PARITY_NONE);
	m_datasource.SetFlowControl(FT_FLOW_NONE,0,0);

	// set up an event to wait for
	if (hEvent == NULL)  {
		hEvent = CreateEvent(NULL,FALSE,FALSE,"");
		m_datasource.SetEventNotification(FT_EVENT_RXCHAR,hEvent);
	}

	//purge buffers, just to make sure we're clean
	m_datasource.Purge(FT_PURGE_RX|FT_PURGE_TX);

}


BOOL CUSBDataCapture::OnIdle(LONG lCount)  {   /// TODO: fix race condition... what is crashing, anyway?
	DWORD nRxQueue, nTxQueue, devStatus,nBytesRead;

	WaitForSingleObject(hEvent,500);  // wait for an RX character to appear... but only for one second.
	m_datasource.GetStatus(&nRxQueue,&nTxQueue,&devStatus);  // get status information

	if (nRxQueue > 0)  {   // data available. so read it!     
		m_datasource.Read(RxBuffer,nRxQueue,&nBytesRead);
		DWORD i = 0;
		for (i; i < nBytesRead; i++) {
			if (ReadState == WAIT_FOR_PREAMBLE)  {
				if (RxBuffer[i] == (unsigned char) 255)  {   // Preamble to message has 4 bytes of 0xff
					if (++PreambleCounter == 4) {
						ReadState = GETTING_SIZE;
						PreambleCounter = 0;
					}
				}
				else if ((PreambleCounter == 3)&&(RxBuffer[i] == (unsigned char)170)) {   // 170 is aa
					ReadState = READING_ED_MESSAGE;
					PreambleCounter = 0;
				}
				else
					PreambleCounter = 0;
			}
			else if (ReadState == GETTING_SIZE)  {
				MessageCounter = 0;
				MessageSize = RxBuffer[i];  // get the size of the message to come
				ReadState = READING_MESSAGE;
			}
			else if (ReadState == READING_MESSAGE)  {
				MsgBuffer[MessageCounter++] = RxBuffer[i] + 65;  // Get current byte of message
				if (MessageCounter == MessageSize)  {  // this is the end of the message
					MessageCounter = 0;
					ReadState = WAIT_FOR_PREAMBLE;
					CSnifferEvent *newEvent = new CSnifferEvent(MsgBuffer,MessageSize);
					theApp.PostThreadMessage(WM_SEND_DATA,current_channel,(LPARAM)newEvent);   // Add the newly completed message to the document
				}
			}
			else if (ReadState == WAIT_FOR_ACK)  {   
				if (CTime::GetCurrentTime() > timeout)  {  // waited too long for ACK, alert user to error.
					ReadState = WAIT_FOR_PREAMBLE;
					//Beep(750,300);
					AfxMessageBox("Packet Sniffer did not respond to message. Check the connection.");
				}
				else if ((AckCounter < 3) && (RxBuffer[i] == (unsigned char) 255))  {
					AckCounter++;
				}
				else if ((AckCounter == 3) && ((RxBuffer[i] == (unsigned char)221)))  {  // 221 = 0xdd
					// this is the end of the ack message!
					ReadState = WAIT_FOR_PREAMBLE;
					AckCounter = 0;
				}
				else  {
					AckCounter = 0;
				}
			}
			else if (ReadState == READING_ED_MESSAGE)  {
				MsgBuffer[MessageCounter++] = RxBuffer[i] + 65;  // Get current byte of message
				if (MessageCounter == 16)  {  // this is the end of the message
					MessageCounter = 0;
					ReadState = WAIT_FOR_PREAMBLE;
					int i = 0;
					for (i;i<16;i++)  {
						EDbuff[i] = MsgBuffer[i];
					}
					theApp.PostThreadMessage(WM_SEND_RSSI_DATA,0,(LPARAM)EDbuff);   /// SUSPECT that if this message is sent when config dialog is closed, main app tries to access recently destroyed config dialog object...
				}
			}
		} 
	}

	else if (ReadState == WAIT_FOR_ACK)  {
		if (CTime::GetCurrentTime() > timeout)  {
			ReadState = WAIT_FOR_PREAMBLE;
			Beep(750,200);
			AfxMessageBox("PacketSniffer did not respond to message. Check the connection.");   /// now, flush the buffers?
		}
	}

	return TRUE;
}

void CUSBDataCapture::set_device_channel(WPARAM wParam, LPARAM lParam)  {  
	// wParam holds DWORD which indicates the channel
	DWORD channel = (DWORD) wParam;
	current_channel = channel;
	DWORD nBytesWritten;
	TxBuffer[0] = 171;  // 0xab
	TxBuffer[1] = (unsigned char) channel; 
	m_datasource.Write(TxBuffer,2,&nBytesWritten);
	if (nBytesWritten != 2)  {
		AfxMessageBox("Failed to write 2 bytes!");
	}
	CTimeSpan *temp = new CTimeSpan(0,0,0,1);  // 1 second
	timeout = CTime::GetCurrentTime() + *temp;  // one second from now we'll time out
	ReadState = WAIT_FOR_ACK;
	delete temp;
}

void CUSBDataCapture::pause_data_capture(WPARAM wParam, LPARAM lParam)  {
	// if we are pausing in the middle of a data capture, flush the device's buffers, get rid of extraneous data.
	if (ReadState == READING_MESSAGE || ReadState == READING_ED_MESSAGE)  {
		m_datasource.Purge(FT_PURGE_RX|FT_PURGE_TX);
	}

	DWORD nBytesWritten;
	TxBuffer[0] = 157;  // 0x9d, which is pause command
	m_datasource.Write(TxBuffer,1,&nBytesWritten);
	CTimeSpan *temp = new CTimeSpan(0,0,0,1);  // 1 second
	timeout = CTime::GetCurrentTime() + *temp;
	ReadState = WAIT_FOR_ACK;
	delete temp;
}

void CUSBDataCapture::resume_data_capture(WPARAM wParam, LPARAM lParam)  {
	DWORD nBytesWritten;
	TxBuffer[0] = 202;  // 0xca, which is run command
	m_datasource.Write(TxBuffer,1,&nBytesWritten);
	CTimeSpan *temp = new CTimeSpan(0,0,0,1);  // 1 second
	timeout = CTime::GetCurrentTime() + *temp;
	ReadState = WAIT_FOR_ACK;
	delete temp;
}

void CUSBDataCapture::start_rssi_scan(WPARAM wParam, LPARAM lParam)  {
	// wParam and lParam are unused in this function
	DWORD nBytesWritten;
	TxBuffer[0] = 186;  // 0xba
	m_datasource.Write(TxBuffer,1,&nBytesWritten);
	CTimeSpan *temp = new CTimeSpan(0,0,0,1);
	timeout = CTime::GetCurrentTime() + *temp;
	ReadState = WAIT_FOR_ACK;
	delete temp;
}

void CUSBDataCapture::reset_cumote()  {
	DWORD nBytesWritten;
	TxBuffer[0] = 186;  // 0x9d
	m_datasource.Write(TxBuffer,1,&nBytesWritten);
}