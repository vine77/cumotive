/* 
flext tutorial - threads 1

Copyright (c) 2002,2003 Thomas Grill (xovo@gmx.net)
For information on usage and redistribution, and for a DISCLAIMER OF ALL
WARRANTIES, see the file, "license.txt," in this distribution.  

-------------------------------------------------------------------------

This shows an example of a method running as a thread
*/

/* define FLEXT_THREADS for thread usage. Flext must also have been compiled with that defined!
	it's even better to define that as a compiler flag (-D FLEXT_THREADS) for all files of the
	flext external
*/
#ifndef FLEXT_THREADS
#define FLEXT_THREADS
#endif

#include <flext.h>
#include "SerialD2XX.h"

#if !defined(FLEXT_VERSION) || (FLEXT_VERSION < 400)
#error You need at least flext version 0.4.0
#endif


#define WAIT_FOR_PREAMBLE	1
#define READING_MESSAGE		2
#define GETTING_SIZE		3

class thread1:
	public flext_base
{
	FLEXT_HEADER(thread1,flext_base)
 
public:
	thread1(); 
	~thread1();

protected:
	void m_start(); // method function
	void m_stop();
	CSerialD2XX m_datasource;

private:	
	// define threaded callback for method m_start
	// the same syntax as with FLEXT_CALLBACK is used here
	FLEXT_THREAD(m_start)
	//FLEXT_CALLBACK(m_stop)
	FLEXT_THREAD(m_stop);

	volatile bool stoppit, running;
	DWORD n_rxQueue;
	DWORD n_txQueue;
	DWORD deviceStatus;
	DWORD n_bytesRead;

	// thread conditional for stopping
	ThrCond cond;
};

FLEXT_NEW("thread1",thread1)



thread1::~thread1()  {
	m_datasource.DisconnectFromDevice();
	m_datasource.FreeDll();
}

thread1::thread1()
{ 
	BOOL result;
	AddInAnything();
	//AddInAnything();
	AddOutList(); 

	stoppit = false;
	running = false;
	
	result = m_datasource.LoadDll();
	if (!result)
		post("Error loading D2XX dll");
	else
		post("Loaded D2XX dll");
	result = m_datasource.LoadDllFunctions();
	if (!result)
		post("Error loading D2XX dll functions");
	else
		post("Loaded D2XX dll functions");
	
	result = m_datasource.CheckForDevices();
	if (result)  {
		result = m_datasource.ConnectToDevice(0);  // connect to first device
		if (!result)  {
			post("Failed to connect to device.");
			Exit();
			//exit(1);
		}
		else  {
			post("Connected.");
		}
	}
	else  {
		post("No devices connected! Aborting...");
		//exit(1);
		Exit();
	}

	m_datasource.SetBaudRate(250000);
	m_datasource.SetDataCharacteristics(FT_BITS_8,FT_STOP_BITS_1,FT_PARITY_NONE);
	m_datasource.SetFlowControl(FT_FLOW_NONE,0,0);

	FLEXT_ADDMETHOD_(0,"start",m_start); // register method
	FLEXT_ADDMETHOD_(0,"stop",m_stop);
} 

void thread1::m_start()
{
	if (running) {  // already running!
		return;
	}

	running = true;
	
	n_rxQueue = 0;
	n_txQueue = 0;
	deviceStatus = 0;
	n_bytesRead = 0;

	DWORD i,j;
	DWORD PreambleCounter = 0;
	DWORD MessageCounter = 0;
	DWORD MessageSize = 0;
	AtomList m_list(15);
	t_atom item;
	
	unsigned char ReadState = WAIT_FOR_PREAMBLE;
	unsigned char rx_buffer[256];
	unsigned char msg_buffer[256];
		
	m_datasource.Purge(FT_PURGE_RX|FT_PURGE_TX);


	while ((!ShouldExit())&&!(stoppit))  {   // keep gathering data until we quit. 
		if (m_datasource.is_dll_loaded)
			m_datasource.GetStatus(&n_rxQueue,&n_txQueue,&deviceStatus);
		if (n_rxQueue > 0)  {  // data is available, so read it!
			if (m_datasource.is_dll_loaded)
				m_datasource.Read(rx_buffer,n_rxQueue,&n_bytesRead);
			for (i=0; i<n_bytesRead; i++)  {
				if (ReadState == WAIT_FOR_PREAMBLE)  {
					if (rx_buffer[i] == (unsigned char) 255)  {   // Preamble to message has 4 bytes of 0xff
						if (++PreambleCounter == 4) {
							ReadState = GETTING_SIZE;
							PreambleCounter = 0;
						}
					}
					else 
						PreambleCounter = 0;
				}
				else if (ReadState == GETTING_SIZE)  {
					MessageCounter = 0;
					MessageSize = rx_buffer[i];  // get the size of the message to come
					ReadState = READING_MESSAGE;
				}
				else if (ReadState == READING_MESSAGE)  {
					msg_buffer[MessageCounter++] = rx_buffer[i];  // Get current byte of message
					if (MessageCounter == MessageSize)  {  // this is the end of the message
						MessageCounter = 0;
						ReadState = WAIT_FOR_PREAMBLE;
						for (j=0;j<MessageSize;j++)  {    // print the full received message
							//post("%i",msg_buffer[j]);
							SetInt(item,(int)msg_buffer[j]);
							m_list.Append(item);
						}
						ToOutList(0,m_list);
						m_list.Clear();
					}
				}
			}
		}
		Sleep(10/1000);  // sleep for 10 ms
	}
	running = false;
	cond.Signal();
}

void thread1::m_stop()  {
	stoppit = true;

	if (running) {
		cond.Wait();
	}

	stoppit = false;  // reset flag
}



