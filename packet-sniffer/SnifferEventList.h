#pragma once
#include "afxcoll.h"

#include "SnifferEvent.h"

class SnifferEventList :
	public CObArray
{
	DECLARE_SERIAL(SnifferEventList);

public:
	SnifferEventList(void);
	~SnifferEventList(void);
	void Serialize(CArchive &ar);

	void Draw(CDC* pDC);
};
