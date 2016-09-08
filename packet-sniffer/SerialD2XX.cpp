#include "StdAfx.h"
#include ".\seriald2xx.h"

CSerialD2XX::CSerialD2XX(void)  //constructor
{
	is_connected = FALSE;
	m_ftHandle = NULL; 
	m_ftStats = NULL;
	if (!LoadDll())  {   // if dll fails to load, exit program
		exit(1);
	}
	if (!LoadDllFunctions())  {  // if dll functions fail to load, exit program
		FreeDll();
		exit(1);
	}
	devInfo = NULL;
}

CSerialD2XX::~CSerialD2XX(void)  //destructor
{
	FreeDll();    // make sure connection closed, dll freed 
	if (devInfo != NULL)  {
		free(devInfo);  // make sure there's no memory leak
	}
}


bool CSerialD2XX::LoadDll(void)  {
	m_hModule = LoadLibrary("ftd2xx.dll");
	if (m_hModule == NULL)  {
		AfxMessageBox("Couldn't load ftd2xx.dll!");
		return false;  // failure
	}
	return true;  // success
}

void CSerialD2XX::FreeDll(void)  {
	if (m_ftHandle != NULL) {
		m_ftStats = (m_pClose)(m_ftHandle);
	}
	if (m_hModule != NULL)  {
		FreeModule(m_hModule);
	}
}

