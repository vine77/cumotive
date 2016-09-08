#pragma once

#include "afxtempl.h"

class CMovingAverage
{
public:
	CMovingAverage(void);
	CMovingAverage(int len);
	~CMovingAverage(void);
	unsigned int get_average(void);
	void add_data(unsigned char datum);
private:
	CList<int,int> my_data;
	unsigned int avg_length;
};
