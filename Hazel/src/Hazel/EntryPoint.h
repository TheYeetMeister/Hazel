#pragma once

#ifdef HZ_PLATFORM_WINDOWS

extern Hazel::Application* Hazel::CreateApplication();

int main(int argc, char** argv)
{
	Hazel::Log::Init();
	Hazel::Log::GetCoreLogger()->warn("Initialized Log!");
	Hazel::Log::GetClientLogger()->info("Hello world!");

	auto app = Hazel::CreateApplication();
	app->run();
	delete app;
}

#endif