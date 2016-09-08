// PacketSniffer.h : main header file for the PacketSniffer application
//
#pragma once

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols
#include "USBDataCapture.h"

// CPacketSnifferApp:
// See PacketSniffer.cpp for the implementation of this class
//

class CPacketSnifferApp : public CWinApp
{
public:
	CPacketSnifferApp();


// Overrides
public:
	virtual BOOL InitInstance();

	CUSBDataCapture* p_DataThread;
	int ExitInstance();

// Implementation
	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
	afx_msg void OnEditConfig();
	void OnReceiveData(WPARAM,LPARAM);
	void OnReceiveRSSIData(WPARAM,LPARAM);

};

extern CPacketSnifferApp theApp;