// PacketSniffer.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "SnifferEvent.h"
#include "PacketSniffer.h"
#include "MainFrm.h"

#include "PacketSnifferDoc.h"
#include "PacketSnifferView.h"
#include ".\packetsniffer.h"
#include "ConfigDialog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CPacketSnifferApp

BEGIN_MESSAGE_MAP(CPacketSnifferApp, CWinApp)
	ON_COMMAND(ID_APP_ABOUT, OnAppAbout)
	// Standard file based document commands
	ON_COMMAND(ID_FILE_NEW, CWinApp::OnFileNew)
	ON_COMMAND(ID_FILE_OPEN, CWinApp::OnFileOpen)
	// Standard print setup command
	ON_COMMAND(ID_FILE_PRINT_SETUP, CWinApp::OnFilePrintSetup)
	ON_THREAD_MESSAGE(WM_SEND_DATA, OnReceiveData)
	ON_THREAD_MESSAGE(WM_SEND_RSSI_DATA, OnReceiveRSSIData)
END_MESSAGE_MAP()


// CPacketSnifferApp construction

CPacketSnifferApp::CPacketSnifferApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}


// The one and only CPacketSnifferApp object

CPacketSnifferApp theApp;

// CPacketSnifferApp initialization

BOOL CPacketSnifferApp::InitInstance()
{
	// InitCommonControls() is required on Windows XP if an application
	// manifest specifies use of ComCtl32.dll version 6 or later to enable
	// visual styles.  Otherwise, any window creation will fail.
	InitCommonControls();

	CWinApp::InitInstance();

	// Initializing secondary thread object
	p_DataThread = new CUSBDataCapture;         /// TODO: Where to delete this object??

	// Initialize OLE libraries
	if (!AfxOleInit())
	{
		AfxMessageBox(IDP_OLE_INIT_FAILED);
		return FALSE;
	}
	AfxEnableControlContainer();
	// Standard initialization
	// If you are not using these features and wish to reduce the size
	// of your final executable, you should remove from the following
	// the specific initialization routines you do not need
	// Change the registry key under which our settings are stored
	// TODO: You should modify this string to be something appropriate
	// such as the name of your company or organization
	SetRegistryKey(_T("Local AppWizard-Generated Applications"));
	LoadStdProfileSettings(4);  // Load standard INI file options (including MRU)
	// Register the application's document templates.  Document templates
	//  serve as the connection between documents, frame windows and views
	CSingleDocTemplate* pDocTemplate;
	pDocTemplate = new CSingleDocTemplate(
		IDR_MAINFRAME,
		RUNTIME_CLASS(CPacketSnifferDoc),
		RUNTIME_CLASS(CMainFrame),       // main SDI frame window
		RUNTIME_CLASS(CPacketSnifferView));
	if (!pDocTemplate)
		return FALSE;
	AddDocTemplate(pDocTemplate);
	// Enable DDE Execute open
	EnableShellOpen();
	RegisterShellFileTypes(TRUE);
	// Parse command line for standard shell commands, DDE, file open
	CCommandLineInfo cmdInfo;
	ParseCommandLine(cmdInfo);
	// Dispatch commands specified on the command line.  Will return FALSE if
	// app was launched with /RegServer, /Register, /Unregserver or /Unregister.
	if (!ProcessShellCommand(cmdInfo))
		return FALSE;
	// The one and only window has been initialized, so show and update it
	m_pMainWnd->ShowWindow(SW_SHOW);
	m_pMainWnd->UpdateWindow();
	// call DragAcceptFiles only if there's a suffix
	//  In an SDI app, this should occur after ProcessShellCommand
	// Enable drag/drop open
	m_pMainWnd->DragAcceptFiles();
	return TRUE;
}

void CPacketSnifferApp::OnReceiveData(WPARAM wParam, LPARAM lParam)  {  
	// current channel is in wParam, data is in lParam
	CSnifferEvent *newEvent = (CSnifferEvent *)lParam;
	newEvent->set_channel((DWORD)wParam);
	// Get some access to the open document, and then add data to that document.
	POSITION pos = GetFirstDocTemplatePosition();
	CDocTemplate *temp = GetNextDocTemplate(pos);
	POSITION fpos = temp->GetFirstDocPosition();
	CPacketSnifferDoc *doc = (CPacketSnifferDoc *)temp->GetNextDoc(fpos);
	doc->add_sniffer_event(newEvent);
	doc->UpdateAllViews(NULL);
}