bool CSerialD2XX::LoadDllFunctions(void)  {
	m_pListDevices = (PtrToListDevices)GetProcAddress(m_hModule,"FT_ListDevices");  // Load List Devices Function
	if (m_pListDevices != NULL)  {   // successfully loaded function
		m_ftStats = (m_pListDevices)(&m_nDevices,NULL,FT_LIST_NUMBER_ONLY);  // check for connected devices
		if (m_ftStats == FT_OK)  { 
			if (m_nDevices == 0)  {
				AfxMessageBox("No CUmotes connected. Please connect a device.");
				return false;
			}
		}
		else  {
			AfxMessageBox("Failed to list devices");
			return false;
		}
	}

	m_pClose = (PtrToClose)GetProcAddress(m_hModule,"FT_Close");  // load Close function
	if (m_pClose == NULL)  {
		AfxMessageBox("Failed to load FT_Close function. Check ftd2xx.dll");
		return false;
	}

	m_pOpen = (PtrToOpen)GetProcAddress(m_hModule,"FT_Open");  // load Open function
	if (m_pOpen == NULL)  {
		AfxMessageBox("Failed to load FT_Open function. Check ftd2xx.dll");
		return false;	
	}

	m_pOpenEx = (PtrToOpenEx)GetProcAddress(m_hModule,"FT_OpenEx");  // load OpenEx function
	if (m_pOpenEx == NULL)  {
		AfxMessageBox("Failed to load FT_OpenEx function. Check ftd2xx.dll");
		return false;
	}	
	
	m_pRead = (PtrToRead)GetProcAddress(m_hModule,"FT_Read");    // load Read function
	if (m_pRead == NULL)  {
		AfxMessageBox("Failed to load FT_Read function. Check ftd2xx.dll");
		return false;	
	}	

	m_pWrite = (PtrToWrite)GetProcAddress(m_hModule,"FT_Write");   // load Write function
	if (m_pWrite == NULL)  {
		AfxMessageBox("Failed to load FT_Write function. Check ftd2xx.dll");
		return false;
	}	

	m_pResetDevice = (PtrToResetDevice)GetProcAddress(m_hModule,"FT_ResetDevice");   // load ResetDevice function
	if (m_pResetDevice == NULL)  {
		AfxMessageBox("Failed to load FT_ResetDevice function. Check ftd2xx.dll");
		return false;	
	}	

	m_pSetBaudRate = (PtrToSetBaudRate)GetProcAddress(m_hModule,"FT_SetBaudRate");  // load SetBaudRate function
	if (m_pSetBaudRate == NULL)  {
		AfxMessageBox("Failed to load FT_SetBaudRate function. Check ftd2xx.dll");
		return false;	
	}

	m_pSetDivisor = (PtrToSetDivisor)GetProcAddress(m_hModule,"FT_SetDivisor");   // load SetDivisor Function
	if (m_pSetDivisor == NULL)  {
		AfxMessageBox("Failed to load FT_SetDivisor function. Check ftd2xx.dll");
		return false;	
	}

	m_pSetDataCharacteristics = (PtrToSetDataCharacteristics)GetProcAddress(m_hModule,"FT_SetDataCharacteristics");  // load SetDataCharacteristics function
	if (m_pSetDataCharacteristics == NULL)  {
		AfxMessageBox("Failed to load FT_SetDataCharacteristics function. Check ftd2xx.dll");
		return false;
	}

	m_pSetFlowControl = (PtrToSetFlowControl)GetProcAddress(m_hModule,"FT_SetFlowControl");  // load SetFlowControl function
	if (m_pSetFlowControl == NULL)  {
		AfxMessageBox("Failed to load FT_SetFlowControl function. Check ftd2xx.dll");
		return false;
	}

	m_pSetDtr = (PtrToSetDtr)GetProcAddress(m_hModule,"FT_SetDtr");  // load SetFlowControl function
	if (m_pSetDtr == NULL)  {
		AfxMessageBox("Failed to load FT_SetDtr function. Check ftd2xx.dll");
		return false;
	}

	m_pClrDtr = (PtrToClrDtr)GetProcAddress(m_hModule,"FT_ClrDtr");  // load SetFlowControl function
	if (m_pClrDtr == NULL)  {
		AfxMessageBox("Failed to load FT_ClrDtr function. Check ftd2xx.dll");
		return false;
	}

	m_pSetRts = (PtrToSetRts)GetProcAddress(m_hModule,"FT_SetRts");  // load SetFlowControl function
	if (m_pSetRts == NULL)  {
		AfxMessageBox("Failed to load FT_SetRts function. Check ftd2xx.dll");
		return false;
	}

	m_pClrRts = (PtrToClrRts)GetProcAddress(m_hModule,"FT_ClrRts");  // load SetFlowControl function
	if (m_pClrRts == NULL)  {
		AfxMessageBox("Failed to load FT_ClrRts function. Check ftd2xx.dll");
		return false;
	}

	m_pGetModemStatus = (PtrToGetModemStatus)GetProcAddress(m_hModule,"FT_GetModemStatus");  // load SetFlowControl function
	if (m_pGetModemStatus == NULL)  {
		AfxMessageBox("Failed to load FT_GetModemStatus function. Check ftd2xx.dll");
		return false;
	}

	m_pSetChars = (PtrToSetChars)GetProcAddress(m_hModule,"FT_SetChars");  // load SetFlowControl function
	if (m_pSetChars == NULL)  {
		AfxMessageBox("Failed to load FT_SetChars function. Check ftd2xx.dll");
		return false;
	}

	m_pPurge = (PtrToPurge)GetProcAddress(m_hModule,"FT_Purge");  // load SetFlowControl function
	if (m_pPurge == NULL)  {
		AfxMessageBox("Failed to load FT_Purge function. Check ftd2xx.dll");
		return false;
	}

	m_pSetTimeouts = (PtrToSetTimeouts)GetProcAddress(m_hModule,"FT_SetTimeouts");  // load SetFlowControl function
	if (m_pSetTimeouts == NULL)  {
		AfxMessageBox("Failed to load FT_SetTimeouts function. Check ftd2xx.dll");
		return false;
	}

	m_pGetQueueStatus = (PtrToGetQueueStatus)GetProcAddress(m_hModule,"FT_GetQueueStatus");  // load SetFlowControl function
	if (m_pGetQueueStatus == NULL)  {
		AfxMessageBox("Failed to load FT_GetQueueStatus function. Check ftd2xx.dll");
		return false;
	}

	m_pSetBreakOn = (PtrToSetBreakOn)GetProcAddress(m_hModule,"FT_SetBreakOn");  // load SetFlowControl function
	if (m_pSetBreakOn == NULL)  {
		AfxMessageBox("Failed to load FT_SetBreakOn function. Check ftd2xx.dll");
		return false;
	}

	m_pSetBreakOff = (PtrToSetBreakOff)GetProcAddress(m_hModule,"FT_SetBreakOff");  // load SetFlowControl function
	if (m_pSetBreakOff == NULL)  {
		AfxMessageBox("Failed to load FT_SetBreakOff function. Check ftd2xx.dll");
		return false;
	}

	m_pGetStatus = (PtrToGetStatus)GetProcAddress(m_hModule,"FT_GetStatus");  // load SetFlowControl function
	if (m_pGetStatus == NULL)  {
		AfxMessageBox("Failed to load FT_GetStatus function. Check ftd2xx.dll");
		return false;
	}

	m_pSetEventNotification = (PtrToSetEventNotification)GetProcAddress(m_hModule,"FT_SetEventNotification");  // load SetFlowControl function
	if (m_pSetEventNotification == NULL)  {
		AfxMessageBox("Failed to load FT_SetEventNotification function. Check ftd2xx.dll");
		return false;
	}

	m_pIoCtl = (PtrToIoCtl)GetProcAddress(m_hModule,"FT_IoCtl");  // load SetFlowControl function
	if (m_pIoCtl == NULL)  {
		AfxMessageBox("Failed to load FT_IoCtl function. Check ftd2xx.dll");
		return false;
	}

	m_pSetWaitMask = (PtrToSetWaitMask)GetProcAddress(m_hModule,"FT_SetWaitMask");  // load SetFlowControl function
	if (m_pSetWaitMask == NULL)  {
		AfxMessageBox("Failed to load FT_SetWaitMask function. Check ftd2xx.dll");
		return false;
	}

	m_pWaitOnMask = (PtrToWaitOnMask)GetProcAddress(m_hModule,"FT_WaitOnMask");  // load SetFlowControl function
	if (m_pWaitOnMask == NULL)  {
		AfxMessageBox("Failed to load FT_WaitOnMask function. Check ftd2xx.dll");
		return false;
	}

	m_pGetDeviceInfo = (PtrToGetDeviceInfo)GetProcAddress(m_hModule,"FT_GetDeviceInfo");  // load SetFlowControl function
	if (m_pGetDeviceInfo == NULL)  {
		AfxMessageBox("Failed to load FT_GetDeviceInfo function. Check ftd2xx.dll");
		return false;
	}

	m_pSetResetPipeRetryCount = (PtrToSetResetPipeRetryCount)GetProcAddress(m_hModule,"FT_SetResetPipeRetryCount");  // load SetFlowControl function
	if (m_pSetResetPipeRetryCount == NULL)  {
		AfxMessageBox("Failed to load FT_SetResetPipeRetryCount function. Check ftd2xx.dll");
		return false;
	}
	
	m_pStopInTask = (PtrToStopInTask)GetProcAddress(m_hModule,"FT_StopInTask");  // load SetFlowControl function
	if (m_pStopInTask == NULL)  {
		AfxMessageBox("Failed to load FT_StopInTask function. Check ftd2xx.dll");
		return false;
	}
	
	m_pRestartInTask = (PtrToRestartInTask)GetProcAddress(m_hModule,"FT_RestartInTask");  // load SetFlowControl function
	if (m_pRestartInTask == NULL)  {
		AfxMessageBox("Failed to load FT_RestartInTask function. Check ftd2xx.dll");
		return false;
	}

	m_pResetPort = (PtrToResetPort)GetProcAddress(m_hModule,"FT_ResetPort");  // load SetFlowControl function
	if (m_pResetPort == NULL)  {
		AfxMessageBox("Failed to load FT_ResetPort function. Check ftd2xx.dll");
		return false;
	}

	m_pCyclePort = (PtrToCyclePort)GetProcAddress(m_hModule,"FT_CyclePort");  // load SetFlowControl function
	if (m_pCyclePort == NULL)  {
		AfxMessageBox("Failed to load FT_CyclePort function. Check ftd2xx.dll");
		return false;
	}

	m_pCreateDeviceInfoList = (PtrToCreateDeviceInfoList)GetProcAddress(m_hModule,"FT_CreateDeviceInfoList");  // load SetFlowControl function
	if (m_pCreateDeviceInfoList == NULL)  {
		AfxMessageBox("Failed to load FT_CreateDeviceInfoList function. Check ftd2xx.dll");
		return false;
	}

	m_pGetDeviceInfoList = (PtrToGetDeviceInfoList)GetProcAddress(m_hModule,"FT_GetDeviceInfoList");  // load SetFlowControl function
	if (m_pGetDeviceInfoList == NULL)  {
		AfxMessageBox("Failed to load FT_GetDeviceInfoList function. Check ftd2xx.dll");
		return false;
	}

	m_pGetDeviceInfoDetail = (PtrToGetDeviceInfoDetail)GetProcAddress(m_hModule,"FT_GetDeviceInfoDetail");  // load SetFlowControl function
	if (m_pGetDeviceInfoDetail == NULL)  {
		AfxMessageBox("Failed to load FT_GetDeviceInfoDetail function. Check ftd2xx.dll");
		return false;
	}

	m_pGetDriverVersion = (PtrToGetDriverVersion)GetProcAddress(m_hModule,"FT_GetDriverVersion");  // load SetFlowControl function
	if (m_pGetDriverVersion == NULL)  {
		AfxMessageBox("Failed to load FT_GetDriverVersion function. Check ftd2xx.dll");
		return false;
	}


	m_pGetLibraryVersion = (PtrToGetLibraryVersion)GetProcAddress(m_hModule,"FT_GetLibraryVersion");  // load SetFlowControl function
	if (m_pGetLibraryVersion == NULL)  {
		AfxMessageBox("Failed to load FT_GetLibraryVersion function. Check ftd2xx.dll");
		return false;
	}

	m_pSetDeadmanTimeout = (PtrToSetDeadmanTimeout)GetProcAddress(m_hModule,"FT_SetDeadmanTimeout");  // load SetFlowControl function
	if (m_pSetDeadmanTimeout == NULL)  {
		AfxMessageBox("Failed to load FT_SetDeadmanTimeout function. Check ftd2xx.dll");
		return false;
	}

	m_pRescan = (PtrToRescan)GetProcAddress(m_hModule,"FT_Rescan");  // load SetFlowControl function
	if (m_pRescan == NULL)  {
		AfxMessageBox("Failed to load FT_Rescan function. Check ftd2xx.dll");
		return false;
	}

	
	m_pReload = (PtrToReload)GetProcAddress(m_hModule,"FT_Reload");  // load SetFlowControl function
	if (m_pReload == NULL)  {
		AfxMessageBox("Failed to load FT_Reload function. Check ftd2xx.dll");
		return false;
	}
	return true;
}

