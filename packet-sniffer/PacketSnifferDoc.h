// PacketSnifferDoc.h : interface of the CPacketSnifferDoc class
//

/// TODO: better understand how data in document gets passed to view, how view updates

/// Document will instantiate thread which monitors USB. Thread class will incorporate D2XX functions. D2XX object created temporarily by dialog box
/// to get list of possible connections. 

#pragma once
#include "USBDataCapture.h"
#include "SnifferEventList.h"
#include "SnifferEvent.h"
#include "ConfigDialog.h"

class CPacketSnifferDoc : public CDocument
{
protected: // create from serialization only
	CPacketSnifferDoc();
	DECLARE_DYNCREATE(CPacketSnifferDoc)

// Attributes
public:

// Operations
public:

// Overrides
	public:
	virtual BOOL OnNewDocument();
	virtual void Serialize(CArchive& ar);

// Implementation
public:
	virtual ~CPacketSnifferDoc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnEditConfig();
	
	CConfigDialog configDlg;

private: // member vars, actual data
	int selected_device;  // just represents index of device to connect to. Don't save to file.
	
	
	SnifferEventList m_SnifferEvents;  // This is the real data that we're interested in

public:  //accessor functions
	void set_selected_device(int val);
	void clear_selected_device();
	void add_sniffer_event(CSnifferEvent *newEvent);
	void draw_data(CDC *pDC);
	
	INT_PTR get_data_size(void);

	afx_msg void OnEditRun();
	afx_msg void OnEditPause();
};