void CPacketSnifferApp::OnReceiveRSSIData(WPARAM wParam, LPARAM lParam)  {   
	// wParam unused. Data stored in lParam as a simple array of bytes.
	unsigned char *rssi_data;  // one byte for each channel, 14 channels.
	rssi_data = (unsigned char *)lParam;
	POSITION pos = GetFirstDocTemplatePosition();   /// get access to the document object
	CDocTemplate *temp = GetNextDocTemplate(pos);
	POSITION fpos = temp->GetFirstDocPosition();
	CPacketSnifferDoc *doc = (CPacketSnifferDoc *)temp->GetNextDoc(fpos);
	if ((doc->configDlg.is_dialog_open()))  { 
		doc->configDlg.m_avgChannel11.add_data(rssi_data[0]);
		doc->configDlg.m_pbChannel11.SetPos(doc->configDlg.m_avgChannel11.get_average());
		doc->configDlg.m_avgChannel12.add_data(rssi_data[1]);
		doc->configDlg.m_pbChannel12.SetPos(doc->configDlg.m_avgChannel12.get_average());
		doc->configDlg.m_avgChannel13.add_data(rssi_data[2]);
		doc->configDlg.m_pbChannel13.SetPos(doc->configDlg.m_avgChannel13.get_average());
		doc->configDlg.m_avgChannel14.add_data(rssi_data[3]);
		doc->configDlg.m_pbChannel14.SetPos(doc->configDlg.m_avgChannel14.get_average());
		doc->configDlg.m_avgChannel15.add_data(rssi_data[4]);
		doc->configDlg.m_pbChannel15.SetPos(doc->configDlg.m_avgChannel15.get_average());
		doc->configDlg.m_avgChannel16.add_data(rssi_data[5]);
		doc->configDlg.m_pbChannel16.SetPos(doc->configDlg.m_avgChannel16.get_average());
		doc->configDlg.m_avgChannel17.add_data(rssi_data[6]);
		doc->configDlg.m_pbChannel17.SetPos(doc->configDlg.m_avgChannel17.get_average());
		doc->configDlg.m_avgChannel18.add_data(rssi_data[7]);
		doc->configDlg.m_pbChannel18.SetPos(doc->configDlg.m_avgChannel18.get_average());
		doc->configDlg.m_avgChannel19.add_data(rssi_data[8]);
		doc->configDlg.m_pbChannel19.SetPos(doc->configDlg.m_avgChannel19.get_average());
		doc->configDlg.m_avgChannel20.add_data(rssi_data[9]);
		doc->configDlg.m_pbChannel20.SetPos(doc->configDlg.m_avgChannel20.get_average());
		doc->configDlg.m_avgChannel21.add_data(rssi_data[10]);
		doc->configDlg.m_pbChannel21.SetPos(doc->configDlg.m_avgChannel21.get_average());
		doc->configDlg.m_avgChannel22.add_data(rssi_data[11]);
		doc->configDlg.m_pbChannel22.SetPos(doc->configDlg.m_avgChannel22.get_average());
		doc->configDlg.m_avgChannel23.add_data(rssi_data[12]);
		doc->configDlg.m_pbChannel23.SetPos(doc->configDlg.m_avgChannel23.get_average());
		doc->configDlg.m_avgChannel24.add_data(rssi_data[13]);
		doc->configDlg.m_pbChannel24.SetPos(doc->configDlg.m_avgChannel24.get_average());
		doc->configDlg.m_avgChannel25.add_data(rssi_data[14]);
		doc->configDlg.m_pbChannel25.SetPos(doc->configDlg.m_avgChannel25.get_average());
		doc->configDlg.m_avgChannel26.add_data(rssi_data[15]);
		doc->configDlg.m_pbChannel26.SetPos(doc->configDlg.m_avgChannel26.get_average());
	}
}

int CPacketSnifferApp::ExitInstance()  {
	if (p_DataThread != NULL) {
		p_DataThread->SuspendThread();
		delete p_DataThread;
	}
	return CWinApp::ExitInstance();
}

// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()

// App command to run the dialog
void CPacketSnifferApp::OnAppAbout()
{
	CAboutDlg aboutDlg;
	aboutDlg.DoModal();
}


// CPacketSnifferApp message handlers



