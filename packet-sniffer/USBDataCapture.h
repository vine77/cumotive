#pragma once
#include "SerialD2XX.h"

#define WM_ASSOCIATE_THREAD (WM_USER+1)   // main thread to this thread
#define WM_SEND_DATA		(WM_USER+2)    // this thread passes data to main thread
#define WM_SET_CHANNEL		(WM_USER+3)		// use this message to tell thread to change the channel to the indicated channel
#define WM_PAUSE_CAPTURE	(WM_USER+4)    // use this message to pause data capture
#define WM_RESUME_CAPTURE	(WM_USER+5)		// use this message to resume data capture after having been paused
#define WM_START_SCAN		(WM_USER+6)    // tell the CUmote to start the real-time RSSI scan
#define WM_STOP_SCAN		(WM_USER+7)	   // tell the CUmote to stop the real-time RSSI scan
#define WM_SEND_RSSI_DATA	(WM_USER+8)    
// CUSBDataCapture

#define WAIT_FOR_PREAMBLE	1
#define READING_MESSAGE		2
#define GETTING_SIZE		3
#define WAIT_FOR_ACK		4
#define READING_ED_MESSAGE  5

class CUSBDataCapture : public CWinThread
{
	DECLARE_DYNCREATE(CUSBDataCapture)

public:
	CUSBDataCapture();           // protected constructor used by dynamic creation
	virtual ~CUSBDataCapture();

public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();

protected:
	DECLARE_MESSAGE_MAP()

private:
	CSerialD2XX m_datasource;
	DWORD device_index;
	HANDLE hEvent;  // handle to event which is signalled by USB device
	unsigned char RxBuffer[256]; // keep track of last 256 characters to be received. Make this larger?
	CString currMsg;  // current message which is being constructed
	DWORD ReadState;  // state variable for reading
	DWORD PreambleCounter;
	DWORD AckCounter;
	DWORD MessageSize;
	DWORD MessageCounter;
	DWORD current_channel;  // store current operating channel of CUmote
	CTime timeout;
	unsigned char MsgBuffer[256];
	unsigned char TxBuffer[2];  // largest message is 2 bytes...
	unsigned char EDbuff[16];
	void reset_cumote(void);
public:
	void set_device_index(WPARAM,LPARAM);
	BOOL OnIdle(LONG lCount);
	void set_device_channel(WPARAM,LPARAM);
	void pause_data_capture(WPARAM,LPARAM);
	void resume_data_capture(WPARAM,LPARAM);
	void start_rssi_scan(WPARAM,LPARAM);
	
};


