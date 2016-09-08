// PacketSnifferView.h : interface of the CPacketSnifferView class
//


#pragma once


class CPacketSnifferView : public CScrollView
{
protected: // create from serialization only
	CPacketSnifferView();
	DECLARE_DYNCREATE(CPacketSnifferView)

// Attributes
public:
	CPacketSnifferDoc* GetDocument() const;

// Operations
public:

// Overrides
	public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
protected:
	virtual void OnInitialUpdate(); // called first time after construct
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);

// Implementation
public:
	virtual ~CPacketSnifferView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
};

#ifndef _DEBUG  // debug version in PacketSnifferView.cpp
inline CPacketSnifferDoc* CPacketSnifferView::GetDocument() const
   { return reinterpret_cast<CPacketSnifferDoc*>(m_pDocument); }
#endif

