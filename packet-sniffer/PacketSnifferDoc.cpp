// PacketSnifferDoc.cpp : implementation of the CPacketSnifferDoc class
//

#include "stdafx.h"
#include "PacketSniffer.h"
#include "SnifferEventList.h"

#include "USBDataCapture.h"

#include "PacketSnifferDoc.h"
#include ".\packetsnifferdoc.h"

#include "ConfigDialog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CPacketSnifferDoc

IMPLEMENT_DYNCREATE(CPacketSnifferDoc, CDocument)

BEGIN_MESSAGE_MAP(CPacketSnifferDoc, CDocument)
	ON_COMMAND(ID_EDIT_CONFIG, OnEditConfig)
	ON_COMMAND(ID_EDIT_RUN, OnEditRun)
	ON_COMMAND(ID_EDIT_PAUSE, OnEditPause)
END_MESSAGE_MAP()


// CPacketSnifferDoc construction/destruction

CPacketSnifferDoc::CPacketSnifferDoc()
{
	// TODO: add one-time construction code here
	selected_device = -1;
	theApp.p_DataThread->CreateThread(CREATE_SUSPENDED);  // create the thread, but don't let it run until we've got a device to connect to
	theApp.p_DataThread->m_bAutoDelete = FALSE;  // don't auto-delete the object when we terminate the thread
}

CPacketSnifferDoc::~CPacketSnifferDoc()
{
//	if (p_DataThread != NULL) delete p_DataThread;
	m_SnifferEvents.RemoveAll();
	ASSERT(m_SnifferEvents.IsEmpty());
}

BOOL CPacketSnifferDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)
	m_SnifferEvents.RemoveAll();

	return TRUE;
}




// CPacketSnifferDoc serialization

void CPacketSnifferDoc::Serialize(CArchive& ar)
{
	if (ar.IsStoring())
	{
		// TODO: add storing code here
	}
	else
	{
		// TODO: add loading code here
	}
}


// CPacketSnifferDoc diagnostics

#ifdef _DEBUG
void CPacketSnifferDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CPacketSnifferDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG


// CPacketSnifferDoc commands

void CPacketSnifferDoc::OnEditConfig()
{
	configDlg.DoModal();  // run dialog box
	/// TODO: pass data from dialog to tell whether or not to proceed with the rest of this code...
	if (!configDlg.is_data_valid())  {
		theApp.p_DataThread->Delete();
	}
	theApp.p_DataThread->PostThreadMessage(WM_PAUSE_CAPTURE,0,0);  // send a message to tell the thread to stop the real-time RSSI scan
	
	
	selected_device = configDlg.get_selected_device();
	if (selected_device < 0)
		return;  // don't do anything if no device was selected!
	
	// Now that we know which device to connect to, pass thread a message containing index of device to connect to.
	//if (p_DataThread->m_hThread != NULL)  { /// TODO: GET THIS STATEMENT WORKING PROPERLY 
	//	AfxMessageBox("Please stop the current capture before attempting to set up another.");
	//}
	//else {
	//	p_DataThread->CreateThread(CREATE_SUSPENDED); // Start the thread halted
		/// post a message to get the thread to start. Messages to send to thread: Associate, Go, Pause, Exit
		/// Messages thread will send: DataAvailable
		
		theApp.p_DataThread->PostThreadMessage(WM_SET_CHANNEL,(DWORD)configDlg.get_selected_channel(),0);
		//theApp.p_DataThread->ResumeThread();
	//}	
}

void CPacketSnifferDoc::set_selected_device(int val)  {
	selected_device = val;
}

void CPacketSnifferDoc::clear_selected_device()  {
	selected_device = -1;
}

void CPacketSnifferDoc::OnEditRun()
{
	// TODO: Add your command handler code here
	//p_DataThread->ResumeThread();  // get the thread running again.
	theApp.p_DataThread->PostThreadMessage(WM_RESUME_CAPTURE,0,0);
}

void CPacketSnifferDoc::OnEditPause()
{
	// TODO: Add your command handler code here
	//p_DataThread->SuspendThread();  // pause thread /// TODO: THIS SHOULD NOT ACTUALLY PAUSE THREAD, BUT IT SHOULD PAUSE THE DATA CAPTURE IN THE THREAD!
	theApp.p_DataThread->PostThreadMessage(WM_PAUSE_CAPTURE,0,0);
}

void CPacketSnifferDoc::add_sniffer_event(CSnifferEvent *newEvent)  {
	m_SnifferEvents.Add(newEvent);
}

void CPacketSnifferDoc::draw_data(CDC *pDC)  {
	m_SnifferEvents.Draw(pDC);
}

INT_PTR CPacketSnifferDoc::get_data_size()  {
	return m_SnifferEvents.GetSize();
}