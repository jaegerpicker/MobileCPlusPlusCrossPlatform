#pragma once

#include <iostream>
#ifdef WINDOWSPHONECPPLib
#define WPCPPLib _declspec(dllexport)
#else
#define WPCPPLib _declspec(dllexport)
#endif

class WPCPPLib WindSquare
{
public:
	WindSquare();
	~WindSquare();
	void write();
};