#include "StdAfx.h"
#include ".\sniffereventlist.h"

IMPLEMENT_SERIAL(SnifferEventList,CObArray,1);

SnifferEventList::SnifferEventList(void)
{
	CObArray::CObArray();
	CSnifferEvent *newEvent = new CSnifferEvent();
	this->Add(newEvent);
	delete newEvent;
}

SnifferEventList::~SnifferEventList(void)
{
	if (!IsEmpty())  {
		RemoveAll();
	}
	CObArray::~CObArray();
}

void SnifferEventList::Draw(CDC *pDC)  {
	INT_PTR i;
	INT_PTR size = GetSize();
	bool is_gray = true;

	for (i = 0; i < size; i++)  {
		CSnifferEvent*& curr_event = (CSnifferEvent*&)ElementAt(i);
		(*curr_event).Draw(pDC,i,is_gray);
		is_gray = !is_gray;
	}
}


void SnifferEventList::Serialize(CArchive& ar)  {
	CObject::Serialize(ar);
	INT_PTR size,i;

	if (ar.IsStoring())  {
		size = GetSize();		
		ar << size;  // store the number of elements
		for (i = 0; i < size; i++)  {
			CSnifferEvent*& curr_event = (CSnifferEvent*&)ElementAt(i);
			(*curr_event).Serialize(ar);
		}
	}
	else  {
		ar >> size;  // load number of elements
		if (GetSize() != 0)  {
			RemoveAll();
		}
		for (i = 0; i < size; i++)  {
			CSnifferEvent *curr_event = new CSnifferEvent();
			(*curr_event).Serialize(ar);
			Add(curr_event);
		}
	}
}
