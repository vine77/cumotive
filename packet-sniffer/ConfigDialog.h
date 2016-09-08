#pragma once


// CConfigDialog dialog
#include "SerialD2XX.h"
#include "afxwin.h"
#include "afxcmn.h"
#include "USBDataCapture.h"
#include "MovingAverage.h"

class CConfigDialog : public CDialog
{
	DECLARE_DYNAMIC(CConfigDialog)

public:
	CConfigDialog(CWnd* pParent = NULL);   // standard constructor
	virtual ~CConfigDialog();
	virtual BOOL OnInitDialog();

// Dialog Data
	enum { IDD = IDD_CONFIG_DLG };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()

private:  // member variables
	BOOL	data_is_valid;
	BOOL	dialog_is_open;
	CSerialD2XX		m_serialport;
	int		m_selected_device;
	CString m_selected_channel;

public:  // accessor functions
	BOOL	is_data_valid(void); 
	void	invalidate_settings(void);  // clear data_is_valid var
	int		get_selected_device(void);  // return index of which device was selected
	unsigned char	get_selected_channel(void); // return the int value of the selected channel
private:
	CComboBox m_cb_DeviceList;
public:
	afx_msg void OnBnClickedOk();
	virtual void OnCancel();
	BOOL is_dialog_open();
	afx_msg void OnCbnSelchangeCombo1();
	afx_msg void OnCbnSelchangeCombo2();
private:
	CComboBox SelDeviceChannel;
	CUSBDataCapture m_device;
public:
	CMovingAverage m_avgChannel11;
	CMovingAverage m_avgChannel12;
	CMovingAverage m_avgChannel13;
	CMovingAverage m_avgChannel14;
	CMovingAverage m_avgChannel15;
	CMovingAverage m_avgChannel16;
	CMovingAverage m_avgChannel17;
	CMovingAverage m_avgChannel18;
	CMovingAverage m_avgChannel19;
	CMovingAverage m_avgChannel20;
	CMovingAverage m_avgChannel21;
	CMovingAverage m_avgChannel22;
	CMovingAverage m_avgChannel23;
	CMovingAverage m_avgChannel24;
	CMovingAverage m_avgChannel25;
	CMovingAverage m_avgChannel26;

	CProgressCtrl m_pbChannel11;	
	CProgressCtrl m_pbChannel12;	
	CProgressCtrl m_pbChannel13;
	CProgressCtrl m_pbChannel14;
	CProgressCtrl m_pbChannel15;
	CProgressCtrl m_pbChannel16;
	CProgressCtrl m_pbChannel17;
	CProgressCtrl m_pbChannel18;
	CProgressCtrl m_pbChannel19;
	CProgressCtrl m_pbChannel20;
	CProgressCtrl m_pbChannel21;
	CProgressCtrl m_pbChannel22;
	CProgressCtrl m_pbChannel23;
	CProgressCtrl m_pbChannel24;
	CProgressCtrl m_pbChannel25;
	CProgressCtrl m_pbChannel26;
	


	void OnReceiveScanData(WPARAM,LPARAM);
};
