// PacketSnifferView.cpp : implementation of the CPacketSnifferView class
//

#include "stdafx.h"
#include "PacketSniffer.h"

#include "PacketSnifferDoc.h"
#include "PacketSnifferView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CPacketSnifferView

IMPLEMENT_DYNCREATE(CPacketSnifferView, CScrollView)

BEGIN_MESSAGE_MAP(CPacketSnifferView, CScrollView)
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CScrollView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CScrollView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CScrollView::OnFilePrintPreview)
END_MESSAGE_MAP()

// CPacketSnifferView construction/destruction

CPacketSnifferView::CPacketSnifferView()
{
	// TODO: add construction code here

}

CPacketSnifferView::~CPacketSnifferView()
{
}

BOOL CPacketSnifferView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return CScrollView::PreCreateWindow(cs);
}

// CPacketSnifferView drawing

void CPacketSnifferView::OnDraw(CDC* pDC)
{
	CPacketSnifferDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	if (!pDoc)
		return;
	INT_PTR num_elements = pDoc->get_data_size();
	CSize sizeTotal;
	sizeTotal.cy = num_elements*40;
	sizeTotal.cx = 400;
	SetScrollSizes(MM_TEXT, sizeTotal);
	// TODO: add draw code for native data here
	pDoc->draw_data(pDC);
}

void CPacketSnifferView::OnInitialUpdate()
{
	CScrollView::OnInitialUpdate();
	CSize sizeTotal;
	// TODO: calculate the total size of this view
	sizeTotal.cx = sizeTotal.cy = 100;
	SetScrollSizes(MM_TEXT, sizeTotal);
}


// CPacketSnifferView printing

BOOL CPacketSnifferView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}

void CPacketSnifferView::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add extra initialization before printing
}

void CPacketSnifferView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add cleanup after printing
}


// CPacketSnifferView diagnostics

#ifdef _DEBUG
void CPacketSnifferView::AssertValid() const
{
	CScrollView::AssertValid();
}

void CPacketSnifferView::Dump(CDumpContext& dc) const
{
	CScrollView::Dump(dc);
}

CPacketSnifferDoc* CPacketSnifferView::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CPacketSnifferDoc)));
	return (CPacketSnifferDoc*)m_pDocument;
}
#endif //_DEBUG


// CPacketSnifferView message handlers
