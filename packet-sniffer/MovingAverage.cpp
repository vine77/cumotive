#include "StdAfx.h"
#include ".\movingaverage.h"

CMovingAverage::CMovingAverage(void)
{
	avg_length = 20;
}

CMovingAverage::CMovingAverage(int len)  {
	avg_length = len;
}

CMovingAverage::~CMovingAverage(void)
{
	if (!(my_data.IsEmpty()))  {
		my_data.RemoveAll();
	}
}

unsigned int CMovingAverage::get_average()  {
	if (my_data.IsEmpty())
		return 0;
	int i;
	unsigned char average = 0;
	POSITION pos = my_data.GetHeadPosition();
	for (i=0;i<my_data.GetCount();i++)  {  // step through the list
		if (i == 0) {
			average = (unsigned char)(my_data.GetNext(pos));
		}
		else  {
			average = (unsigned char)((unsigned int)average + (unsigned int)(my_data.GetNext(pos)))/2;
		}
	}
	return average;
}

void CMovingAverage::add_data(unsigned char datum)  {
	if (my_data.GetCount() == avg_length)  {  // too many elements. Remove one first.
		my_data.RemoveHead();
	}
	my_data.AddTail(datum);
}

