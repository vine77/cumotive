/*
SerialD2XX.h: Wrapper class for FTDI's D2XX driver. Class loads DLL and associated functions, stores data representing single serial link
*/

#pragma once

#include "windows.h"
#include "ftd2xx.h"

class CSerialD2XX
{
public:
	CSerialD2XX(void);
	~CSerialD2XX(void);
	bool LoadDll(void);
	void FreeDll(void);
	bool LoadDllFunctions(void);
	bool CheckForDevices(void);
	void GetNumDevices(DWORD *);
	void ListDevices(void);  // return an array of CStrings and length of array
	//void GetDeviceName(DWORD, CString *);
	BOOL ConnectToDevice(int);
	void DisconnectFromDevice(void);
	void SetBaudRate(DWORD newBaud);  /// baud rate in bps
	void SetDataCharacteristics(UCHAR uWordLength, UCHAR uStopBits, UCHAR uParity);
	void SetFlowControl(USHORT usFlowControl, UCHAR uXon, UCHAR uXoff);
	void Purge(DWORD dwMask);
	void SetEventNotification(DWORD dwEventMask, PVOID pvArg);
	void GetStatus(LPDWORD lpdwAmountInRxQueue, LPDWORD lpdwAmountInTxQueue,LPDWORD lpdwEventStatus);
	void Read(LPVOID lpBuffer, DWORD dwBytesToRead, LPDWORD lpdwBytesReturned);
	void Write(LPVOID lpBuffer, DWORD dwBytesToWrite, LPDWORD lpdwBytesWritten);

	BOOL is_dll_loaded;

	HMODULE m_hModule;  // module to load dll in
	FT_HANDLE m_ftHandle;
	FT_STATUS m_ftStats;
	
	typedef FT_STATUS (WINAPI *PtrToListDevices)(PVOID, PVOID, DWORD);
	PtrToListDevices m_pListDevices;
	DWORD m_nDevices;
	
	typedef FT_STATUS (WINAPI *PtrToOpen)(int, FT_HANDLE *);
	PtrToOpen m_pOpen;
	int m_nDeviceIndex;

	typedef FT_STATUS (WINAPI *PtrToOpenEx)(PVOID,DWORD,FT_HANDLE *);
	PtrToOpenEx m_pOpenEx;

	typedef FT_STATUS (WINAPI *PtrToClose)(FT_HANDLE);
	PtrToClose m_pClose;

	typedef FT_STATUS (WINAPI *PtrToRead)(FT_HANDLE,LPVOID,DWORD,LPDWORD);
	PtrToRead m_pRead;

	typedef FT_STATUS (WINAPI *PtrToWrite)(FT_HANDLE,LPVOID,DWORD,LPDWORD);
	PtrToWrite m_pWrite;

	typedef FT_STATUS (WINAPI *PtrToResetDevice)(FT_HANDLE);
	PtrToResetDevice m_pResetDevice;

	typedef FT_STATUS (WINAPI *PtrToSetBaudRate)(FT_HANDLE, DWORD);
	PtrToSetBaudRate m_pSetBaudRate;
	DWORD m_nBaudRate;

	typedef FT_STATUS (WINAPI *PtrToSetDivisor)(FT_HANDLE,USHORT);
	PtrToSetDivisor m_pSetDivisor;

	typedef FT_STATUS (WINAPI *PtrToSetDataCharacteristics)(FT_HANDLE,UCHAR,UCHAR,UCHAR);
	PtrToSetDataCharacteristics m_pSetDataCharacteristics;

	typedef FT_STATUS (WINAPI *PtrToSetFlowControl)(FT_HANDLE,USHORT,UCHAR,UCHAR);
	PtrToSetFlowControl m_pSetFlowControl;

	typedef FT_STATUS (WINAPI *PtrToSetDtr)(FT_HANDLE);
	PtrToSetDtr m_pSetDtr;

	typedef FT_STATUS (WINAPI *PtrToClrDtr)(FT_HANDLE);
	PtrToClrDtr m_pClrDtr;

	typedef FT_STATUS (WINAPI *PtrToSetRts)(FT_HANDLE);
	PtrToSetRts m_pSetRts;

	typedef FT_STATUS (WINAPI *PtrToClrRts)(FT_HANDLE);
	PtrToClrRts m_pClrRts;

	typedef FT_STATUS (WINAPI *PtrToGetModemStatus)(FT_HANDLE,LPDWORD);
	PtrToGetModemStatus m_pGetModemStatus;

	typedef FT_STATUS (WINAPI *PtrToSetChars)(FT_HANDLE,UCHAR,UCHAR,UCHAR,UCHAR);
	PtrToSetChars m_pSetChars;

