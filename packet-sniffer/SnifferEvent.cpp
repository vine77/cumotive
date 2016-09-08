#include "StdAfx.h"
#include ".\snifferevent.h"

IMPLEMENT_SERIAL(CSnifferEvent,CObject,1);

CSnifferEvent::CSnifferEvent(void)
{
	GetSystemTime(&m_dTimestamp);
	m_nChannel = 13;
	m_nEventType = 1;
	m_nLQI = 87;
	m_sDataFrame = "This is a bit of data!";
}

CSnifferEvent::CSnifferEvent(char msg)  {
	GetSystemTime(&m_dTimestamp);
	m_sDataFrame = msg;
}

CSnifferEvent::CSnifferEvent(unsigned char *msg, DWORD len)  {
	GetSystemTime(&m_dTimestamp);
	CString *message = new CString((char *)msg,len);
	m_sDataFrame = *message;
}

CSnifferEvent::~CSnifferEvent(void)
{
}

void CSnifferEvent::set_channel(DWORD c)  {
	channel = c;
}

void CSnifferEvent::TranslateToDecimal()  {
/*	CString translated_string = "";
	int len = m_sDataFrame.GetLength();
	int i = 0;
	unsigned char currbyte, hundred, ten;
	unsigned char number[4],*number_head;
	int number_index;
	number_head = number;
	for (i; i < len; i++)  {
		number_index = 0;
		currbyte = m_sDataFrame[i];
		if (currbyte >= 100)  {
			hundred = currbyte/100;
			number[number_index++] = (unsigned char)(hundred + 48);
			currbyte = currbyte - hundred*100;
		}
		if (currbyte >= 10)  {
			ten = currbyte/10;
			number[number_index++] = (unsigned char)(ten + 48);
			currbyte = currbyte - ten*10;
		}
		number[number_index++] = (unsigned char)(currbyte + 48);
		number[number_index++] = (unsigned char)(32);  // space
		translated_string += (new CString(number_head,(DWORD)number_index));
	}
	m_sDataFrame = translated_string;*/
}

void CSnifferEvent::Draw(CDC *pDC,int data_index,bool is_gray)  {
	CString to_print;
	/// TODO: Call function to translate each character of string into a new string, displaying individual numbers in decimal or hex, etc. or, ascii.
//TranslateToDecimal();
	to_print.Format("Channel %d at %d:%d:%d:%d -> %s",channel,((m_dTimestamp.wHour+7)%12),m_dTimestamp.wMinute,m_dTimestamp.wSecond,m_dTimestamp.wMilliseconds,m_sDataFrame);
	//pDC->TextOut(0,0,to_print);
	CRect *back_block = new CRect(0,data_index*40,400,(data_index+1)*40);
	CRect *print_block = new CRect(2,data_index*40+2,400-2,(data_index+1)*40-2);
		pDC->FillSolidRect(back_block,RGB(0,0,0));
	if (is_gray)  {
		pDC->FillSolidRect(print_block,RGB(200,200,200));
	}
	else  {
		pDC->FillSolidRect(print_block,RGB(255,255,255));
	}
	pDC->DrawText(to_print,*print_block,0);
}

void CSnifferEvent::Serialize(CArchive &ar)  {
	//CObject::Serialize(ar);
	if (ar.IsStoring())
	{		
		ar << m_dTimestamp.wHour;
		ar << m_dTimestamp.wMinute;
		ar << m_dTimestamp.wSecond;
		ar << m_dTimestamp.wMilliseconds;
		ar << m_nChannel;
		ar << m_nEventType;
		ar << m_nLQI;
		ar << m_sDataFrame;
		// TODO: add storing code here
	}
	else
	{
		ar >> m_dTimestamp.wHour;
		ar >> m_dTimestamp.wMinute;
		ar >> m_dTimestamp.wSecond;
		ar >> m_dTimestamp.wMilliseconds;
		ar >> m_nChannel;
		ar >> m_nEventType;
		ar >> m_nLQI;
		ar >> m_sDataFrame;		
		// TODO: add loading code here
	}
}