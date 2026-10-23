#include "hzpch.h"
#include "application.h"

#include "Hazel/Events/ApplicationEvent.h"
#include "Hazel/Log.h"

namespace Hazel {
	Application::Application()
	{

	}

	Application::~Application()
	{

	}

	void Application::run()
	{
		WindowResizeEvent e(1280, 720);
		HZ_TRACE("{0}", e);

		while (true);
	}
}