	typedef FT_STATUS (WINAPI *PtrToPurge)(FT_HANDLE,DWORD);
	PtrToPurge m_pPurge;

	typedef FT_STATUS (WINAPI *PtrToSetTimeouts)(FT_HANDLE,DWORD,DWORD);
	PtrToSetTimeouts m_pSetTimeouts;

	typedef FT_STATUS (WINAPI *PtrToGetQueueStatus)(FT_HANDLE,LPDWORD);
	PtrToGetQueueStatus m_pGetQueueStatus;

	typedef FT_STATUS (WINAPI *PtrToSetBreakOn)(FT_HANDLE);
	PtrToSetBreakOn m_pSetBreakOn;

	typedef FT_STATUS (WINAPI *PtrToSetBreakOff)(FT_HANDLE);
	PtrToSetBreakOff m_pSetBreakOff;

	typedef FT_STATUS (WINAPI *PtrToGetStatus)(FT_HANDLE,LPDWORD,LPDWORD,LPDWORD);
	PtrToGetStatus m_pGetStatus;

	typedef FT_STATUS (WINAPI *PtrToSetEventNotification)(FT_HANDLE,DWORD,PVOID);
	PtrToSetEventNotification m_pSetEventNotification;

	typedef FT_STATUS (WINAPI *PtrToIoCtl)(FT_HANDLE,DWORD,LPVOID,DWORD,LPVOID,DWORD,LPDWORD,LPOVERLAPPED);
	PtrToIoCtl m_pIoCtl;

	typedef FT_STATUS (WINAPI *PtrToSetWaitMask)(FT_HANDLE,DWORD);
	PtrToSetWaitMask m_pSetWaitMask;

	typedef FT_STATUS (WINAPI *PtrToWaitOnMask)(FT_HANDLE,DWORD);
	PtrToWaitOnMask m_pWaitOnMask;

	typedef FT_STATUS (WINAPI *PtrToGetDeviceInfo)(FT_HANDLE,FT_DEVICE *,LPDWORD,PCHAR,PCHAR,PVOID);
	PtrToGetDeviceInfo m_pGetDeviceInfo;

	typedef FT_STATUS (WINAPI *PtrToSetResetPipeRetryCount)(FT_HANDLE,DWORD);
	PtrToSetResetPipeRetryCount m_pSetResetPipeRetryCount;

	typedef FT_STATUS (WINAPI *PtrToStopInTask)(FT_HANDLE);
	PtrToStopInTask m_pStopInTask;

	typedef FT_STATUS (WINAPI *PtrToRestartInTask)(FT_HANDLE);
	PtrToRestartInTask m_pRestartInTask;

	typedef FT_STATUS (WINAPI *PtrToResetPort)(FT_HANDLE);
	PtrToResetPort m_pResetPort;

	typedef FT_STATUS (WINAPI *PtrToCyclePort)(FT_HANDLE);
	PtrToCyclePort m_pCyclePort;

	typedef FT_STATUS (WINAPI *PtrToCreateDeviceInfoList)(LPDWORD);
	PtrToCreateDeviceInfoList m_pCreateDeviceInfoList;

	typedef FT_STATUS (WINAPI *PtrToGetDeviceInfoList)(FT_DEVICE_LIST_INFO_NODE *,LPDWORD);
	PtrToGetDeviceInfoList m_pGetDeviceInfoList;
	FT_DEVICE_LIST_INFO_NODE *devInfo;

	typedef FT_STATUS (WINAPI *PtrToGetDeviceInfoDetail)(DWORD,LPDWORD,LPDWORD,LPDWORD,LPDWORD,PCHAR,PCHAR,FT_HANDLE);
	PtrToGetDeviceInfoDetail m_pGetDeviceInfoDetail;

	typedef FT_STATUS (WINAPI *PtrToGetDriverVersion)(FT_HANDLE,LPDWORD);
	PtrToGetDriverVersion m_pGetDriverVersion;

	typedef FT_STATUS (WINAPI *PtrToGetLibraryVersion)(LPDWORD);
	PtrToGetLibraryVersion m_pGetLibraryVersion;

	typedef FT_STATUS (WINAPI *PtrToSetDeadmanTimeout)(FT_HANDLE,DWORD);
	PtrToSetDeadmanTimeout m_pSetDeadmanTimeout;

	typedef FT_STATUS (WINAPI *PtrToRescan)();
	PtrToRescan m_pRescan;

	typedef FT_STATUS (WINAPI *PtrToReload)(WORD,WORD);
	PtrToReload m_pReload;
};