bool CSerialD2XX::CheckForDevices()  {
	m_ftStats = (m_pListDevices)(&m_nDevices,NULL,FT_LIST_NUMBER_ONLY);  // check for connected devices
	if (m_ftStats == FT_OK)  { 
		if (m_nDevices == 0)  {
			AfxMessageBox("Please re-connect the CUmote before configuring the connection.");
			return false;
		}
	}
	else  {
		AfxMessageBox("Failed to list devices.");
		return false;
	}
	return true;
}

void CSerialD2XX::GetNumDevices(DWORD *numDevices)  {
	m_ftStats = (m_pListDevices)(&m_nDevices,NULL,FT_LIST_NUMBER_ONLY);  // check for connected devices
	if (m_ftStats == FT_OK)  { 
		*numDevices = m_nDevices;
	}
	else  {
		*numDevices = 0;
	}
}

void CSerialD2XX::ListDevices(void)  {   // builds internal list of devices
	if (devInfo != NULL) {
		free(devInfo);
	}
	m_ftStats = (m_pCreateDeviceInfoList)(&m_nDevices);
	devInfo = (FT_DEVICE_LIST_INFO_NODE*)malloc(sizeof(FT_DEVICE_LIST_INFO_NODE)*m_nDevices);  // allocate memory for device list
	m_ftStats = (m_pGetDeviceInfoList)(devInfo,&m_nDevices);

	//TODO: Error Checking

//	DWORD i = 0;
//	for (i; i < m_nDevices; i++)  {
		//(*devList)[i] = (CString)((devInfo[i]).Description);
//	}
}

