// ConfigDialog.cpp : implementation file
//

#include "stdafx.h"
#include "SerialD2XX.h"
#include "PacketSniffer.h"
#include "ConfigDialog.h"
#include ".\configdialog.h"
#include "USBDataCapture.h"


// CConfigDialog dialog

IMPLEMENT_DYNAMIC(CConfigDialog, CDialog)
CConfigDialog::CConfigDialog(CWnd* pParent /*=NULL*/)
	: CDialog(CConfigDialog::IDD, pParent)
{
	data_is_valid = FALSE;
	m_selected_device = -1;
}

CConfigDialog::~CConfigDialog()
{
//	delete m_device;
}

BOOL CConfigDialog::OnInitDialog()  {
	/// TODO: enumerate connected devices
	BOOL to_return = CDialog::OnInitDialog();
	dialog_is_open = TRUE;
	DWORD numDevices;
	DWORD i;
	m_serialport.ListDevices();
	m_serialport.GetNumDevices(&numDevices);
	CString devName;
	for (i=0; i < numDevices; i++)  {
		m_serialport.GetDeviceName(i,&devName);
		m_cb_DeviceList.AddString(devName);
	}
	SelDeviceChannel.EnableWindow(false);
	m_pbChannel11.SetRange(0,84);
	m_pbChannel12.SetRange(0,84);
	m_pbChannel13.SetRange(0,84);  // range of 0 to 84 for Energy Detection measurement
	m_pbChannel14.SetRange(0,84);
	m_pbChannel15.SetRange(0,84);
	m_pbChannel16.SetRange(0,84);
	m_pbChannel17.SetRange(0,84);
	m_pbChannel18.SetRange(0,84);
	m_pbChannel19.SetRange(0,84);
	m_pbChannel20.SetRange(0,84);
	m_pbChannel21.SetRange(0,84);
	m_pbChannel22.SetRange(0,84);
	m_pbChannel23.SetRange(0,84);
	m_pbChannel24.SetRange(0,84);
	m_pbChannel25.SetRange(0,84);
	m_pbChannel26.SetRange(0,84);
	return to_return;
}

void CConfigDialog::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_COMBO1, m_cb_DeviceList);
	DDX_CBIndex(pDX, IDC_COMBO1, m_selected_device);
	DDX_Control(pDX, IDC_COMBO2, SelDeviceChannel);
	DDX_CBString(pDX, IDC_COMBO2, m_selected_channel);
	DDX_Control(pDX, IDC_CHAN11, m_pbChannel11);
	DDX_Control(pDX, IDC_CHAN12, m_pbChannel12);
	DDX_Control(pDX, IDC_CHAN13, m_pbChannel13);
	DDX_Control(pDX, IDC_CHAN14, m_pbChannel14);
	DDX_Control(pDX, IDC_CHAN15, m_pbChannel15);
	DDX_Control(pDX, IDC_CHAN16, m_pbChannel16);
	DDX_Control(pDX, IDC_CHAN17, m_pbChannel17);
	DDX_Control(pDX, IDC_CHAN18, m_pbChannel18);
	DDX_Control(pDX, IDC_CHAN19, m_pbChannel19);
	DDX_Control(pDX, IDC_CHAN20, m_pbChannel20);
	DDX_Control(pDX, IDC_CHAN21, m_pbChannel21);
	DDX_Control(pDX, IDC_CHAN22, m_pbChannel22);
	DDX_Control(pDX, IDC_CHAN23, m_pbChannel23);
	DDX_Control(pDX, IDC_CHAN24, m_pbChannel24);
	DDX_Control(pDX, IDC_CHAN25, m_pbChannel25);
	DDX_Control(pDX, IDC_CHAN26, m_pbChannel26);
}


BOOL CConfigDialog::is_data_valid(void)  {
	return data_is_valid;
}

void CConfigDialog::invalidate_settings(void)  {
	data_is_valid = FALSE;
}

int CConfigDialog::get_selected_device(void)  {
	return m_selected_device;
}

unsigned char CConfigDialog::get_selected_channel(void)  {
	return (unsigned char) atoi(m_selected_channel);
}

BEGIN_MESSAGE_MAP(CConfigDialog, CDialog)
	ON_BN_CLICKED(IDOK, OnBnClickedOk)
	ON_CBN_SELCHANGE(IDC_COMBO1, OnCbnSelchangeCombo1)
	ON_CBN_SELCHANGE(IDC_COMBO2, OnCbnSelchangeCombo2)
END_MESSAGE_MAP()


// CConfigDialog message handlers

void CConfigDialog::OnCancel()  {
	dialog_is_open = FALSE;
	CDialog::OnCancel();
}

BOOL CConfigDialog::is_dialog_open()  {
	return dialog_is_open;
}

void CConfigDialog::OnBnClickedOk()
{
	dialog_is_open = FALSE;
	UpdateData();
	if (m_selected_device < 0)  {
		CString err_msg;
		err_msg.Format("Selected Device Index: %d",m_selected_device);
		AfxMessageBox(err_msg);
		data_is_valid = FALSE;
	}
	else if (m_selected_channel == "")  {
		CString err_msg;
		err_msg.Format("Please select a channel to use");
		AfxMessageBox(err_msg);
		data_is_valid = FALSE;
	}
	else {
		data_is_valid = TRUE;
		CDialog::OnOK();
	}
}

void CConfigDialog::OnCbnSelchangeCombo1()
{
	UpdateData();
	SelDeviceChannel.EnableWindow();     /// TODO: learn how to use progress bars
	theApp.p_DataThread->PostThreadMessage(WM_ASSOCIATE_THREAD,m_selected_device,0);    /// TODO: Fix the message handler so it will disregard if already connected.
	theApp.p_DataThread->ResumeThread();
	theApp.p_DataThread->PostThreadMessage(WM_START_SCAN,0,0);  // tell thread to get the CUmote to start the RSSI scanning
}

void CConfigDialog::OnCbnSelchangeCombo2()
{
	// TODO: Add your control notification handler code here
//CString tester = "11";
//atoi(tester);
}

void CConfigDialog::OnReceiveScanData(WPARAM wParam, LPARAM lParam)  {   // Should be called when the main thread gets a message from the side-thread when dialog is open
	
}