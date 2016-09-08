#pragma once
#include "afx.h"

#ifndef _CSnifferEvent_
#define _CSnifferEvent_

class CSnifferEvent :
	public CObject
{
	DECLARE_SERIAL(CSnifferEvent);
public:
	CSnifferEvent(void);
	CSnifferEvent(char msg);
	CSnifferEvent(unsigned char *msg,DWORD len);
	~CSnifferEvent(void);
	void Serialize(CArchive &ar);
	void set_channel(DWORD c);
	void Draw(CDC* pDC,int data_index,bool is_gray);  // function to draw data on screen
	

private:  // member variables
	CString m_sDataFrame;  // contents of message
	int m_nLQI;
	int m_nChannel;  
	SYSTEMTIME m_dTimestamp;
	int m_nEventType;
	DWORD channel;
	
	void TranslateToDecimal(void);
public:  // accessor functions

};

#endif