void CSerialD2XX::GetDeviceName(DWORD whichDevice, CString *devName)  {  // 0 for first device, 1 for second, etc.
	// must call ListDevices first to build internal list of devices
	(*devName).Format("%s:%d",(CString)(devInfo[whichDevice].Description),devInfo[whichDevice].LocId);
}

BOOL CSerialD2XX::ConnectToDevice(int dev_index)  {
	m_ftStats = (m_pOpen)(dev_index,&m_ftHandle);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Could not connect to selected device");
		return FALSE;
	}
	is_connected = TRUE;
	return TRUE;
}

void CSerialD2XX::DisconnectFromDevice()  {
	m_ftStats = (m_pClose)(&m_ftHandle);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Could not close connection to device");
	}
	else
		is_connected = FALSE;
}

void CSerialD2XX::SetBaudRate(DWORD newBaud)  {
	m_nBaudRate = newBaud;
	m_ftStats = (m_pSetBaudRate)(m_ftHandle,newBaud);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Failed to set the baud rate");
	}
}

void CSerialD2XX::SetDataCharacteristics(UCHAR uWordLength, UCHAR uStopBits, UCHAR uParity)  {
	m_ftStats = (m_pSetDataCharacteristics)(m_ftHandle,uWordLength,uStopBits,uParity);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Failed to set the data characteristics.");
	}
}

void CSerialD2XX::SetFlowControl(USHORT usFlowControl, UCHAR uXon, UCHAR uXoff)  {
	m_ftStats = (m_pSetFlowControl)(m_ftHandle,usFlowControl,uXon,uXoff);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Failed to set the flow control");
	}
}

void CSerialD2XX::Purge(DWORD dwMask)  {
	m_ftStats = (m_pPurge)(m_ftHandle,dwMask);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Failed to purge requested buffers");
	}
}

void CSerialD2XX::SetEventNotification(DWORD dwEventMask,PVOID pvArg)  {
	m_ftStats = (m_pSetEventNotification)(m_ftHandle,dwEventMask,pvArg);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Failed to create event");
	}
}

void CSerialD2XX::GetStatus(LPDWORD lpdwAmountInRxQueue,LPDWORD lpdwAmountInTxQueue,LPDWORD lpdwEventStatus)  {
	m_ftStats = (m_pGetStatus)(m_ftHandle,lpdwAmountInRxQueue,lpdwAmountInTxQueue,lpdwEventStatus);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Failed to get device status. Check to make sure device is still connected.");
	}
}

void CSerialD2XX::Read(LPVOID lpBuffer, DWORD dwBytesToRead, LPDWORD lpdwBytesReturned)  {
	m_ftStats = (m_pRead)(m_ftHandle,lpBuffer,dwBytesToRead,lpdwBytesReturned);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Failed to read the device.");
	}
	if (dwBytesToRead != *lpdwBytesReturned) {
		AfxMessageBox("Failed to read specified number of bytes.");
	}
}

void CSerialD2XX::Write(LPVOID lpBuffer, DWORD dwBytesToWrite, LPDWORD lpdwBytesWritten)  {
	m_ftStats = (m_pWrite)(m_ftHandle,lpBuffer,dwBytesToWrite,lpdwBytesWritten);
	if (m_ftStats != FT_OK)  {
		AfxMessageBox("Failed to write to the device.");
	}
	if (dwBytesToWrite != *lpdwBytesWritten)  {
		AfxMessageBox("Failed to write the entire message.");
	}
}